# DNS profile (Pi-hole + Unbound)

Optional profile: `dns` (also included in `full`).

## Layout

- **Pi-hole** — ad/tracker blocking; publishes DNS (host port 53 by default) and a web UI
- **Unbound** (`klutchell/unbound`) — recursive resolver on the compose network only (no host ports). Pi-hole upstream is `unbound` instead of a public resolver

## LAN use

Point the router’s LAN DHCP DNS at this machine’s LAN IP **only while** the dns profile is running. On dual-use gaming PCs, stop the profile (or restore ISP DNS) before competitive play / VPN if you hit DNS conflicts. Publishing port 53 can also conflict with Windows / Hyper-V DNS.

Do not commit real Pi-hole admin passwords; use `.env` locally.
