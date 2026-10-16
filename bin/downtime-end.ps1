# Nightly downtime END - bring the media stack + Jellyfin back (scheduled 8:00 AM)
# Only starts things. Gaming Mode OFF starts the same containers, so the two never conflict.
# Usage: .\bin\downtime-end.ps1 [-DryRun]   (-WhatIf is an alias of -DryRun)
param([Alias('WhatIf')][switch]$DryRun)
$log = Join-Path $PSScriptRoot 'downtime.log'
$containers = @('unmanic','homarr')        # same list as downtime-start.ps1
$verify = $containers + @('pihole','unbound')
$jellyfinService = 'JellyfinServer'
function Log($m) { $l = "{0} [END]{1} {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $(if ($DryRun) { ' [DRYRUN]' } else { '' }), $m; Add-Content -Path $log -Value $l; Write-Host $l }
Log "---- downtime end ----"
$exit = 0

# Jellyfin
$svc = Get-Service -Name $jellyfinService -ErrorAction SilentlyContinue
if (-not $svc) { Log "Jellyfin service '$jellyfinService' not found"; $exit = 2 }
elseif ($svc.Status -eq 'Running') { Log "Jellyfin service already Running" }
elseif ($DryRun) { Log "would start service $jellyfinService (currently $($svc.Status))" }
else {
  try { Start-Service -Name $jellyfinService -ErrorAction Stop; $svc.WaitForStatus('Running','00:00:45'); Log "Started service $jellyfinService" }
  catch { Log "FAILED to start $jellyfinService : $($_.Exception.Message)"; $exit = 2 }
}

# Docker guard. Docker Desktop only starts at login, so after a late boot wait up to 10 min for it.
$ok = $false
$deadline = (Get-Date).AddMinutes(10)
do {
  $null = docker info 2>$null
  if ($LASTEXITCODE -eq 0) { $ok = $true; break }
  if ($DryRun) { break }
  Start-Sleep 20
} while ((Get-Date) -lt $deadline)
if (-not $ok) { Log "Docker not reachable - containers not started"; exit 1 }

$running = @(docker ps --format '{{.Names}}' 2>$null)
foreach ($c in $containers) {
  if ($running -contains $c) { Log "$c already running"; continue }
  if ($DryRun) { Log "would docker start $c"; continue }
  $null = docker start $c 2>$null
  if ($LASTEXITCODE -eq 0) { Log "Started $c" } else { Log "FAILED to start $c"; $exit = 2 }
}
if (-not $DryRun) { Start-Sleep 8 }
$up = @(docker ps --format '{{.Names}}' 2>$null)
foreach ($c in $verify) { Log ("{0}: {1}" -f $c, $(if ($up -contains $c) { 'UP' } else { 'DOWN' })) }
$jf = (Get-Service -Name $jellyfinService -ErrorAction SilentlyContinue).Status
Log "Jellyfin service: $jf"
if ($jf -ne 'Running' -and -not $DryRun) { $exit = 2 }
Log "---- downtime end done (exit=$exit) ----"
exit $exit
