# Home Media Lab (Portfolio)

Self-hosted media stack on a dual-use Windows 11 gaming PC, designed to stay **portable** for a later move to a dedicated box.

This write-up focuses on systems work employers care about: Docker Compose, service profiles, storage layout, remote access, and documentation. Application credentials and third-party indexer details are intentionally omitted.

## Highlights

- **Docker Compose** multi-service stack with **profiles** (`core`, `requests`, `subs`, `music`, `dns`, `compress`, `dashboard`, `sync`, `full`) so the same machine can game and serve media without starting everything at once
- **Gaming Mode**: PowerShell helpers stop download/*arr/CPU-heavy containers while leaving Jellyfin + Pi-hole/Unbound up ([docs/gaming-mode.md](docs/gaming-mode.md))
- **Portable layout**: one folder (`compose`, `config`, `media`, `downloads`) with relative paths and a migrate guide
- **Storage split**: app config on a fast volume; library overflow + download scratch on a second drive ([docs/downloads-layout.md](docs/downloads-layout.md))
- **Jellyfin ops**: *arr → Jellyfin Connect for timely library updates on Docker Desktop bind mounts; plugins (Enhanced/Seerr, Intro Skipper, Media Bar)
- **Remote access plan**: Tailscale + Jellyfin `PublishedServerUrl` (no inbound port forwarding)
- **Ops extras**: Homarr dashboard, Recyclarr quality-profile sync, optional overnight library compression

## Stack (high level)

| Area | Services |
|------|----------|
| Playback / requests | Jellyfin (+ plugins), Jellyseerr |
| Automation | Sonarr, Radarr, Bazarr, Prowlarr, FlareSolverr |
| Downloads | qBittorrent (containerized) |
| DNS (optional profile) | Pi-hole + Unbound; Windows host dnsproxy for LAN :53 |
| Music (optional profile) | Lidarr (+ optional Soulseek client) |
| Compress (optional profile) | Unmanic |
| Dashboard / QoL | Homarr, Recyclarr |

## Architecture notes

```text
Gaming PC (Windows 11 + Docker Desktop / WSL2)
├── Primary volume   media-server/   # compose, config, primary media
├── Secondary volume media-server/   # overflow library + downloads
└── Tailscale on host for remote Jellyfin clients
```

- **RAM-aware**: prefer `--profile core` while gaming (~16 GB host); use Gaming Mode scripts to pause the rest
- **AMD GPU**: containerized encode is software-first; heavy re-encode kept on an idle/overnight profile
- **Migration**: pack/scripts + docs for moving the whole tree to a dedicated Linux host later

## What I did

1. Designed a profile-based Compose layout for a dual-use PC
2. Documented first-run wiring, space-saving encode preferences, and Tailscale remote access
3. Expanded library + downloads onto a second volume without moving app config
4. Built Gaming Mode on/off scripts so streaming/DNS survive game sessions
5. Fixed Jellyfin library freshness on Docker Desktop (Connect + scan safety net) and added UI plugins (Seerr-in-Jellyfin, Intro Skipper, Media Bar)
6. Coordinated ongoing hardening with a dedicated Homelab assistant workflow

## Repo contents

- Sanitized `docker-compose` / `.env.example` (no secrets)
- `bin/` Gaming Mode PowerShell helpers (relative stack root)
- Architecture and ops docs (`docs/`), including local URLs without custom router DNS
- Changelog of milestones suitable for interviews

> **Privacy:** Do not commit real `.env`, API keys, or download-client credentials.

## Status

Living project — updated as the lab evolves.
