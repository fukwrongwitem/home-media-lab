# Jellyfin library updates (Docker Desktop / Windows)

## Symptom

New files copied into `media/movies` or `media/tv` (finished rips, home videos) show up on disk but not in Jellyfin until a long delay, or not at all until a manual scan.

## Root cause (Docker Desktop bind mounts)

1. **Realtime monitoring is unreliable** on Docker Desktop Windows bind mounts (`EnableRealtimeMonitor=true` still often misses file creates).
2. Default **Scan Media Library** interval can be many hours (e.g. 12h).

The path mounts themselves were fine: `media/movies` → `/media/movies`, `media/tv` → `/media/tv`, plus the `movies2` / `tv2` overflow mounts.

## What fixed it

1. Set **Scan Media Library** to a shorter interval (every 1 hour) as the safety net.
2. Created a Jellyfin API key for local scripts (stored outside git).
3. After copying a batch of new rips into the library, trigger a one-shot refresh instead of waiting:

```powershell
# API key comes from my local secrets, never from this repo
Invoke-RestMethod -Method Post -Uri "http://localhost:<JELLYFIN_PORT>/Library/Refresh" -Headers @{ "X-Emby-Token" = $env:JELLYFIN_API_KEY }
```

## Confirm

- New titles appear after the refresh call, or within the scan interval.
- Manual fallback: Jellyfin Dashboard → Scan All Libraries.

## Notes

- Copy finished files into the library in one move (encode in `work/encodes`, then move the finished folder). A half-copied file picked up by a scan can get matched with bad runtime/metadata; "Refresh metadata" on the item fixes it.
- Docker bind mounts on Windows can't hardlink across drives, so moves between volumes are real copies and take a while for big files.
