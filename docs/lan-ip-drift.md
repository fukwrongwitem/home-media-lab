# LAN IP drift broke a client app

## What broke

A Jellyfin client app on the LAN stopped connecting one afternoon. Jellyfin itself was fine (local playback on the PC worked, container healthy). The media PC is wired with a plain DHCP lease, and over one day the lease changed twice. The client still had the old address saved, and `JELLYFIN_PublishedServerUrl` was still pointing at the old address too.

## Fix

1. Check the PC's current IPv4 address first (`ipconfig` on the host) before touching firewall rules or Jellyfin bind settings.
2. Update `JELLYFIN_PublishedServerUrl` in `.env` to `http://<server-lan-ip>:<JELLYFIN_PORT>` and recreate the Jellyfin container.
3. In the client app, remove the old server entry and add `http://<server-lan-ip>:<JELLYFIN_PORT>`.

## Long-term

- Added a DHCP reservation for the media PC in the router's app so it always gets the same address.
- After the next reboot or lease renewal, confirm the host still lands on the reserved address, and keep `JELLYFIN_PublishedServerUrl` and any client bookmarks matching it.
- Until the reservation has held through a reboot, treat "a client can't connect" as an IP check first, not a Jellyfin outage.

## Lesson

Anything a client bookmarks by IP needs a reserved lease. I'd already documented the LAN IP in [local-access.md](local-access.md) and [dns.md](dns.md) as if it were static, and it wasn't.
