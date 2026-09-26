# Migrating this stack to another machine

This project is a **single portable folder**. Compose, config, media, and downloads all live under one root. To move hosts, copy that folder (or use `scripts/pack-for-move.*`) and bring Docker back up.

## What's portable

| Include | Why |
|---------|-----|
| `docker-compose.yml`, `.env` / `.env.example`, `scripts/`, `docs/`, `README.md` | Stack definition |
| `config/` | App databases, settings, API keys, Pi-hole lists |
| `media/` | Library files (movies / tv / music) |
| `downloads/` | Completed (and optionally incomplete) downloads |

Paths in `.env` default to **relative** values (`./config`, `./media`, `./downloads`). Docker Compose resolves them relative to the compose file directory, so the stack moves with the folder.

Internal Docker hostnames (`qbittorrent`, `sonarr`, `radarr`, …) do **not** change when you move machines.

## Gaming PC → dedicated Linux box

1. On the old host: stop the stack  
   `docker compose --profile full down`
2. Copy the whole stack root (rsync, `pack-for-move`, USB, etc.):  
   `rsync -aH --info=progress2 ./media-server/ user@newhost:/opt/media-server/`  
   Or: `./scripts/pack-for-move.sh --include-media` then extract on the new host.
3. On the new host: install Docker Engine + Compose plugin.
4. Edit `.env`:
   - Set `PUID` / `PGID` to the Linux user that owns the folder (`id -u` / `id -g`)
   - Set `TZ` if needed
   - Keep relative paths unless you intentionally override `MEDIA_ROOT`
5. From the stack root:  
   `docker compose --profile core up -d`  
   (use `full` or extra profiles when ready)
6. Update host-specific settings (see below), including Tailscale `JELLYFIN_PublishedServerUrl` — [tailscale.md](tailscale.md).

## Gaming PC → another Windows box

1. Stop the stack on the old PC.
2. Copy the whole folder (e.g. to `D:\media-server`).
3. Install **WSL2** + **Docker Desktop** (WSL2 backend) on the new PC.
4. Keep relative `.env` paths, or set absolute `D:/media-server/...` overrides if you prefer.
5. From the stack root in PowerShell:  
   `docker compose --profile core up -d`
6. Update host-specific settings (see below).

Helper scripts:

```powershell
.\scripts\pack-for-move.ps1 -SkipIncomplete              # config + downloads/complete
.\scripts\pack-for-move.ps1 -IncludeMedia -SkipIncomplete  # + media library
```

```bash
./scripts/pack-for-move.sh --skip-incomplete
./scripts/pack-for-move.sh --include-media --skip-incomplete
```

## What to change on the new host

- **Jellyfin** Published Server URL → new LAN IP (`http://NEW_LAN_IP:8096`)
- **Pi-hole** → point router DNS at the **new** machine’s LAN IP (only while Pi-hole is running)
- **Firewall** → allow the ports you expose (8096, 8080, 53, etc.) on the new host
- **PUID / PGID / TZ** in `.env` for Linux ownership and timezone
- Any bookmarks or LAN clients that used the old IP

## What NOT to change

- Internal Docker service hostnames: `qbittorrent`, `prowlarr`, `sonarr`, `radarr`, `jellyfin`, `flaresolverr`, etc.
- In-container paths (`/downloads`, `/tv`, `/movies`, `/music`, `/media/...`) — bind mounts already map them
- Compose service names and the `media` network name (unless you intentionally redesign)

## Optional: media on a separate drive later

Keep config + compose on the stack root; point only the library elsewhere:

```env
CONFIG_ROOT=./config
DOWNLOADS_ROOT=./downloads
MEDIA_ROOT=E:/media
# Linux example:
# MEDIA_ROOT=/mnt/storage/media
```

Config and app settings stay portable; only the media bind target changes. Re-run or re-create library folders on that drive as needed.

## After migrate checklist

1. `docker compose --profile core ps` — healthy
2. Open Jellyfin / qBittorrent / Prowlarr on localhost ports
3. Confirm *arr still reach `qbittorrent:8080` and Prowlarr
4. Update Jellyfin published URL + Pi-hole router DNS if used
5. See [wire-up.md](wire-up.md) if anything needs re-linking
