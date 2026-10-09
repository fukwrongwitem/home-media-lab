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
    "config\homarr",
    "config\unbound",
    "config\unmanic",
    "config\pihole\etc-pihole",
    "config\pihole\etc-dnsmasq.d",
    "media\movies",
    "media\tv",
    "media\music",
    "media\home-videos",
    "work\rips",
    "work\encodes",
    "work\unmanic-cache"
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
Write-Host "  WORK_ROOT=./work"
Write-Host ""
Write-Host "Optional absolute override if media lives on another drive later:"
Write-Host "  MEDIA_ROOT=<drive>:/media"
Write-Host ""
Write-Host "Copy the whole stack folder to move to another machine — see docs\migrate.md"
