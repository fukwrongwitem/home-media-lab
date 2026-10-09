# SSD space strategy (prefer compressed media)

My SSD (like most gaming SSDs) fills up fast with full-size disc rips. A lossless Blu-ray MKV is often 20–40 GB per movie; a 1080p HEVC encode of the same disc is usually a few GB and looks the same to me from the couch. So the library keeps **compressed encodes**, and the lossless rip is only a temporary file in `work/`.

Jellyfin on a LAN plays HEVC (x265) fine on typical TVs, phones, and browsers.

## Prefer / avoid

| Prefer | Avoid |
|--------|-------|
| **x265 / HEVC** encodes of my rips | Keeping the lossless MKV after the encode checks out |
| **1080p** (movies), **720p–1080p** (TV) | Storing both a lossless rip *and* an encode long term |
| **AV1** if clients support it and size is better | Multi-audio "just in case" — keep the main track + commentary I actually watch |
| FLAC for CDs (small anyway) | Leaving half-finished rips in `work/rips` forever |

## New rips: encode once with HandBrake

Full workflow is in [disc-ripping.md](disc-ripping.md). The space-relevant part:

1. MakeMKV → lossless MKV in `work/rips/`.
2. HandBrake → H.265 (x265), **Constant Quality**, into `work/encodes/`.
   - HandBrake's docs suggest RF **20–24 for 1080p**, **18–22 for DVD (480p/576p)**, and **22–28 for 4K**. I start at RF 20 for Blu-ray and 19 for DVD and only go higher if the file is still big.
   - Preset **Medium** or slower; slower presets get a bit more efficiency per GB but take much longer on CPU.
   - Keep the original audio track (passthru) for the main movie; it is a small share of the file.
3. Spot-check the encode (dark scenes, fast motion, subtitles), move it into `media/`, then delete the lossless rip.

Run encodes when the PC is idle. Software x265 on this CPU will compete with games.

## Jellyfin

- HEVC/x265 playback on LAN is normal; if a client cannot decode HEVC, Jellyfin may **transcode** (CPU cost on this gaming PC — avoid while gaming).
- Prefer clients with hardware HEVC decode (most modern TVs and phones; browser support varies).

## Optional: Unmanic (`compress` profile)

Image: `josh5/unmanic` — UI on `UNMANIC_PORT`. I use it only for **older** library files that went in before I settled on the HandBrake step.

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
- Cache/work dir: `work/unmanic-cache` → `/tmp/unmanic` (needs free space during encode; clean occasionally).

### CPU / gaming PC notes (~16 GB RAM)

- Default path on **Docker Desktop + Windows + AMD** is **software (CPU) encode** — slow and hot; will compete with games.
- **Do not** leave Unmanic workers running while gaming.
- Start with **1 worker**, low priority; raise only when the PC is idle overnight.
- On a **future dedicated Linux box**, VA-API/`/dev/dri` may enable AMD/Intel HW encode; that is unreliable on Docker Desktop Windows today (same story as the Jellyfin AMD notes in the README).

### Plugin direction (high level)

In Unmanic, enable a video converter plugin aimed at **HEVC/x265**, skip files already HEVC, and optionally ignore small files. Test on one movie/show folder before scanning the whole library.

## Order of operations

Re-encoding an already-encoded file costs CPU and some quality, so:

1. Encode new rips once, from the lossless source, with HandBrake.
2. Delete lossless rips once the encode is checked.
3. Only then run Unmanic on older files that are still oversized.

## Related

- Disc ripping workflow: [disc-ripping.md](disc-ripping.md)
- Portable move / separate media drive: [migrate.md](migrate.md)
- First-run order: [wire-up.md](wire-up.md)
