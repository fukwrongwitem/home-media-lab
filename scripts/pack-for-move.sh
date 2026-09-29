#!/usr/bin/env bash
# Create a dated archive of this portable media-server stack for transfer.
#
# Always includes: compose files, .env.example, scripts, docs, config/
# Media is optional (--include-media). Incomplete downloads can be skipped (--skip-incomplete).
#
# Usage:
#   ./scripts/pack-for-move.sh
#   ./scripts/pack-for-move.sh --skip-incomplete
#   ./scripts/pack-for-move.sh --include-media --skip-incomplete
#   ./scripts/pack-for-move.sh --output-dir /tmp/backups

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$ROOT"
INCLUDE_MEDIA=0
SKIP_INCOMPLETE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-media|-IncludeMedia) INCLUDE_MEDIA=1; shift ;;
    --skip-incomplete|-SkipIncomplete) SKIP_INCOMPLETE=1; shift ;;
    --output-dir|-OutputDir) OUTPUT_DIR="$2"; shift 2 ;;
    --root|-Root) ROOT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--include-media] [--skip-incomplete] [--output-dir DIR]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE_NAME="media-server-move-${STAMP}"
STAGING="$(mktemp -d)/${ARCHIVE_NAME}"
mkdir -p "$STAGING" "$OUTPUT_DIR"

echo "Stack root:  $ROOT"
echo "Staging:     $STAGING"
echo "IncludeMedia=$INCLUDE_MEDIA  SkipIncomplete=$SKIP_INCOMPLETE"

copy_rel() {
  local rel="$1"
  if [[ -e "$ROOT/$rel" ]]; then
    mkdir -p "$(dirname "$STAGING/$rel")"
    cp -a "$ROOT/$rel" "$STAGING/$rel"
    echo "  + $rel"
  else
    echo "  skip (missing): $rel"
  fi
}

# Always
for rel in docker-compose.yml .env.example .gitignore README.md scripts docs config; do
  copy_rel "$rel"
done

if [[ -f "$ROOT/.env" ]]; then
  copy_rel ".env"
else
  echo "  skip (missing): .env"
fi

# downloads
if [[ -d "$ROOT/downloads" ]]; then
  mkdir -p "$STAGING/downloads"
  copy_rel "downloads/complete"
  if [[ "$SKIP_INCOMPLETE" -eq 0 ]]; then
    copy_rel "downloads/incomplete"
  else
    echo "  skip (SkipIncomplete): downloads/incomplete"
    mkdir -p "$STAGING/downloads/incomplete/soulseek"
  fi
else
  echo "  skip (missing): downloads"
fi

if [[ "$INCLUDE_MEDIA" -eq 1 ]]; then
  copy_rel "media"
else
  echo "  skip (no --include-media): media  (re-run with --include-media to pack library)"
  mkdir -p "$STAGING/media/movies" "$STAGING/media/tv" "$STAGING/media/music"
fi

OUT="$OUTPUT_DIR/${ARCHIVE_NAME}.tar.gz"
tar -C "$(dirname "$STAGING")" -czf "$OUT" "$(basename "$STAGING")"
rm -rf "$(dirname "$STAGING")"

echo ""
echo "Created: $OUT"
echo "Extract on new host, then: cd into folder, copy .env.example -> .env if needed, docker compose --profile core up -d"
echo "See docs/migrate.md"
