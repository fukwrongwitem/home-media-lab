# Changelog

## 2026-09 — Jellyfin plugins + Seerr-in-UI
- Installed Jellyfin Enhanced (Seerr search/request via compose DNS to Jellyseerr), Intro Skipper, Media Bar, and File Transformation
- Documented community plugin repositories and post-restart client refresh steps
- See [docs/jellyfin-plugins.md](docs/jellyfin-plugins.md)

## 2026-09 — Gaming Mode for dual-use PC
- Added PowerShell Gaming Mode on/off scripts that stop download/*arr/CPU-heavy containers while leaving Jellyfin + Pi-hole/Unbound running
- Desktop shortcut helper; state file records what was paused for clean resume
- See [docs/gaming-mode.md](docs/gaming-mode.md) and `bin/`

## 2026-09 — Downloads on secondary volume
- Moved `DOWNLOADS_ROOT` to a second drive; kept container paths (`/downloads`) so Sonarr/Radarr maps stay stable
- Documented primary vs overflow library + download scratch layout
- See [docs/downloads-layout.md](docs/downloads-layout.md)

## 2026-09 — Jellyfin library freshness on Docker Desktop
- Documented unreliable realtime file watchers on Windows bind mounts
- Wired Sonarr/Radarr → Jellyfin MediaBrowser Connect (path maps over compose DNS) plus hourly library scan safety net
- See [docs/jellyfin-library-updates.md](docs/jellyfin-library-updates.md)

## 2026-09 — Local access without custom router DNS
- Documented Homarr / stack URLs via `127.0.0.1` (and LAN IP for other devices)
- Noted Docker Desktop hairpin + Homarr tile ping URLs on the compose network
- Confirmed dashboards work with ISP DNS; Pi-hole/dnsproxy optional for UI access

## 2026-09 — Windows Docker DNS on :53 via host dnsproxy
- Pi-hole DNS published only as `127.0.0.1:5053` (avoids Docker Desktop / ICS conflict on LAN UDP/TCP 53)
- Documented AdGuard dnsproxy on the host (`:53` → `127.0.0.1:5053`), WSL mirrored networking, Private Ethernet + firewall notes
- Unbound remains Pi-hole’s recursive upstream on the compose network

## 2026-09 — Recursive DNS with Unbound
- Added Unbound (klutchell/unbound, NLnetLabs) on the `dns` profile beside Pi-hole
- Pi-hole upstream set to `unbound` (private recursive resolver on the compose network; no host ports on Unbound)
- Optional LAN setup: point router DHCP DNS at the host LAN IP only while the dns profile is running

## 2026-09 — Dual-drive library expansion
- Added secondary movie/TV mounts for overflow storage on a second volume
- Kept app config on the primary volume for portability

## 2026-09 — Portable media lab v1
- Docker Compose stack with RAM-aware profiles for a gaming PC
- Docs for first-run wiring, space-saving encodes, Tailscale remote access, and host migration
- Optional profiles: requests dashboard, subtitles, music, DNS, overnight compression
