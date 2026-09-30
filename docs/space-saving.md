# SSD space strategy (prefer compressed media)

D: (and most laptop/gaming SSDs) fill up fast with remuxes and uncompressed Blu-ray rips. This stack assumes you **prefer smaller compressed files** over archival remux quality.

Jellyfin on a LAN plays HEVC (x265) and modern codecs fine for typical TVs/phones/browsers. Prefer grabbing already-compressed releases; use optional Unmanic only to shrink what you already have.

Quality and size strategy only — no indexer lists.

## Prefer / avoid

| Prefer | Avoid / deprioritize |
|--------|----------------------|
| **x265 / HEVC** encodes | Uncompressed / huge **Remux** / Blu-ray disc dumps |
| **WEBDL / WEBRIP** when they are already x265 | Multi-audio 4K remuxes “just in case” |
| **1080p** (movies) or **720p–1080p** (TV) | Storing both a remux *and* a compressed copy |
| **AV1** if clients support it and size is better | Keeping incomplete downloads forever |

Rough size intuition (order of magnitude): a 1080p x265 movie is often a few GB; a remux of the same title can be tens of GB. On a limited SSD, remuxes are rarely worth it for casual streaming.

## Sonarr / Radarr quality profile (space-saving shape)

Do this **before** adding many shows/movies (see [wire-up.md](wire-up.md)).

### Movies (Radarr)

Suggested custom profile idea (name it e.g. `Space-1080p-x265`):

1. **Allowed qualities:** WEBDL-1080p, WEBRIP-1080p, Bluray-1080p (for already-compressed encodes), optionally WEBDL-720p as fallback.
2. **Cap resolution:** prefer **1080p max** unless you have spare disk and HEVC 2160p clients.
3. **Custom formats / scoring (conceptually):**
   - **Boost:** `x265`, `HEVC`, `AV1`, `WEBDL`, `WEBRIP`
   - **Penalize or block:** `Remux`, `REMUX`, uncompressed `AVC`/`x264` when a smaller HEVC exists, huge sample sizes
4. **Upgrade until:** stop once you have a solid 1080p HEVC — do not keep upgrading into remux.
5. **Minimum / maximum size** (optional): set sane max sizes per runtime so multi-tens-of-GB grabs fail the profile.

### TV (Sonarr)

Suggested profile idea (e.g. `Space-TV-x265`):

1. Prefer **720p or 1080p WEB** encodes in **x265/HEVC**.
2. Cap at **1080p**; many series are fine at **720p** on SSD.
3. Same custom-format idea: prefer HEVC/WEB; reject or heavily deprioritize **Remux**.
4. Enable season-pack friendly settings only if packs are still HEVC-sized — giant remux season packs will crush the disk.

### Music (Lidarr)

Prefer lossy (e.g. V0/320) unless you intentionally archive FLAC and have space. Not covered by Unmanic video encode.

## Jellyfin

- Add libraries as usual (`/media/movies`, `/tv`, `/music`).
- HEVC/x265 playback on LAN is normal; if a client cannot decode HEVC, Jellyfin may **transcode** (CPU cost on this gaming PC — avoid while gaming).
- Prefer clients with hardware HEVC decode (most modern TVs, phones, browsers with MSE/EME vary).

## Optional: Unmanic (`compress` profile)

Image: `josh5/unmanic` — UI at **http://localhost:8888**.

```powershell
# When NOT gaming / not needing CPU headroom:
docker compose --profile compress up -d
# or with core:
docker compose --profile core --profile compress up -d

# Before gaming:
docker compose stop unmanic
```

### What it is for

- Re-encode **existing** library files under `/library` (bind of `MEDIA_ROOT`) to **HEVC** to reclaim SSD space.
- Cache/work dir: `downloads/unmanic-cache` → `/tmp/unmanic` (needs free space during encode; clean occasionally).

### CPU / gaming PC notes (~16 GB RAM)

- Default path on **Docker Desktop + Windows + AMD** is **software (CPU) encode** — slow and hot; will compete with games.
- **Do not** leave Unmanic workers running while gaming.
- Start with **1 worker**, low priority; raise only when the PC is idle overnight.
- On a **future dedicated Linux box**, VA-API/`/dev/dri` may enable AMD/Intel HW encode; that is unreliable on Docker Desktop Windows today (same story as Jellyfin AMD notes in the README).

### Plugin direction (high level)

In Unmanic, enable a video converter plugin aimed at **HEVC/x265**, skip files already HEVC, and optionally ignore small files. Test on one movie/show folder before scanning the whole library.

## Prefer “download small” over “re-encode later”

Re-encoding burns CPU and can lose quality. Best SSD strategy:

1. Space-saving **quality profiles** in Radarr/Sonarr (above).
2. Delete or avoid remuxes.
3. Only then run Unmanic on leftovers that are still oversized.

## Related

- Portable move / separate media drive: [migrate.md](migrate.md)
- First-run order: [wire-up.md](wire-up.md)
