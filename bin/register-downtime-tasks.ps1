# Run ONCE from an elevated (Run as administrator) PowerShell in the stack root:
#   powershell -ExecutionPolicy Bypass -File .\bin\register-downtime-tasks.ps1
# Registers the tasks for the signed-in user, since Docker Desktop only runs in that session.
$ErrorActionPreference = 'Stop'
$user = "$env:USERDOMAIN\$env:USERNAME"
function Reg($name, $time, $script, $late) {
  $path = Join-Path $PSScriptRoot $script
  $a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$path`""
  $t = New-ScheduledTaskTrigger -Daily -At $time
  $p = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest
  $s = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
  $s.StartWhenAvailable = $late
  Register-ScheduledTask -TaskName $name -Action $a -Trigger $t -Principal $p -Settings $s -Description "Nightly media-server downtime ($script)" -Force | Out-Null
  "registered $name"
}
Reg 'Homelab Downtime Start' '1:00AM' 'downtime-start.ps1' $false   # missed 1 AM start is skipped, not run late
Reg 'Homelab Downtime End'   '8:00AM' 'downtime-end.ps1'   $true    # runs late if the PC was off at 8
Get-ScheduledTask -TaskName 'Homelab Downtime*' | Get-ScheduledTaskInfo | Select-Object TaskName, NextRunTime | Format-Table | Out-String
