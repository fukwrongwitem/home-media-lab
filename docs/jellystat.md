# Jellystat (Jellyfin playback stats)

Jellystat shows who watched what, when, and on which client, plus library and
session history. Jellyfin's built-in dashboard only shows what's playing right
now, so this fills the gap.

## Setup

- Runs as its own compose project in `jellystat/`, separate from the main stack:
  Postgres 16 (alpine) for the data, plus the Jellystat app.
- Memory caps on both containers (256 MB for the DB, 512 MB for the app) so it
  stays light next to games on a 16 GB PC.
- Jellyfin is a native Windows service on this PC, not a container, so
  Jellystat reaches it through `host.docker.internal` (mapped with
  `extra_hosts: host-gateway`).
- Secrets (`POSTGRES_PASSWORD`, `JWT_SECRET`) live in `jellystat/.env`. The
  Jellyfin API key is entered once in the Jellystat setup screen.

```powershell
cd jellystat
copy .env.example .env   # fill in the two secrets
docker compose up -d
```

Then open the UI, create the Jellystat admin login, point it at
`http://host.docker.internal:8096`, and paste a Jellyfin API key.

## Notes

- `postgres/` and `backup/` are bind-mounted next to the compose file, so the
  folder moves with the rest of the lab when I migrate.
- Jellystat's own backup feature writes into `backup/`.
- If the stats page is empty, check that the API key is still valid and that
  Jellyfin is up. Containers can't reach `localhost` on the host, which is why
  the URL uses `host.docker.internal`.
