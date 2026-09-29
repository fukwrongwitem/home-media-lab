# Create media-server folder layout under the portable stack root.
# Default Root: parent of scripts\ (the folder that contains docker-compose.yml).
#
# Usage:
#   .\scripts\init-folders.ps1
#   .\scripts\init-folders.ps1 -Root "<STACK_ROOT>"

param(
    [string]$Root = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

Write-Host "Creating folder layout under: $Root"

$dirs = @(
    "config\jellyfin",
    "config\qbittorrent",
    "config\prowlarr",
    "config\sonarr",
    "config\radarr",
    "config\bazarr",
    "config\lidarr",
    "config\jellyseerr",
    "config\homarr",
    "config\recyclarr",
    "config\unbound",
    "config\nicotine-plus",
    "config\unmanic",
    "config\pihole\etc-pihole",
    "config\pihole\etc-dnsmasq.d",
    "media\movies",
    "media\tv",
    "media\music",
    "downloads\complete",
    "downloads\incomplete",
    "downloads\complete\soulseek",
    "downloads\incomplete\soulseek",
    "downloads\unmanic-cache"
)

foreach ($rel in $dirs) {
    $path = Join-Path $Root $rel
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}

Write-Host "Done."
Write-Host ""
Write-Host "Use these relative paths in .env (resolved from the compose file directory):"
Write-Host "  CONFIG_ROOT=./config"
Write-Host "  MEDIA_ROOT=./media"
Write-Host "  DOWNLOADS_ROOT=./downloads"
Write-Host ""
Write-Host "Optional absolute override if media lives on another drive later:"
Write-Host "  MEDIA_ROOT=E:/media"
Write-Host ""
Write-Host "Copy the whole stack folder to move to another machine — see docs\migrate.md"
