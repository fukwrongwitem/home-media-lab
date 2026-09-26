# DNS profile (Pi-hole + Unbound)

Optional profile: `dns` (also included in `full`).

## Layout

- **Pi-hole** — ad/tracker blocking; web UI on host port `8053` (configurable). DNS is published **only** on `127.0.0.1:5053` (not LAN `:53`).
- **Unbound** (`klutchell/unbound`) — recursive resolver on the compose network only (no host ports). Pi-hole upstream is `unbound` instead of a public resolver.
- **Host dnsproxy** (Windows) — AdGuard `dnsproxy` listens on the host’s LAN `:53` and forwards to `127.0.0.1:5053`, so Docker never needs to own UDP/TCP 53.

## Why the Windows workaround

On Windows with Docker Desktop, publishing container ports `53/tcp` and `53/udp` often fails or fights with Internet Connection Sharing (ICS), Hyper-V, or other host DNS listeners. Binding Pi-hole to loopback `:5053` and putting a thin host forwarder on `:53` avoids that conflict while still serving the LAN.

Typical companion host setup (documented here for portfolio context; exact install paths vary):

1. Enable WSL2 mirrored networking in `.wslconfig` when needed for consistent host/LAN behavior with Docker Desktop.
2. Set the Ethernet profile to **Private** and allow DNS (UDP/TCP 53) in the Windows firewall for the private profile.
3. Install AdGuard `dnsproxy` and run it at login/startup (example task name: `PiHoleDnsProxy`) forwarding to `127.0.0.1:5053`.
4. Point the router’s LAN DHCP DNS at this machine’s LAN IP (example lab host: `192.168.4.42`) **only while** dnsproxy and the `dns` profile are running.

On a dedicated Linux host later, you can often publish Pi-hole on `:53` directly and drop the host forwarder.

## Ops notes

- On a dual-use gaming PC, stop the `dns` profile (and dnsproxy) or restore ISP DNS before competitive play / VPN if you hit DNS conflicts.
- Do not commit real Pi-hole admin passwords; use `.env` locally.
