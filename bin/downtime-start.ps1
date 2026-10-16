# Nightly downtime START - stop the media stack + Jellyfin overnight (scheduled 1:00 AM)
# Never touches DNS (pihole, unbound) or Docker Desktop itself.
# Usage: .\bin\downtime-start.ps1 [-DryRun]   (-WhatIf is an alias of -DryRun)
param([Alias('WhatIf')][switch]$DryRun)
$log = Join-Path $PSScriptRoot 'downtime.log'
$containers = @('unmanic','homarr')        # edit to match your stack
$jellyfinService = 'JellyfinServer'         # default name from the Jellyfin Server for Windows installer
function Log($m) { $l = "{0} [START]{1} {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $(if ($DryRun) { ' [DRYRUN]' } else { '' }), $m; Add-Content -Path $log -Value $l; Write-Host $l }
Log "---- downtime start ----"
$exit = 0

# Jellyfin (native Windows service)
$svc = Get-Service -Name $jellyfinService -ErrorAction SilentlyContinue
if (-not $svc) { Log "Jellyfin service '$jellyfinService' not found" }
elseif ($svc.Status -ne 'Running') { Log "Jellyfin service already $($svc.Status)" }
elseif ($DryRun) { Log "would stop service $jellyfinService (currently Running)" }
else {
  try { Stop-Service -Name $jellyfinService -Force -ErrorAction Stop; $svc.WaitForStatus('Stopped','00:00:45'); Log "Stopped service $jellyfinService" }
  catch { Log "FAILED to stop $jellyfinService : $($_.Exception.Message)"; $exit = 2 }
}

# Docker guard
$null = docker info 2>$null
if ($LASTEXITCODE -ne 0) { Log "Docker not reachable - skipping containers"; exit 1 }
$running = @(docker ps --format '{{.Names}}' 2>$null)
foreach ($c in $containers) {
  if ($running -notcontains $c) { Log "$c not running - skip"; continue }
  if ($DryRun) { Log "would docker stop $c"; continue }
  $null = docker stop $c 2>$null
  if ($LASTEXITCODE -eq 0) { Log "Stopped $c" } else { Log "FAILED to stop $c"; $exit = 2 }
}
$up = @(docker ps --format '{{.Names}}' 2>$null)
Log ("Still running: " + ($up -join ', '))
Log "---- downtime start done (exit=$exit) ----"
exit $exit
