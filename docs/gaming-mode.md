# Gaming Mode (homelab on a gaming PC)

Free CPU / RAM / disk / network while playing games, without stopping house streaming or DNS.

Compose project: `home-media-server`  
Profiles: `core`, `requests`, `dns`, `subs`, `music`, `compress`, `dashboard`, `sync`, `full`

Scripts live under `bin/` next to `docker-compose.yml` (relative stack root).

## What stays up

| Service | Why |
|---------|-----|
| **jellyfin** | House media playback |
| **pihole** + **unbound** | LAN / local DNS (ads + recursive) |

## What gets stopped

| Service | Why pause |
|---------|-----------|
| qbittorrent | Downloads / torrents |
| sonarr, radarr, prowlarr | *arr polling + grabs |
| flaresolverr | Prowlarr helper |
| jellyseerr | Requests UI |
| bazarr | Subtitle work |
| lidarr, nicotine-plus | Music / Soulseek |
| unmanic | HEVC re-encode (CPU-heavy) |
| recyclarr | Profile sync (not needed live) |
| homarr | Dashboard (light, but frees a bit of RAM) |

Containers are **stopped**, not removed. Config and downloads stay on disk.

## Desktop shortcuts

| Shortcut | Script | Action |
|----------|--------|--------|
| Homelab Gaming Mode | `bin/gaming-mode-on.ps1` | Stop heavy list; leave Jellyfin + DNS |
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
docker compose stop qbittorrent sonarr radarr prowlarr flaresolverr jellyseerr bazarr lidarr nicotine-plus unmanic recyclarr homarr

# Gaming OFF (start existing containers)
docker compose start qbittorrent sonarr radarr prowlarr flaresolverr jellyseerr bazarr lidarr nicotine-plus unmanic recyclarr homarr
```

If a container was **removed** (not just stopped), recreate with profiles, e.g.:

```powershell
docker compose --profile core --profile requests --profile dns --profile dashboard --profile subs up -d
```

## Notes

- Prefer this over `docker compose --profile full stop`, which would also stop Jellyfin and Pi-hole.
- Unmanic / nicotine-plus are especially bad while gaming on ~16 GB RAM — keep them in the stop list.
- After Resume, give *arr a minute to reconnect to qBittorrent.
