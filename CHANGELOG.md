# Changelog

## 2026-10-09 — Repo trimmed to Jellyfin, DNS, and remote access
- Removed download-automation services, docs, and config from the repo; it now focuses on Jellyfin, DNS, remote access, and Windows host ops
- Compose example and `.env.example` now cover Jellyfin, Pi-hole/Unbound, Homarr, and Unmanic only; `work/` replaces the old scratch folder for rip staging and encode cache
- Gaming Mode stop list reduced to match (Unmanic, Homarr)
- Kept host-specific network details (addresses, port remaps, remote-access config) out of the public docs; examples use placeholders
- Added [docs/disc-ripping.md](docs/disc-ripping.md): ripping my own DVDs, Blu-rays, and CDs into the library (MakeMKV, HandBrake, EAC/whipper, Picard, Jellyfin naming)

## 2026-10-08 — DHCP reservation for the media PC
- Reserved the media PC's address in the router's DHCP settings so client bookmarks stop chasing lease drift
- Still confirming the reservation holds after a reboot
- See [docs/lan-ip-drift.md](docs/lan-ip-drift.md)

## 2026-10-08 — Host port conflict
- Another Windows app already held a container web UI's host port, so Docker could not publish it
- Changed only the host side of the mapping; containers that use the service name were unaffected

## 2026-10-05 — LAN IP drift broke a client app
- A Jellyfin client app lost the server after the PC's DHCP lease moved twice in a day; Jellyfin itself was healthy
- Updated `JELLYFIN_PublishedServerUrl` to the current LAN IP and re-added the server in the client
- Follow-up: DHCP reservation set on the router 2026-10-08
- See [docs/lan-ip-drift.md](docs/lan-ip-drift.md)

## 2026-09-30 — Obsidian vault
- Colocated Obsidian vault under the media-server tree for lean ops notes
- See [docs/obsidian-vault.md](docs/obsidian-vault.md)

## 2026-09-29 — Household Jellyfin roles
- Documented owner admin vs non-admin household access (no passwords in repo)
- Removed a duplicate owner account from the live stack; docs match one owner + one household account
- See [docs/jellyfin-users.md](docs/jellyfin-users.md)

## 2026-09-29 — Wire-up guide + migrate scripts
- First-run wire-up order for Jellyfin, overflow roots, DNS, and Gaming Mode
- Added `scripts/init-folders.*` and `scripts/pack-for-move.*` used by the migrate docs
- Fixed broken links left from the first repo cut

## 2026-09 — Jellyfin plugins
- Installed Jellyfin Enhanced, Intro Skipper, Media Bar, File Transformation
- Notes for community plugin repos and client refresh after restart
- [docs/jellyfin-plugins.md](docs/jellyfin-plugins.md)

## 2026-09 — Gaming Mode
- PowerShell on/off scripts stop CPU-heavy containers; Jellyfin + Pi-hole/Unbound stay up
- Desktop shortcuts; state file so resume only starts what was paused
- [docs/gaming-mode.md](docs/gaming-mode.md), `bin/`

## 2026-09 — Scratch space on secondary volume
- Moved scratch/staging space to a second drive while app config stayed on the primary volume

## 2026-09 — Jellyfin library freshness (Docker Desktop)
- Realtime file watchers on Windows bind mounts kept missing new files
- Added targeted library refreshes and shortened Scan Media Library to hourly
- [docs/jellyfin-library-updates.md](docs/jellyfin-library-updates.md)

## 2026-09 — Local access without custom router DNS
- Open UIs via localhost on the server itself (Docker Desktop hairpin quirk with the host's own LAN IP)
- Homarr status pings use Docker service names
- Dashboards work with the router's default DNS; Pi-hole not required just to open Homarr

## 2026-09 — Windows Docker DNS via a host forwarder
- Pi-hole DNS bound to a non-default loopback port (Docker Desktop conflicts on port 53)
- Small DNS forwarder on the host owns port 53 and hands queries to Pi-hole
- Unbound still upstream of Pi-hole on the compose network

## 2026-09 — Recursive DNS with Unbound
- Unbound (`klutchell/unbound`) on the `dns` profile next to Pi-hole
- Pi-hole upstream set to `unbound` instead of a public resolver
- Optional: point router DHCP DNS at this host's LAN IP only while dns is running

## 2026-09 — Dual-drive library expansion
- Secondary movie/TV mounts for overflow storage
- App config stays on the primary volume

## 2026-09 — Portable media lab v1
- Docker Compose stack with RAM-aware profiles on a gaming PC
- Docs for first-run wiring, space-saving encodes, Tailscale, and host migration
- Optional profiles: DNS, dashboard, overnight compression
