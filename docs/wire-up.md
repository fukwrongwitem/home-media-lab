# First-run wire-up order

Configure things in this order. Containers reach each other by name on the Docker network `media` (e.g. `http://jellyfin:8096` from Homarr). From a browser on the Docker host, use `http://localhost:<port>`.

## 0. Prerequisites

- Docker Engine running (Docker Desktop + WSL2 on Windows, or Docker on Linux)
- `.env` created from `.env.example` (paths like `./config` are relative to the stack root — see [migrate.md](migrate.md))
- Folders created (`scripts/init-folders.ps1` or `scripts/init-folders.sh`)
- Core stack up: `docker compose --profile core up -d`

## 1. Jellyfin (localhost:8096) — profile `core`

1. Create the admin user.
2. Add libraries:
   - Movies → `/media/movies` (and `/media/movies2` if overflow is mounted)
   - Shows → `/media/tv` (and `/media/tv2` if overflow is mounted)
   - Music → `/media/music`
   - Home videos → `/media/home-videos` (library type "Home Videos and Photos")
3. **Transcoding:** on AMD + Docker Desktop Windows, start with **software** encoding. Hardware AMF via Docker Desktop is limited; for HW encode consider native Windows Jellyfin.
4. Set `JELLYFIN_PublishedServerUrl` for LAN/Tailscale clients — see [tailscale.md](tailscale.md).
5. Library refresh on Docker Desktop bind mounts is unreliable; see [jellyfin-library-updates.md](jellyfin-library-updates.md).
6. File and folder naming for new rips: [disc-ripping.md](disc-ripping.md).

## 2. Household users

Owner admin plus non-admin household accounts — [jellyfin-users.md](jellyfin-users.md).

## 3. Plugins

Enhanced, Intro Skipper, Media Bar — [jellyfin-plugins.md](jellyfin-plugins.md).

## 4. Pi-hole + Unbound — profile `dns` or `full`

1. Open the admin UI at `http://localhost:<PIHOLE_WEB_PORT>/admin` (password from `.env` `PIHOLE_PASSWORD`).
2. On Windows Docker Desktop, use the loopback + host forwarder pattern in [dns.md](dns.md) instead of publishing container port 53 to the LAN.
3. Point router LAN DHCP DNS at this host's LAN IP only while the dns profile (and host forwarder, if used) are running.
4. **Dual-use / gaming:** stop the dns profile or restore the router's default DNS before competitive play / VPN if you hit conflicts. Gaming Mode leaves Pi-hole/Unbound up — see [gaming-mode.md](gaming-mode.md).

```powershell
docker compose --profile dns up -d
# pause DNS profile when needed:
docker compose stop pihole unbound
```

## 5. Homarr — profile `dashboard` or `full`

1. Set `HOMARR_SECRET_ENCRYPTION_KEY` in `.env` first (`openssl rand -hex 32`).
2. Add tiles for Jellyfin, Pi-hole, and Unmanic. Links use `localhost`; status pings use Docker service names — see [local-access.md](local-access.md).

## 6. Remote access

Tailscale on the Windows host; no router port forwards — [tailscale.md](tailscale.md).

## 7. Optional Unmanic — profile `compress` (SSD shrink)

Only for older library files that are still oversized. For new rips I encode with HandBrake before they go into the library ([space-saving.md](space-saving.md)).

1. Start when **not gaming**: `docker compose --profile compress up -d`
2. Open the Unmanic UI (`http://localhost:<UNMANIC_PORT>`) — point the library at `/library` (already bound to `MEDIA_ROOT`).
3. Configure HEVC convert; use **1 worker** on a ~16 GB gaming PC; stop Unmanic before gaming (or use Gaming Mode).

## Quick health checklist

```powershell
docker compose --profile full ps
docker compose --profile core logs --tail=50
```

Browser smoke test: open Jellyfin, the Pi-hole admin page, and Homarr on their `.env` ports.
