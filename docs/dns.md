# DNS profile (Pi-hole + Unbound)

Optional profile: `dns` (also included in `full`).

## What each piece does

- **Pi-hole** — ad and telemetry blocking for the LAN, with a web admin UI.
- **Unbound** (`klutchell/unbound`) — recursive resolver on the compose network only (no host ports). Pi-hole uses the `unbound` service as its upstream instead of a public resolver, so lookups go straight to the authoritative servers.
- **Small host-side DNS forwarder** (Windows only) — listens on the host's port 53 and hands queries to Pi-hole.

## Why the Windows workaround

On Windows with Docker Desktop, publishing a container on port 53 (TCP/UDP) often fails or fights with other DNS listeners on the host (Hyper-V, Docker Desktop's own DNS, sharing features). What worked for me:

1. Publish Pi-hole's DNS only on loopback, on a **non-default local port** (`PIHOLE_DNS_BIND` / `PIHOLE_DNS_PORT` in `.env`).
2. Run a lightweight DNS forwarder on the host (I used AdGuard's `dnsproxy`) that owns port 53 and forwards to that loopback port. Start it at login so it survives reboots.
3. Allow inbound DNS on the host firewall for the LAN only.
4. Point the router's DHCP DNS setting at `<server-lan-ip>` **only while** the forwarder and the `dns` profile are running.

On a dedicated Linux host later, Pi-hole can usually publish 53 directly and the forwarder goes away.

## Ops notes

- On a dual-use gaming PC, stop the `dns` profile (and the forwarder) or put the router back on its default DNS before competitive play / VPN if you hit DNS conflicts. If the PC is off, anything pointed at it for DNS stops resolving, so keep a fallback in mind.
- Do not commit real Pi-hole admin passwords; use `.env` locally.
