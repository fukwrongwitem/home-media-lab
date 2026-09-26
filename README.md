# Home Media Lab (Portfolio)

Self-hosted media stack on a dual-use Windows 11 gaming PC, designed to stay **portable** for a later move to a dedicated box.

This write-up focuses on systems work employers care about: Docker Compose, service profiles, storage layout, remote access, and documentation. Application credentials and third-party indexer details are intentionally omitted.

## Highlights

- **Docker Compose** multi-service stack with **profiles** (`core`, `requests`, `subs`, `music`, `dns`, `compress`, `full`) so the same machine can game and serve media without starting everything at once
- **Portable layout**: one folder (`compose`, `config`, `media`, `downloads`) with relative paths and a migrate guide
- **Storage split**: app config on a fast volume; bulk library growth on a second drive with secondary mounts into Jellyfin / Sonarr / Radarr
- **Remote access plan**: Tailscale + Jellyfin `PublishedServerUrl` (no inbound port forwarding)
- **Ops extras (in progress)**: dashboard (Homarr), quality-profile sync (Recyclarr), optional overnight library compression

## Stack (high level)

| Area | Services |
|------|----------|
| Playback / requests | Jellyfin, Jellyseerr |
| Automation | Sonarr, Radarr, Bazarr, Prowlarr, FlareSolverr |
| Downloads | qBittorrent (containerized) |
| DNS (optional profile) | Pi-hole + Unbound; Windows host dnsproxy for LAN :53 |
| Music (optional profile) | Lidarr (+ optional Soulseek client) |
| Compress (optional profile) | Unmanic |
| Dashboard / QoL | Homarr, Recyclarr |

## Architecture notes

```text
Gaming PC (Windows 11 + Docker Desktop / WSL2)
├── D:  media-server/     # compose, config, primary media, downloads
└── E:  media-server/     # overflow movies / tv library mounts
        └─ Tailscale host for remote clients
```

- **RAM-aware**: prefer `--profile core` while gaming (~16 GB host)
- **AMD GPU**: containerized encode is software-first; heavy re-encode kept on an idle/overnight profile
- **Migration**: pack/scripts + docs for moving the whole tree to a dedicated Linux host later

## What I did

1. Designed a profile-based Compose layout for a dual-use PC
2. Documented first-run wiring, space-saving encode preferences, and Tailscale remote access
3. Expanded library storage onto a second volume without moving app config
4. Coordinated ongoing hardening (dashboard, profile sync, backups) with a dedicated Homelab assistant workflow

## Repo contents

- Sanitized `docker-compose` / `.env.example` (no secrets)
- Architecture and ops docs (`docs/`)
- Changelog of milestones suitable for interviews

> **Privacy:** Do not commit real `.env`, API keys, or download-client credentials.

## Status

Living project — updated as the lab evolves.
