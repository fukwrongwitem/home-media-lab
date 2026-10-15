#Requires -RunAsAdministrator
# Example: Private-profile inbound TCP allow rules for the web UI ports.
# Idempotent: removes any existing rule with the same DisplayName before re-adding.
# Replace the placeholder ports with the values from your .env.
# Pi-hole DNS bound to loopback does not need a LAN firewall rule.
$ErrorActionPreference = 'Stop'
$rules = @(
  @{ Name = 'HomeMedia - Jellyfin';  Port = '<JELLYFIN_PORT>' },
  @{ Name = 'HomeMedia - Homarr';    Port = '<HOMARR_PORT>' },
  @{ Name = 'HomeMedia - PiholeWeb'; Port = '<PIHOLE_WEB_PORT>' }
)
foreach ($r in $rules) {
  Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
  New-NetFirewallRule -DisplayName $r.Name -Group 'HomeMedia' -Direction Inbound -Action Allow `
    -Protocol TCP -LocalPort $r.Port -Profile Private | Out-Null
  Write-Host "OK  $($r.Name) (TCP $($r.Port), Private)"
}
