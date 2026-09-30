#Requires -Version 5.1
<#
.SYNOPSIS
  Gaming Mode ON - pause download/*arr/CPU-heavy containers.
.DESCRIPTION
  Stops qbittorrent, *arr, jellyseerr, flaresolverr, bazarr, music, compress,
  recyclarr, and homarr. Leaves jellyfin + pihole + unbound running for house use.
  Records which stopped services were running so gaming-mode-off can restore them.
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

Write-Host '=== Gaming Mode ON ==='
Set-MediaServerLocation

if (-not (Wait-DockerEngine)) {
    if (-not $NoPause) { Read-Host 'Press Enter to close' }
    exit 1
}

$running = Get-RunningContainerNames
$toStop = @($script:GamingStopServices | Where-Object { $running -contains $_ })

$state = [ordered]@{
    enabledAt     = (Get-Date).ToString('o')
    keptRunning   = @($script:KeepRunning | Where-Object { $running -contains $_ })
    stopped       = $toStop
    alreadyDown   = @($script:GamingStopServices | Where-Object { $running -notcontains $_ })
}
if (-not $DryRun) {
    $state | ConvertTo-Json | Set-Content -LiteralPath $script:StateFile -Encoding UTF8
}

if ($toStop.Count -eq 0) {
    Write-Host '[ok] No download/*arr heavy services were running.'
} else {
    Write-Host ("[..] Stopping: {0}" -f ($toStop -join ', '))
    if ($DryRun) {
        Write-Host ('[DryRun] Would run: docker compose stop {0}' -f ($toStop -join ' '))
    } else {
        & docker compose stop @toStop
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "docker compose stop exited with code $LASTEXITCODE"
        } else {
            Write-Host '[ok] Heavy services stopped.'
        }
    }
}

Show-GamingModeStatus
Write-Host 'Jellyfin + DNS (pihole/unbound) left up when they were already running.'
Write-Host 'Resume later with: Homelab Resume shortcut, or .\bin\gaming-mode-off.ps1'

if (-not $NoPause) {
    Write-Host ''
    Read-Host 'Press Enter to close'
}
