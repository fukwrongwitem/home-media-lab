# Changelog

## 2026-09-29 — Wire-up guide + migrate scripts
- First-run wire-up order for Jellyseerr, overflow roots, DNS, and Gaming Mode
- Added `scripts/init-folders.*` and `scripts/pack-for-move.*` used by the migrate docs
- Fixed broken links left from the first repo cut

## 2026-09 — Jellyfin plugins + Seerr in the UI
- Installed Jellyfin Enhanced (Seerr search/request to Jellyseerr over compose DNS), Intro Skipper, Media Bar, File Transformation
- Notes for community plugin repos and client refresh after restart
- [docs/jellyfin-plugins.md](docs/jellyfin-plugins.md)

## 2026-09 — Gaming Mode
- PowerShell on/off scripts stop download/*arr/CPU-heavy containers; Jellyfin + Pi-hole/Unbound stay up
- Desktop shortcuts; state file so resume only starts what was paused
- [docs/gaming-mode.md](docs/gaming-mode.md), `bin/`

## 2026-09 — Downloads on secondary volume
- Pointed `DOWNLOADS_ROOT` at a second drive; left container paths as `/downloads` so Sonarr/Radarr maps stay the same
- [docs/downloads-layout.md](docs/downloads-layout.md)

## 2026-09 — Jellyfin library freshness (Docker Desktop)
- Realtime file watchers on Windows bind mounts kept missing imports
- Wired Sonarr/Radarr → Jellyfin MediaBrowser Connect (path maps over compose DNS) and shortened Scan Media Library to hourly
- [docs/jellyfin-library-updates.md](docs/jellyfin-library-updates.md)

## 2026-09 — Local access without custom router DNS
- Homarr and the rest of the stack via `127.0.0.1` on this PC (LAN IP from other devices)
- Docker Desktop hairpin quirk; Homarr tile pings use Docker service names
- Dashboards work with ISP DNS; Pi-hole/dnsproxy not required just to open Homarr

## 2026-09 — Windows Docker DNS via host dnsproxy
- Pi-hole DNS bound to `127.0.0.1:5053` only (Docker Desktop / ICS conflict on LAN `:53`)
- AdGuard dnsproxy on the host (`:53` → `127.0.0.1:5053`); WSL mirrored networking + Private Ethernet notes
- Unbound still upstream of Pi-hole on the compose network

## 2026-09 — Recursive DNS with Unbound
- Unbound (`klutchell/unbound`) on the `dns` profile next to Pi-hole
- Pi-hole upstream set to `unbound` instead of a public resolver
- Optional: point router DHCP DNS at this host’s LAN IP only while dns is running

## 2026-09 — Dual-drive library expansion
- Secondary movie/TV mounts for overflow storage
- App config stays on the primary volume

## 2026-09 — Portable media lab v1
- Docker Compose stack with RAM-aware profiles on a gaming PC
- Docs for first-run wiring, space-saving encodes, Tailscale, and host migration
- Optional profiles: requests, subs, music, DNS, overnight compression
