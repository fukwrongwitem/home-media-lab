# Local access (no custom router DNS)

Router LAN DNS can stay on ISP defaults. Open dashboards by IP/localhost — do not rely on Pi-hole hostnames.

## Primary (this PC)

| App | URL |
|-----|-----|
| **Homarr (dashboard)** | http://127.0.0.1:7575 |
| Jellyfin | http://127.0.0.1:8096 |
| Jellyseerr | http://127.0.0.1:5055 |
| Sonarr | http://127.0.0.1:8989 |
| Radarr | http://127.0.0.1:7878 |
| Prowlarr | http://127.0.0.1:9696 |
| Bazarr | http://127.0.0.1:6767 |
| qBittorrent | http://127.0.0.1:8080 |
| Pi-hole admin | http://127.0.0.1:8053/admin |
| FlareSolverr | http://127.0.0.1:8191 |

Bookmark **http://127.0.0.1:7575** as the home dashboard.

## Other devices on LAN

Use `http://192.168.4.42:<port>` (same ports). From *this* Windows host, `192.168.4.42` often hangs (Docker Desktop hairpin) — prefer `127.0.0.1` on the media PC itself.

## DNS note (informational)

- System DNS: ISP (router default) — expected.
- dnsproxy + Pi-hole still run locally (127.0.0.1:5053 / web :8053) but are **not required** for Homarr.
- Do not change router DNS for dashboard access.

Homarr tile **hrefs** stay `localhost` (correct when browsing on this PC). Tile **ping** URLs use Docker service names so status lights work inside the container network.
