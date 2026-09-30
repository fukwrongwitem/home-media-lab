# Proton VPN for qBittorrent only (planned)

**Status:** plan only — live compose still runs qBittorrent on the `media` bridge. Do not bring a VPN profile up until WireGuard (or OpenVPN) credentials exist in `.env` / a secrets file that stays out of git.

**Scope:** qBittorrent traffic only. Jellyfin, Homarr, Pi-hole, and the *arr stack stay on `media` / LAN.

## Why

Hide the ISP IP on torrent traffic without shoving the whole media stack through a VPN. Kill switch: if the VPN container dies, qBit should lose network.

## Target design

1. Add **gluetun** (Proton) with `cap_add: NET_ADMIN` and `/dev/net/tun`.
2. Move **qbittorrent** to `network_mode: "service:gluetun"`.
3. Publish the qBit WebUI (and BT listen if needed) on **gluetun**, not on qbit.
4. Prefer **WireGuard + port forwarding** (`VPN_PORT_FORWARDING=on`, `PORT_FORWARD_ONLY=on`).
5. Allow gluetun → LAN so *arr can still reach the WebUI: `FIREWALL_OUTBOUND_SUBNETS=<your-lan-cidr>`.
6. Keep jellyfin / homarr / pihole / *arr on **`media`**.

**Docker Desktop / Windows:** `/dev/net/tun` must exist inside the Linux VM (WSL2). If gluetun cannot create tun, fix Docker Desktop / WSL tun access before fighting compose.

## Env vars (never commit real values)

WireGuard (preferred):

| Variable | Notes |
|----------|--------|
| `VPN_SERVICE_PROVIDER=protonvpn` | literal |
| `VPN_TYPE=wireguard` | literal |
| `WIREGUARD_PRIVATE_KEY` | from Proton → VPN → WireGuard (enable NAT-PMP / port forward when generating) |
| `SERVER_COUNTRIES` | optional, e.g. a P2P-friendly country |
| `VPN_PORT_FORWARDING=on` | recommended for torrents |
| `PORT_FORWARD_ONLY=on` | only port-forward capable servers |
| `FIREWALL_OUTBOUND_SUBNETS` | your LAN CIDR so *arr can reach WebUI |

OpenVPN fallback uses Proton’s OpenVPN username/password (not account email); append `+pmp` on the username when you want port forward.

Stub for `.env` (fill later, leave commented until ready):

```env
# VPN_SERVER_COUNTRIES=Netherlands
# VPN_LAN_SUBNET=192.168.x.0/24
# WIREGUARD_PRIVATE_KEY=
```

## Draft compose shape (profile `vpn`)

Not merged into the live file yet. When credentials exist:

```yaml
services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    profiles: ["vpn"]
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - TZ=${TZ:-America/Los_Angeles}
      - VPN_SERVICE_PROVIDER=protonvpn
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY:?set in .env}
      - SERVER_COUNTRIES=${VPN_SERVER_COUNTRIES:-Netherlands}
      - VPN_PORT_FORWARDING=on
      - PORT_FORWARD_ONLY=on
      - FIREWALL_OUTBOUND_SUBNETS=${VPN_LAN_SUBNET:-192.168.0.0/24}
    ports:
      - "${QBIT_WEBUI_PORT:-8080}:8080"
    volumes:
      - ${CONFIG_ROOT}/gluetun:/gluetun
    networks:
      - media
    restart: unless-stopped

  # qbittorrent then uses:
  #   network_mode: "service:gluetun"
  #   depends_on: [gluetun]
  #   (no ports: / no networks: on qbit itself)
```

## Activation checklist (later)

1. Put WireGuard private key (or OpenVPN user/pass) in `.env` — never in this repo.
2. Create `config/gluetun`.
3. Merge gluetun + switch qbit to `network_mode: "service:gluetun"`; drop qbit `ports`/`networks`.
4. In qBit WebUI, allow localhost auth bypass if you use gluetun’s port-forward up-command.
5. `docker compose --profile core --profile vpn up -d gluetun qbittorrent`
6. Confirm WebUI on `:8080`, external IP inside qbit ≠ home IP, and `docker stop gluetun` kills qbit’s net.
7. Confirm Sonarr/Radarr download clients still reach the published WebUI.

## References

- [Gluetun ProtonVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md)
- [VPN port forwarding](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md)
