# Downloads on a secondary volume

Bulk download scratch space can live on a second drive while app config stays on the primary (fast) volume.

## Pattern

| Path env | Typical role |
|----------|----------------|
| `CONFIG_ROOT` | App config (primary / SSD) |
| `MEDIA_ROOT` | Primary library trees |
| overflow mounts (`movies2` / `tv2`) | Extra library capacity on a second volume |
| `DOWNLOADS_ROOT` | qBittorrent + *arr incomplete/complete (often the second volume) |

Example `.env` override (Windows Docker Desktop style):

```env
CONFIG_ROOT=./config
MEDIA_ROOT=./media
DOWNLOADS_ROOT=E:/media-server/downloads
```

## Why this works without remapping *arr

- Container paths stay `/downloads`, `/movies`, `/tv`, `/movies2`, `/tv2`.
- Sonarr/Radarr remote-path maps do **not** need to change when only the **host** side of `DOWNLOADS_ROOT` moves.
- Library roots can remain split: primary under `MEDIA_ROOT`, overflow via secondary mounts already in compose.

## Ops notes

- Prefer compressed encodes (see [space-saving.md](space-saving.md)) so the download volume does not fill with remuxes.
- After moving `DOWNLOADS_ROOT`, recreate or remount the qBittorrent / *arr containers so they pick up the new bind.
- Empty leftover download folders on the old volume only after confirming imports and active torrents look healthy.
