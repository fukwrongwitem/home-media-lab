#Requires -Version 5.1
<#
.SYNOPSIS
  Create Desktop shortcuts for Homelab Gaming Mode / Resume.
#>
[CmdletBinding()]
param(
    [string]$DesktopPath = [Environment]::GetFolderPath('Desktop')
)

$ErrorActionPreference = 'Stop'
$bin = $PSScriptRoot
$stackRoot = (Resolve-Path (Join-Path $bin '..')).Path
$onScript  = Join-Path $bin 'gaming-mode-on.ps1'
$offScript = Join-Path $bin 'gaming-mode-off.ps1'

foreach ($p in @($onScript, $offScript)) {
    if (-not (Test-Path -LiteralPath $p)) {
        throw "Missing script: $p"
    }
}

$wsh = New-Object -ComObject WScript.Shell
$pwsh = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

function New-HomelabShortcut {
    param(
        [string]$LinkPath,
        [string]$ScriptPath,
        [string]$Description
    )
    $sc = $wsh.CreateShortcut($LinkPath)
    $sc.TargetPath = $pwsh
    $sc.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $sc.WorkingDirectory = $stackRoot
    $sc.WindowStyle = 1
    $sc.Description = $Description
    # Prefer Docker Desktop icon if present
    $ddIco = Join-Path ${env:ProgramFiles} 'Docker\Docker\Docker Desktop.exe'
    if (Test-Path -LiteralPath $ddIco) {
        $sc.IconLocation = "$ddIco,0"
    }
    $sc.Save()
    Write-Host "[ok] $LinkPath"
}

$onLink  = Join-Path $DesktopPath 'Homelab Gaming Mode.lnk'
$offLink = Join-Path $DesktopPath 'Homelab Resume.lnk'

New-HomelabShortcut -LinkPath $onLink  -ScriptPath $onScript  -Description 'Stop download/*arr heavy Docker services; leave Jellyfin + DNS up'
New-HomelabShortcut -LinkPath $offLink -ScriptPath $offScript -Description 'Restore homelab services paused for gaming'

Write-Host ''
Write-Host "Desktop shortcuts created under: $DesktopPath"
