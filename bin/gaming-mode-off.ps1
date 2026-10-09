#Requires -Version 5.1
<#
.SYNOPSIS
  Homelab Resume (Gaming Mode OFF) - restore services stopped for gaming.
.DESCRIPTION
  Starts containers previously recorded by gaming-mode-on.ps1. If no state file
  exists, starts any GamingStopServices containers that exist but are stopped.
  Does not recreate removed containers; uses docker compose start.
.NOTES
  Stack root: parent of this bin/ folder
  Docs: docs/gaming-mode.md
#>
param(
    [switch]$DryRun,
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'
$common = Join-Path $PSScriptRoot 'gaming-mode-common.ps1'
. $common

Write-Host '=== Homelab Resume (Gaming Mode OFF) ==='
Set-MediaServerLocation

if (-not (Wait-DockerEngine)) {
    if (-not $NoPause) { Read-Host 'Press Enter to close' }
    exit 1
}

$toStart = @()
if (Test-Path -LiteralPath $script:StateFile) {
    try {
        $state = Get-Content -LiteralPath $script:StateFile -Raw | ConvertFrom-Json
        if ($state.stopped) {
            $toStart = @($state.stopped)
            Write-Host ("[..] Restoring from state ({0}): {1}" -f $state.enabledAt, ($toStart -join ', '))
        }
    } catch {
        Write-Warning "Could not read state file: $($script:StateFile) - falling back to known heavy list."
    }
}

if ($toStart.Count -eq 0) {
    # Fallback: start any known heavy service that has a stopped container
    $all = docker ps -a --format '{{.Names}} {{.Status}}' 2>$null
    foreach ($svc in $script:GamingStopServices) {
        $line = $all | Where-Object { $_ -match "^$([regex]::Escape($svc))\s" }
        if ($line -and ($line -notmatch '\sUp\s')) {
            $toStart += $svc
        }
    }
    if ($toStart.Count -gt 0) {
        Write-Host ("[..] No state file / empty; starting stopped heavy services: {0}" -f ($toStart -join ', '))
    }
}

if ($toStart.Count -eq 0) {
    Write-Host '[ok] Nothing to restore (no recorded/stopped heavy services).'
} else {
    if ($DryRun) {
        Write-Host ('[DryRun] Would run: docker compose start {0}' -f ($toStart -join ' '))
    } else {
        & docker compose start @toStart
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "docker compose start exited with code $LASTEXITCODE"
            Write-Host 'Tip: if a container was removed, recreate with the usual profile, e.g.:'
            Write-Host '  docker compose --profile core --profile dns --profile dashboard up -d'
        } else {
            Write-Host '[ok] Heavy services started.'
        }
    }
}

if ((Test-Path -LiteralPath $script:StateFile) -and -not $DryRun) {
    Remove-Item -LiteralPath $script:StateFile -Force -ErrorAction SilentlyContinue
}

Show-GamingModeStatus

if (-not $NoPause) {
    Write-Host ''
    Read-Host 'Press Enter to close'
}
