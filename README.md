# Home Media Lab

Self-hosted media stack on my Windows 11 gaming PC. Same box games and serves media, so everything is profile-based and easy to pause. Layout is meant to move to a dedicated Linux host later without redesigning the stack.

Credentials, API keys, and indexer details are kept out of this repo.

## What’s running

| Area | Services |
|------|----------|
| Playback / requests | Jellyfin (+ plugins), Jellyseerr |
| Automation | Sonarr, Radarr, Bazarr, Prowlarr, FlareSolverr |
| Downloads | qBittorrent (Proton/gluetun planned — qBit only) |
| DNS (optional) | Pi-hole + Unbound; on Windows, host dnsproxy owns LAN `:53` |
| Music (optional) | Lidarr (+ optional Soulseek client) |
| Compress (optional) | Unmanic (overnight / idle only) |
| Dashboard / QoL | Homarr, Recyclarr |
| Notes | Obsidian vault colocated with the stack; Local REST API via Tailscale Serve |

Compose profiles: `core`, `requests`, `subs`, `music`, `dns`, `compress`, `dashboard`, `sync`, `full` (plus a planned `vpn` profile for gluetun).

## Layout

```text
Gaming PC (Windows 11 + Docker Desktop / WSL2)
├── Primary volume   media-server/   # compose, config, primary media, Obsidian vault
├── Secondary volume media-server/   # overflow library + downloads
└── Tailscale on the host for remote Jellyfin (+ Serve for Obsidian API)
```

- One stack folder: compose, config, media, downloads (relative paths where possible)
- App config stays on the fast drive; library overflow and download scratch sit on a second volume — [downloads-layout.md](docs/downloads-layout.md)
- ~16 GB RAM: keep `--profile core` while gaming, or use Gaming Mode scripts to stop the heavy containers and leave Jellyfin + Pi-hole/Unbound up — [gaming-mode.md](docs/gaming-mode.md)
- AMD GPU: software encode in Docker for now; heavy re-encode only when idle
- Remote: Tailscale + Jellyfin `PublishedServerUrl` (no inbound port forward) — [tailscale.md](docs/tailscale.md)
- Lab notes in Obsidian next to the stack — [obsidian-vault.md](docs/obsidian-vault.md)

## What I built / fixed

1. Profile-based Docker Compose so the PC can game and still stream
2. First-run wiring notes, space-saving quality profiles, Tailscale remote access
3. Split library + downloads across two volumes without moving app config
4. Gaming Mode on/off PowerShell scripts (desktop shortcuts) so streaming/DNS survive a game session
5. Jellyfin library refresh on Docker Desktop bind mounts (Sonarr/Radarr Connect + hourly scan) after realtime watchers kept missing imports
6. Worked around Windows Docker Desktop fighting over UDP/TCP 53 (Pi-hole on loopback + host dnsproxy)
7. Jellyfin plugins: Enhanced (Seerr in the UI), Intro Skipper, Media Bar
8. Obsidian vault for lean ops notes; Local REST API reached over Tailscale Serve (tailnet only)
9. Planned Proton + gluetun kill-switch path for qBittorrent only (credentials not applied yet)
10. Sonarr `Anime-Loose` quality profile + lower size floors for short-episode anime packs

## Repo contents

- Sanitized `docker-compose.example.yml` and `.env.example` (no secrets)
- `bin/` — Gaming Mode helpers
- `scripts/` — folder init + pack-for-move for migration
- `docs/` — ops notes (start with [wire-up.md](docs/wire-up.md), [local-access.md](docs/local-access.md), [jellyfin-users.md](docs/jellyfin-users.md))
- [CHANGELOG.md](CHANGELOG.md)

**Privacy:** don’t commit a real `.env`, API keys, VPN private keys, or download-client passwords.

## Status

Active lab. Docs get updated when the stack changes.
