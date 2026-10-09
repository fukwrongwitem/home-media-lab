# Home Media Lab

Self-hosted Jellyfin server on my Windows 11 gaming PC, plus the DNS, networking, and remote-access work around it. The library is discs I bought and ripped myself, and home videos. The same box games and serves media, so everything is profile-based and easy to pause. The layout is meant to move to a dedicated Linux host later without redesigning the stack.

Credentials and API keys are kept out of this repo.

## What's running

| Area | Services |
|------|----------|
| Playback | Jellyfin (+ plugins) |
| DNS (optional) | Pi-hole + Unbound; on Windows, a small host forwarder owns port 53 |
| Compress (optional) | Unmanic (overnight / idle only) |
| Dashboard | Homarr |
| Remote access | Tailscale on the Windows host (no inbound port forwards) |
| Notes | Obsidian vault colocated with the stack |

Compose profiles: `core`, `dns`, `dashboard`, `compress`, `full`.

## Layout

```text
Gaming PC (Windows 11 + Docker Desktop / WSL2)
├── Primary volume   media-server/   # compose, config, primary library, Obsidian vault
├── Secondary volume media-server/   # overflow library + rip/encode scratch
└── Tailscale on the host for remote Jellyfin
```

- One stack folder: compose, config, media, work scratch (relative paths where possible)
- App config stays on the fast drive; library overflow and rip staging sit on a second volume
- ~16 GB RAM: keep `--profile core` while gaming, or use Gaming Mode scripts to stop the heavy containers and leave Jellyfin + Pi-hole/Unbound up — [gaming-mode.md](docs/gaming-mode.md)
- AMD GPU: software encode in Docker for now; heavy re-encode only when idle
- Remote: Tailscale + Jellyfin `PublishedServerUrl` (no inbound port forward) — [tailscale.md](docs/tailscale.md)
- Getting discs into the library: [disc-ripping.md](docs/disc-ripping.md)
- Lab notes in Obsidian next to the stack — [obsidian-vault.md](docs/obsidian-vault.md)

## What I built / fixed

1. Profile-based Docker Compose so the PC can game and still stream
2. First-run wiring notes, space-saving encode strategy, Tailscale remote access
3. Split the library across two volumes without moving app config
4. Gaming Mode on/off PowerShell scripts (desktop shortcuts) so streaming/DNS survive a game session
5. Jellyfin library refresh on Docker Desktop bind mounts (hourly scan + API refresh) after realtime watchers kept missing new files
6. Worked around Windows Docker Desktop fighting over DNS port 53 (Pi-hole on a loopback port + small host forwarder)
7. Jellyfin plugins: Enhanced, Intro Skipper, Media Bar
8. Obsidian vault for lean ops notes, kept next to the stack so backups include the runbooks
9. Tracked down a "Jellyfin is down" report from a client app that was really DHCP lease drift on the media PC; added a DHCP reservation on the router so the address stops moving — [lan-ip-drift.md](docs/lan-ip-drift.md)
10. Disc ripping workflow for my own DVDs, Blu-rays, and CDs: lossless rip, optional HEVC encode, Jellyfin naming — [disc-ripping.md](docs/disc-ripping.md)

## Repo contents

- Sanitized `docker-compose.example.yml` and `.env.example` (no secrets)
- `bin/` — Gaming Mode helpers
- `scripts/` — folder init + pack-for-move for migration
- `docs/` — ops notes (start with [wire-up.md](docs/wire-up.md), [local-access.md](docs/local-access.md), [jellyfin-users.md](docs/jellyfin-users.md))
- [CHANGELOG.md](CHANGELOG.md)

**Privacy:** don't commit a real `.env`, API keys, or admin passwords.

## Status

Active lab. Docs get updated when the stack changes.
