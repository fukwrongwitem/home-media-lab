# Home Media Lab

Self-hosted Jellyfin server on my Windows 11 gaming PC, plus the DNS, networking, and remote-access work around it. The library is discs I bought and ripped myself, and home videos. The same box games and serves media, so everything is profile-based and easy to pause. The layout is meant to move to a dedicated Linux host later without redesigning the stack.

Credentials and API keys are kept out of this repo.

## What's running

| Area | Services |
|------|----------|
| Playback | Jellyfin as a native Windows service. The compose file still has a `jellyfin` service for a future Linux move |
| DNS (optional) | Pi-hole + Unbound; on Windows, a small host forwarder owns port 53 |
| Compress (optional) | Unmanic (overnight / idle only) |
| Dashboard | Homarr |
| Stats | Jellystat (Jellyfin watch history, own compose project in `jellystat/`) |
| Remote access | Tailscale on the Windows host (no inbound port forwards) |
| Notes | Obsidian vault for ops notes |

Compose profiles: `core`, `dns`, `dashboard`, `compress`, `full`.

On this PC, Jellyfin no longer runs in a container. The Windows service uses the Jellyfin port and reads the same `media/` folders the compose stack used.

## Layout

```text
Gaming PC (Windows 11 + Docker Desktop / WSL2)
├── Primary volume   media-server/   # compose, config, primary library, work scratch
├── Secondary volume                 # overflow library + rip/encode scratch
├── Jellyfin Server (native Windows service)
└── Tailscale on the host for remote Jellyfin
```

- One stack folder: compose, config, media, work scratch (relative paths where possible)
- App config for the Docker services stays on the fast drive. Library overflow and rip staging sit on a second volume
- RAM is tight while gaming. I keep the heavy profiles off, or run the Gaming Mode scripts to stop Homarr and Unmanic and leave DNS up ([gaming-mode.md](docs/gaming-mode.md)). Jellyfin keeps running either way
- Overnight (1 AM to 8 AM) scheduled tasks stop Jellyfin and the media containers and bring them back in the morning. DNS stays up ([nightly-downtime.md](docs/nightly-downtime.md))
- AMD GPU: Docker Desktop can't do hardware encode well here. I want to try AMF on the native install later ([jellyfin-native-windows.md](docs/jellyfin-native-windows.md))
- Remote: Tailscale plus the Jellyfin published URL, no inbound port forward - [tailscale.md](docs/tailscale.md)
- Getting discs into the library: [disc-ripping.md](docs/disc-ripping.md)
- Lab notes in Obsidian - [obsidian-vault.md](docs/obsidian-vault.md)

## What I built / fixed

1. Profile-based Docker Compose so the PC can game and still stream
2. First-run wiring notes, space-saving encode strategy, Tailscale remote access
3. Split the library across two volumes without moving app config
4. Gaming Mode on/off PowerShell scripts (desktop shortcuts) so streaming/DNS survive a game session
5. Jellyfin library refresh on Docker Desktop bind mounts (hourly scan + API refresh) after realtime watchers kept missing new files
6. Worked around Windows Docker Desktop fighting over DNS port 53 (Pi-hole on a loopback port + small host forwarder)
7. Jellyfin plugins: Enhanced, Intro Skipper, Media Bar
8. Obsidian vault for lean ops notes
9. Tracked down a "Jellyfin is down" report from a client app that was really DHCP lease drift on the media PC; added a DHCP reservation on the router so the address stops moving - [lan-ip-drift.md](docs/lan-ip-drift.md)
10. Disc ripping workflow for my own DVDs, Blu-rays, and CDs: lossless rip, optional HEVC encode, Jellyfin naming - [disc-ripping.md](docs/disc-ripping.md)
11. Rebuilt the lab on a new PC. Moved Jellyfin from Docker to a Windows service because it kept going down whenever I stopped Docker Desktop. Libraries stayed in the same folders ([jellyfin-native-windows.md](docs/jellyfin-native-windows.md))
12. Nightly downtime with Windows Task Scheduler: stop Jellyfin and the media containers at 1 AM, start them at 8 AM, keep DNS up, and handle a PC that was off or booted late ([nightly-downtime.md](docs/nightly-downtime.md))
13. Jellystat for Jellyfin playback history, kept as a separate memory-capped stack that talks to the native Jellyfin service ([jellystat.md](docs/jellystat.md))
14. Tuned Unbound's cache (prefetch + serve-expired) so repeat lookups come back from cache instead of a full recursive walk ([dns.md](docs/dns.md))

## Repo contents

- Sanitized `docker-compose.example.yml` and `.env.example` (no secrets)
- `bin/` - Gaming Mode helpers (Homarr and Unmanic) and the nightly downtime scripts
- `jellystat/` - example compose + `.env.example` for the stats stack
- `examples/unbound/` - Unbound cache tuning snippet
- `scripts/` - folder init and pack-for-move for migration, plus an example firewall script for the web ports
- `docs/` - ops notes (start with [wire-up.md](docs/wire-up.md), [local-access.md](docs/local-access.md), [jellyfin-users.md](docs/jellyfin-users.md))
- [CHANGELOG.md](CHANGELOG.md)

**Privacy:** don't commit a real `.env`, API keys, or admin passwords.

## Status

Active lab. Docs get updated when the stack changes.
