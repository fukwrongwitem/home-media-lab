# First-run wire-up order

Configure apps in this order. Use container names as hostnames on the Docker network `media` (e.g. `http://qbittorrent:8080` from Sonarr). From your browser on the Docker host, use `http://localhost:<port>`.

**No piracy guidance here** — only paths, download client, and service links.

## 0. Prerequisites

- Docker Engine running (Docker Desktop + WSL2 on Windows, or Docker on Linux)
- `.env` created from `.env.example` (paths like `./config` are relative to the stack root — see [migrate.md](migrate.md))
- Folders created (`scripts/init-folders.ps1` or `scripts/init-folders.sh`)
- Core stack up: `docker compose --profile core up -d`

## 1. Prowlarr (localhost:9696)

1. Complete the setup wizard; set authentication.
2. Add indexers you are authorized to use (your accounts / legal sources only).
3. Later (step 7): add FlareSolverr as a proxy where an indexer needs it:
   - Tag or proxy URL: `http://flaresolverr:8191`
4. After Sonarr/Radarr/Lidarr exist: **Settings → Apps** → add each *arr using API keys (or Prowlarr's sync).

## 2. qBittorrent (localhost:8080)

1. Log in (linuxserver image prints a temporary password in logs on first run — check `docker compose logs qbittorrent`).
2. Set a strong password.
3. **Downloads:**
   - Default save path: `/downloads/complete`
   - Keep incomplete in `/downloads/incomplete` (enable incomplete folder if desired)
4. Note Web UI host/port for *arr: from other containers use:
   - Host: `qbittorrent`
   - Port: `8080`
5. Optional: categories `tv`, `movies`, `music` matching Sonarr/Radarr/Lidarr.

## 3. Sonarr / Radarr / Lidarr

### Sonarr (localhost:8989) — profile `core`

1. **Media Management → Root Folders:** `/tv` (bind of `MEDIA_ROOT/tv`). Add `/tv2` if using overflow storage.
2. **Download Clients → qBittorrent:** server `qbittorrent`, port `8080`, category e.g. `tv`.
3. **Connect** to Prowlarr (or add indexers via Prowlarr sync).
4. Match paths so completed downloads hardlink/move from `/downloads` into `/tv`.
5. **Space-saving (do this before adding shows):** create/import a quality profile that prefers **x265/HEVC** (and WEBDL/WEBRIP), caps at **720p–1080p**, and rejects or deprioritizes **Remux**. Details: [space-saving.md](space-saving.md).

### Radarr (localhost:7878) — profile `core`

1. Root folder: `/movies` (and `/movies2` for overflow if used)
2. Download client: `qbittorrent:8080`, category e.g. `movies`
3. Sync with Prowlarr
4. **Space-saving (do this before adding movies):** same idea — prefer **1080p x265/HEVC**, boost WEB encodes, block/deprioritize **Remux** so the SSD is not filled with huge files. See [space-saving.md](space-saving.md).

### Lidarr (localhost:8686) — profile `music` or `full`

1. Root folder: `/music`
2. Download client: `qbittorrent:8080`, category e.g. `music`
3. Sync with Prowlarr
4. For Soulseek grabs via Nicotine+: download into `/data/downloads` (host: `downloads/complete/soulseek`), then move/organize into `/music` for Lidarr/Jellyfin libraries

## 4. Bazarr (localhost:6767) — profile `subs` or `full`

1. Add Sonarr + Radarr (URLs `http://sonarr:8989`, `http://radarr:7878`) with API keys.
2. Point movie/TV paths at `/movies` and `/tv` (same binds as *arr).
3. Enable providers you are allowed to use; set languages.

## 5. Jellyseerr (localhost:5055) — profile `requests` or `full`

1. Sign in / create admin.
2. Connect **Jellyfin**: URL `http://jellyfin:8096` or `http://host.docker.internal:8096` if needed.
3. Connect **Sonarr** and **Radarr** with API keys and correct root folders/quality profiles.
4. Set default request permissions.

## 6. Jellyfin libraries (localhost:8096) — profile `core`

1. Create admin user.
2. Add libraries:
   - Movies → `/media/movies` (and `/media/movies2` if overflow is mounted)
   - TV → `/media/tv` (and `/media/tv2` if overflow is mounted)
   - Music → `/media/music`
3. **Transcoding:** on AMD + Docker Desktop Windows, start with **software** encoding. Hardware AMF via Docker Desktop is limited; for HW encode consider native Windows Jellyfin.
4. Optional: set `JELLYFIN_PublishedServerUrl` for LAN/Tailscale clients — see [tailscale.md](tailscale.md).
5. For timely library updates after *arr imports on Docker Desktop bind mounts, see [jellyfin-library-updates.md](jellyfin-library-updates.md).

## 7. FlareSolverr in Prowlarr

1. Confirm FlareSolverr: `http://localhost:8191` (health).
2. In Prowlarr: **Settings → Indexers → Proxy** (or per-indexer):
   - FlareSolverr URL: `http://flaresolverr:8191`
3. Attach the proxy only to indexers that need Cloudflare challenge solving.

## 8. Pi-hole + Unbound — profile `dns` or `full`

1. Open admin UI: `http://localhost:8053/admin` (password from `.env` `PIHOLE_PASSWORD`).
2. On Windows Docker Desktop, prefer the loopback `:5053` + host dnsproxy pattern described in [dns.md](dns.md) instead of publishing container `:53` to the LAN.
3. Point router LAN DHCP DNS at this host's LAN IP only while the dns profile (and host forwarder, if used) are running.
4. **Dual-use / gaming:** stop the dns profile or restore ISP DNS before competitive play / VPN if you hit conflicts. Gaming Mode leaves Pi-hole/Unbound up when you only need to free download/*arr CPU — see [gaming-mode.md](gaming-mode.md).

```powershell
docker compose --profile dns up -d
# pause DNS profile when needed:
docker compose stop pihole unbound
```

## 9. Optional Unmanic — profile `compress` (SSD shrink)

Only if you already have oversized library files. Prefer space-saving *arr profiles first ([space-saving.md](space-saving.md)).

1. Start when **not gaming**: `docker compose --profile compress up -d`
2. Open `http://localhost:8888` — point library at `/library` (already bound to `MEDIA_ROOT`).
3. Configure HEVC convert; use **1 worker** on a ~16 GB gaming PC; stop Unmanic before gaming (or use Gaming Mode).

## Quick health checklist

```powershell
docker compose --profile core ps
docker compose --profile core logs --tail=50
```

Browser smoke test: Jellyfin :8096, qBittorrent :8080, Prowlarr :9696, Sonarr :8989, Radarr :7878.

## Suggested "next" after wire-up

- Add Jellyseerr when family requests matter (`--profile requests`)
- Add Bazarr when you want automated subs (`--profile subs`)
- Add Lidarr + Nicotine+ when building music (`--profile music`)
- Add Pi-hole + Unbound only after you accept Windows DNS / gaming tradeoffs (`--profile dns`) — see [dns.md](dns.md)
- Add Unmanic only for leftover oversized files, when idle (`--profile compress`) — see [space-saving.md](space-saving.md)
- Use Gaming Mode scripts when playing games on the same PC — see [gaming-mode.md](gaming-mode.md)
