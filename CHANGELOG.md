# Changelog

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
