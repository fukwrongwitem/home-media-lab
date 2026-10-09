#!/usr/bin/env bash
# Create a dated archive of this portable media-server stack for transfer.
#
# Always includes: compose files, .env.example, scripts, docs, config/
# Media is optional (--include-media). work/ (rip staging + encode cache) is
# skipped unless --include-work is passed.
#
# Usage:
#   ./scripts/pack-for-move.sh
#   ./scripts/pack-for-move.sh --include-media
#   ./scripts/pack-for-move.sh --include-media --include-work
#   ./scripts/pack-for-move.sh --output-dir /tmp/backups

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$ROOT"
INCLUDE_MEDIA=0
INCLUDE_WORK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-media|-IncludeMedia) INCLUDE_MEDIA=1; shift ;;
    --include-work|-IncludeWork) INCLUDE_WORK=1; shift ;;
    --output-dir|-OutputDir) OUTPUT_DIR="$2"; shift 2 ;;
    --root|-Root) ROOT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--include-media] [--include-work] [--output-dir DIR]"
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
echo "IncludeMedia=$INCLUDE_MEDIA  IncludeWork=$INCLUDE_WORK"

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

# work/ = rip staging and encode cache (scratch; skipped by default)
if [[ "$INCLUDE_WORK" -eq 1 ]]; then
  copy_rel "work"
else
  echo "  skip (no --include-work): work"
  mkdir -p "$STAGING/work/rips" "$STAGING/work/encodes"
fi

if [[ "$INCLUDE_MEDIA" -eq 1 ]]; then
  copy_rel "media"
else
  echo "  skip (no --include-media): media  (re-run with --include-media to pack library)"
  mkdir -p "$STAGING/media/movies" "$STAGING/media/tv" "$STAGING/media/music" "$STAGING/media/home-videos"
fi

OUT="$OUTPUT_DIR/${ARCHIVE_NAME}.tar.gz"
tar -C "$(dirname "$STAGING")" -czf "$OUT" "$(basename "$STAGING")"
rm -rf "$(dirname "$STAGING")"

echo ""
echo "Created: $OUT"
echo "Extract on new host, then: cd into folder, copy .env.example -> .env if needed, docker compose --profile core up -d"
echo "See docs/migrate.md"
