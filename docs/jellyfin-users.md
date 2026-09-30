# Jellyfin / Jellyseerr access model

Dual-use home stack: host admin account for the owner, plus a household requester with limited powers.

## Accounts (pattern)

| Role | Jellyfin | Jellyseerr | Intent |
|------|----------|------------|--------|
| Owner / approver | admin media user | admin / manage requests | Stack admin + approve household requests |
| Requester | non-admin media user | request only | Request TV/movies; no admin |

In this lab the owner account is **`draco`** (main username). A second Jellyfin user named `rado` was created earlier for the same person and is not treated as a separate household member — prefer `draco`. The requester account is **`sebastian`**.

## Policy

- Requesters open movies/TV in Jellyseerr only.
- Owner (`draco`) reviews and approves (Jellyseerr admin) and remains Jellyfin admin.
- New Jellyseerr users default to **request-only** permissions.

## URLs (lab)

- Jellyfin LAN: `http://<LAN-IP>:8096`
- Jellyseerr LAN: `http://<LAN-IP>:5055`
- Jellyfin over Tailscale: `http://<tailscale-ip-or-magicdns>:8096` (see [tailscale.md](tailscale.md))

Prefer `http://127.0.0.1:...` on the media PC itself ([local-access.md](local-access.md)).

## Passwords

Not stored in this repo. Users change passwords in Jellyfin (Profile → Password). The same Jellyfin login is used for Jellyseerr media-server sign-in when that is enabled.

## Ops notes

- After creating users, confirm Jellyseerr imported them from Jellyfin and that requester vs owner permissions match the table above.
- Keep credentials out of notes that sync toward public docs.
