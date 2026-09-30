# Jellyfin library updates (Docker Desktop / Windows)

## Symptom

New imports from Sonarr/Radarr land on disk under `media/tv` or `media/movies` but do not appear in Jellyfin until a long delay (or never until a manual scan).

## Root cause (Docker Desktop bind mounts)

1. **Realtime monitoring is unreliable** on Docker Desktop Windows bind mounts (`EnableRealtimeMonitor=true` still often misses file creates).
2. **No Sonarr/Radarr → Jellyfin Connect** means imports do not trigger a targeted library refresh.
3. Default **Scan Media Library** interval can be many hours (e.g. 12h).

Path mounts themselves were already correct in this stack:

- Sonarr `/tv` + `/tv2` ↔ Jellyfin `/media/tv` + `/media/tv2`
- Radarr `/movies` + `/movies2` ↔ Jellyfin `/media/movies` + `/media/movies2`

## What fixed it

1. Trigger a one-shot `POST /Library/Refresh` (full scan) after large backfills.
2. Create a Jellyfin API key dedicated to *arr notifications (store only in the apps; never in git).
3. Add Emby/Jellyfin (**MediaBrowser**) Connect entries in Sonarr and Radarr with **Update Library** and path maps:
   - Sonarr: `/tv` → `/media/tv`, `/tv2` → `/media/tv2`
   - Radarr: `/movies` → `/media/movies`, `/movies2` → `/media/movies2`
   - Host: `jellyfin` (compose network DNS), port `8096`
4. Set **Scan Media Library** to a shorter interval (e.g. every 1 hour) as a safety net.

## Confirm

- Jellyfin Shows/Movies: new titles appear after import (Connect) or within the scan interval.
- Sonarr/Radarr → Settings → Connect: Test succeeds for the Jellyfin entries.
- Manual: Jellyfin Dashboard → Scan All Libraries, or `POST http://127.0.0.1:8096/Library/Refresh` with an API key.

## Notes

- Large pack imports may sit in Sonarr **importPending** while another item is **importing** (Docker bind mounts often cannot hardlink; copies are slow). That is separate from Jellyfin visibility once files exist under `media/`.
- Bazarr may still mount only primary `movies`/`tv` — add `/movies2` `/tv2` if subtitles on overflow storage are needed.
