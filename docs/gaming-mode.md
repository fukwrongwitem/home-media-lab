# Gaming Mode

Frees CPU, RAM, disk, and network while I game, without killing house streaming or DNS.

Compose project: `home-media-server`  
Profiles: `core`, `dns`, `dashboard`, `compress`, `full`

Scripts live under `bin/` next to `docker-compose.yml` (relative stack root).

## What stays up

| Service | Why |
|---------|-----|
| **Jellyfin (Windows service)** | House media playback. It is not a container on this PC ([jellyfin-native-windows.md](jellyfin-native-windows.md)) |
| **pihole** + **unbound** | LAN / local DNS (ads + recursive) |

If I ran the compose `jellyfin` service instead, it would go on the keep-running list too.

## What gets stopped

| Service | Why pause |
|---------|-----------|
| unmanic | HEVC re-encode (CPU-heavy) |
| homarr | Dashboard (light, but frees a bit of RAM) |

Containers are **stopped**, not removed. Config and media stay on disk.

One thing the scripts can't pause: a HandBrake encode or a disc rip running on the host. I don't start those before a game session ([disc-ripping.md](disc-ripping.md)).

## Desktop shortcuts

| Shortcut | Script | Action |
|----------|--------|--------|
| Homelab Gaming Mode | `bin/gaming-mode-on.ps1` | Stop the heavy list; leave DNS and Jellyfin up |
| Homelab Resume | `bin/gaming-mode-off.ps1` | Start what Gaming Mode stopped |

Both wait for **Docker Desktop** / the engine (`docker info`) before running compose. Recreate shortcuts anytime:

```powershell
cd <STACK_ROOT>
.\bin\create-gaming-mode-shortcuts.ps1
```

## CLI

```powershell
cd <STACK_ROOT>

# Dry / preview
.\bin\gaming-mode-on.ps1 -DryRun -NoPause
.\bin\gaming-mode-off.ps1 -DryRun -NoPause

# Real
.\bin\gaming-mode-on.ps1 -NoPause
.\bin\gaming-mode-off.ps1 -NoPause
```

`-NoPause` skips the “Press Enter to close” prompt (useful for automation). Desktop shortcuts omit `-NoPause` so a window stays open with status.

State of what was stopped is written to `bin/.gaming-mode-state.json` and cleared on resume.

## Manual compose equivalents

```powershell
cd <STACK_ROOT>

# Gaming ON (example)
docker compose stop unmanic homarr

# Gaming OFF (start existing containers)
docker compose start unmanic homarr
```

If a container was **removed** (not just stopped), recreate with profiles, e.g.:

```powershell
docker compose --profile dns --profile dashboard up -d
```

## Notes

- Prefer this over `docker compose --profile full stop`, which would also stop Pi-hole.
- Unmanic is especially bad while gaming on ~16 GB RAM - keep it in the stop list.
- Jellyfin does not show up in `docker compose ps` anymore. If playback is down, I check Services for `JellyfinServer`.
- Overnight shutdown is a separate pair of scheduled tasks ([nightly-downtime.md](nightly-downtime.md)). Gaming Mode OFF and downtime end start the same containers, so they don't step on each other.
