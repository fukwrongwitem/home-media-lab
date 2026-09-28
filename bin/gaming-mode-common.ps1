# Shared helpers for gaming-mode-on / gaming-mode-off.
# Dot-source from those scripts; do not run directly.

$script:MediaServerRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$script:StateFile = Join-Path $PSScriptRoot '.gaming-mode-state.json'

# Download / *arr / CPU-heavy services to pause while gaming.
# Leave jellyfin + pihole + unbound running for house streaming / DNS.
$script:GamingStopServices = @(
    'qbittorrent'
    'sonarr'
    'radarr'
    'prowlarr'
    'flaresolverr'
    'jellyseerr'
    'bazarr'
    'lidarr'
    'nicotine-plus'
    'unmanic'
    'recyclarr'
    'homarr'
)

$script:KeepRunning = @('jellyfin', 'pihole', 'unbound')

function Wait-DockerEngine {
    param(
        [int]$TimeoutSec = 180,
        [int]$PollSec = 3
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    $dd = Join-Path ${env:ProgramFiles} 'Docker\Docker\Docker Desktop.exe'

    while ((Get-Date) -lt $deadline) {
        docker info 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host '[ok] Docker engine reachable.'
            return $true
        }

        if (Test-Path -LiteralPath $dd) {
            $running = Get-Process -Name 'Docker Desktop' -ErrorAction SilentlyContinue
            if (-not $running) {
                Write-Host '[..] Starting Docker Desktop...'
                Start-Process -FilePath $dd | Out-Null
            }
        }

        Write-Host '[..] Waiting for Docker engine...'
        Start-Sleep -Seconds $PollSec
    }

    Write-Error "Docker engine not reachable after ${TimeoutSec}s. Open Docker Desktop and retry."
    return $false
}

function Set-MediaServerLocation {
    if (-not (Test-Path -LiteralPath $script:MediaServerRoot)) {
        throw "Media server root not found: $($script:MediaServerRoot)"
    }
    Set-Location -LiteralPath $script:MediaServerRoot
}

function Get-RunningContainerNames {
    $out = docker ps --format '{{.Names}}' 2>$null
    if (-not $out) { return @() }
    return @($out | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Show-GamingModeStatus {
    Write-Host ''
    Write-Host '=== Homelab status ==='
    docker compose ps -a --format 'table {{.Name}}\t{{.Status}}\t{{.Service}}' 2>$null
    Write-Host ''
    $running = Get-RunningContainerNames
    $kept = $script:KeepRunning | Where-Object { $running -contains $_ }
    $stopped = $script:GamingStopServices | Where-Object { $running -notcontains $_ }
    $stillUp = $script:GamingStopServices | Where-Object { $running -contains $_ }
    Write-Host ("Keep-alive up : {0}" -f ($(if ($kept) { $kept -join ', ' } else { '(none)' })))
    Write-Host ("Heavy stopped : {0}" -f ($(if ($stopped) { $stopped -join ', ' } else { '(none)' })))
    if ($stillUp) {
        Write-Host ("Heavy still up: {0}" -f ($stillUp -join ', '))
    }
}
