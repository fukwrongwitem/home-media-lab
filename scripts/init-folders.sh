#!/usr/bin/env bash
# Create media-server folder layout under the portable stack root.
# Default Root: parent of scripts/ (the folder that contains docker-compose.yml).
#
# Usage:
#   ./scripts/init-folders.sh
#   ./scripts/init-folders.sh /path/to/media-server

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-${MEDIA_SERVER_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}}"

echo "Creating folder layout under: $ROOT"

mkdir -p \
  "$ROOT/config/jellyfin" \
  "$ROOT/config/qbittorrent" \
  "$ROOT/config/prowlarr" \
  "$ROOT/config/sonarr" \
  "$ROOT/config/radarr" \
  "$ROOT/config/bazarr" \
  "$ROOT/config/lidarr" \
  "$ROOT/config/jellyseerr" \
  "$ROOT/config/homarr" \
  "$ROOT/config/recyclarr" \
  "$ROOT/config/unbound" \
  "$ROOT/config/nicotine-plus" \
  "$ROOT/config/unmanic" \
  "$ROOT/config/pihole/etc-pihole" \
  "$ROOT/config/pihole/etc-dnsmasq.d" \
  "$ROOT/media/movies" \
  "$ROOT/media/tv" \
  "$ROOT/media/music" \
  "$ROOT/downloads/complete" \
  "$ROOT/downloads/incomplete" \
  "$ROOT/downloads/complete/soulseek" \
  "$ROOT/downloads/incomplete/soulseek" \
  "$ROOT/downloads/unmanic-cache"

echo "Done."
echo ""
echo "Use these relative paths in .env (resolved from the compose file directory):"
echo "  CONFIG_ROOT=./config"
echo "  MEDIA_ROOT=./media"
echo "  DOWNLOADS_ROOT=./downloads"
echo ""
echo "Optional absolute override if media lives on another drive later:"
echo "  MEDIA_ROOT=/mnt/storage/media"
echo ""
echo "Copy the whole stack folder to move to another machine — see docs/migrate.md"
