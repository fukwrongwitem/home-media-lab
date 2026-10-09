# Create a dated archive of this portable media-server stack for transfer.
#
# Always includes: compose files, .env.example, scripts, docs, config/
# Media is optional (-IncludeMedia). work\ (rip staging + encode cache) is
# skipped unless -IncludeWork is passed.
#
# Usage:
#   .\scripts\pack-for-move.ps1
#   .\scripts\pack-for-move.ps1 -IncludeMedia
#   .\scripts\pack-for-move.ps1 -IncludeMedia -IncludeWork
#   .\scripts\pack-for-move.ps1 -OutputDir "<BACKUP_DIR>"

param(
    [string]$Root = "",
    [string]$OutputDir = "",
    [switch]$IncludeMedia,
    [switch]$IncludeWork
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = $Root
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$archiveName = "media-server-move-$stamp"
$staging = Join-Path $env:TEMP $archiveName
$zipPath = Join-Path $OutputDir "$archiveName.zip"

Write-Host "Stack root:  $Root"
Write-Host "Staging:     $staging"
Write-Host "IncludeMedia=$IncludeMedia  IncludeWork=$IncludeWork"

if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force -Path $staging | Out-Null

function Copy-ItemSafe {
    param([string]$Rel)
    $src = Join-Path $Root $Rel
    if (-not (Test-Path $src)) {
        Write-Host "  skip (missing): $Rel"
        return
    }
    $dst = Join-Path $staging $Rel
    $dstParent = Split-Path $dst -Parent
    if (-not (Test-Path $dstParent)) {
        New-Item -ItemType Directory -Force -Path $dstParent | Out-Null
    }
    Copy-Item -Path $src -Destination $dst -Recurse -Force
    Write-Host "  + $Rel"
}

# Always: compose + docs + scripts + env example + gitignore
$always = @(
    "docker-compose.yml",
    ".env.example",
    ".gitignore",
    "README.md",
    "scripts",
    "docs",
    "config"
)
foreach ($rel in $always) { Copy-ItemSafe $rel }

# .env if present (secrets — you may exclude manually before sharing)
if (Test-Path (Join-Path $Root ".env")) {
    Copy-ItemSafe ".env"
} else {
    Write-Host "  skip (missing): .env"
}

# work\ = rip staging and encode cache (scratch; skipped by default)
if ($IncludeWork) {
    Copy-ItemSafe "work"
} else {
    Write-Host "  skip (no -IncludeWork): work"
    foreach ($sub in @("rips", "encodes")) {
        New-Item -ItemType Directory -Force -Path (Join-Path $staging "work\$sub") | Out-Null
    }
}

if ($IncludeMedia) {
    Copy-ItemSafe "media"
} else {
    Write-Host "  skip (no -IncludeMedia): media  (re-run with -IncludeMedia to pack library)"
    # placeholder layout
    foreach ($sub in @("movies", "tv", "music", "home-videos")) {
        New-Item -ItemType Directory -Force -Path (Join-Path $staging "media\$sub") | Out-Null
    }
}

# Prefer tar if available (smaller, preserves better); else Compress-Archive
$tar = Get-Command tar -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

if ($tar) {
    $tarPath = Join-Path $OutputDir "$archiveName.tar.gz"
    Push-Location (Split-Path $staging -Parent)
    try {
        & tar -czf $tarPath $archiveName
    } finally {
        Pop-Location
    }
    Remove-Item -Recurse -Force $staging
    Write-Host ""
    Write-Host "Created: $tarPath"
    Write-Host "Extract on new host, then: cd into folder, copy .env.example -> .env if needed, docker compose --profile core up -d"
    Write-Host "See docs\migrate.md"
} else {
    if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
    Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -CompressionLevel Optimal
    Remove-Item -Recurse -Force $staging
    Write-Host ""
    Write-Host "Created: $zipPath"
    Write-Host "Extract on new host, then: cd into folder, copy .env.example -> .env if needed, docker compose --profile core up -d"
    Write-Host "See docs\migrate.md"
}
