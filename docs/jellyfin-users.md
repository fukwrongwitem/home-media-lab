# Jellyfin / Jellyseerr access model

Dual-use home stack: one admin for the host, plus household accounts with different request powers.

## Accounts (pattern)

| Role | Jellyfin | Jellyseerr | Intent |
|------|----------|------------|--------|
| Stack admin | existing admin user | admin | Leave as host/owner admin |
| Approver | non-admin media user | admin / manage requests | Approve and curate household requests |
| Requester | non-admin media user | request only | Request TV/movies; no admin |

In this lab: stack admin stays `draco`; approver is `rado`; requester is `sebastian`.

## Policy

- Requesters open movies/TV in Jellyseerr only.
- Approver reviews and approves (Jellyseerr admin).
- New Jellyseerr users default to **request-only** permissions.
- Stack admin on Jellyfin is left unchanged for compose/ops work.

## URLs (lab)

- Jellyfin LAN: `http://<LAN-IP>:8096`
- Jellyseerr LAN: `http://<LAN-IP>:5055`
- Jellyfin over Tailscale: `http://<tailscale-ip-or-magicdns>:8096` (see [tailscale.md](tailscale.md))

Prefer `http://127.0.0.1:...` on the media PC itself ([local-access.md](local-access.md)).

## Passwords

Not stored in this repo. Users change passwords in Jellyfin (Profile → Password). The same Jellyfin login is used for Jellyseerr media-server sign-in when that is enabled.

## Ops notes

- After creating users, confirm Jellyseerr imported them from Jellyfin and that requester vs approver permissions match the table above.
- Keep credentials out of Obsidian notes that sync toward public docs.
