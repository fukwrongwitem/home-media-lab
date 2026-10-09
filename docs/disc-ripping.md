# Ripping my own discs into Jellyfin

How DVDs, Blu-rays, and audio CDs I bought end up in the Jellyfin library. Video goes disc → lossless MKV → (optional) HEVC encode → named folder under `media/`. CDs go to FLAC with a verified rip and MusicBrainz tags.

> **Legal note.** In the US, DMCA §1201 prohibits circumventing technical measures that control access to copyrighted works, and that covers the encryption on most commercial DVDs and Blu-rays even when you own the disc. Ripping your own discs for personal use is a legal gray area, not a clear right. I only rip discs I own, for playback in my own house, and I don't share or distribute the files. Audio CDs normally have no encryption to bypass.

## Hardware

- **Drive:** any internal SATA or USB Blu-ray reader handles DVD, Blu-ray, and CD. On the gaming PC I use a USB 3 drive so I can unplug it when it's not in use. Give a USB drive its own port (not a passive hub); bus-powered slim drives can be flaky on weak ports.
- **4K UHD discs:** reading UHD needs a drive and firmware combination that MakeMKV supports (the MakeMKV forum keeps a "UHD friendly" drive list). Plenty of retail drives won't read UHD with their stock firmware. I don't own UHD discs right now, so I skip that and stay on regular Blu-ray.
- **Disk space:** a Blu-ray rip needs 20–50 GB of free scratch space before encoding, a DVD 4–9 GB.

## Software

| Job | Tool | Notes |
|-----|------|-------|
| DVD / Blu-ray → MKV | **MakeMKV** | Reads the disc and writes MKV without re-encoding; keeps all video/audio/subtitle tracks and chapters. DVD support is free; Blu-ray is free during the beta. |
| Optional shrink | **HandBrake** | H.265 (x265) Constant Quality encode — see [space-saving.md](space-saving.md) |
| Audio CD → FLAC (Windows) | **Exact Audio Copy (EAC)** | Secure mode + AccurateRip verification |
| Audio CD → FLAC (Linux, later box) | **whipper** | Same idea: accuracy over speed, AccurateRip |
| Music tagging | **MusicBrainz Picard** | Looks up the CD (or the EAC/whipper log) and writes tags |

MakeMKV handles reading the disc. I don't use any other tools for that.

## Folder layout

```text
<stack-root>\
├── work\               # WORK_ROOT (can point at a secondary drive in .env)
│   ├── rips\           # raw MakeMKV output, deleted after encode check
│   └── encodes\        # HandBrake output waiting for a spot-check
└── media\              # MEDIA_ROOT, read-only inside Jellyfin
    ├── movies\
    ├── tv\
    ├── music\
    └── home-videos\
```

Only finished, named files go into `media\`. That way Jellyfin never scans a half-written file (see [jellyfin-library-updates.md](jellyfin-library-updates.md)).

## Movie workflow (DVD / Blu-ray)

1. Insert the disc, open MakeMKV, let it scan.
2. Pick the **main feature**. Usually the longest title, and it should match the runtime on the case. Untick the rest unless I want extras.
3. Tracks: keep the main audio track in the original language, any commentary I care about, and English subtitles (full plus forced, if present).
4. Output folder: `work\rips\Example Movie (2019)\`. Rip.
5. Optional: open the MKV in HandBrake, H.265 (x265) with Constant Quality, audio passthru, subtitles as below, output to `work\encodes\`.
6. Spot-check: start, a dark scene, a fast scene, a part with subtitles, the end.
7. Rename and move into the library, trigger a Jellyfin refresh, delete the raw rip.

## Jellyfin naming

Based on the Jellyfin docs for movies and shows. Avoid `< > : " / \ | ? *` in names.

### Movies

```text
media\movies\
└── Example Movie (2019)\
    ├── Example Movie (2019).mkv
    ├── Example Movie (2019).en.srt
    ├── Example Movie (2019).en.forced.srt
    ├── behind the scenes\
    │   └── Making Of.mkv
    ├── deleted scenes\
    │   └── Alternate Ending.mkv
    └── trailers\
        └── Trailer.mkv
```

- Folder `Title (Year)`, file name the same as the folder. Adding `[imdbid-tt0000000]` or `[tmdbid-000]` to the folder name pins the match when titles are ambiguous.
- Two cuts of one movie on one disc: `Example Movie (2019) - Theatrical.mkv` and `Example Movie (2019) - Extended.mkv` in the same folder show up as versions of one item.
- Extras folders Jellyfin recognizes: `behind the scenes`, `deleted scenes`, `interviews`, `scenes`, `shorts`, `featurettes`, `clips`, `trailers`, `extras`, `other`.

### TV (season box sets)

```text
media\tv\
└── Example Show (2015)\
    ├── Season 00\
    │   └── Example Show S00E01.mkv
    └── Season 01\
        ├── Example Show S01E01.mkv
        ├── Example Show S01E02.mkv
        └── Example Show S01E03-E04.mkv
```

- `Season 01`, not `S01`, and pad the number. Specials go in `Season 00`.
- Disc title order doesn't always match episode order. I check runtimes against the episode list before renaming.
- If a disc stores two episodes as one title, Jellyfin shows one entry for both (`S01E03-E04`). It's cleaner to split them by chapter in MakeMKV or with MKVToolNix.

### Home videos

`media\home-videos\` uses the "Home Videos and Photos" library type. I name folders by date and event (`2024-07 Beach Trip\`); no metadata lookup is needed.

## Metadata and subtitles

- Jellyfin pulls metadata from TMDB/TVDB by name and year. A wrong match usually means a wrong year or an ambiguous title, so add the provider ID to the folder name and run Refresh Metadata.
- MKV keeps subtitle tracks inside the file. External subtitle files go next to the video with a language flag: `.en.srt`, `.en.forced.srt`, `.en.sdh.srt`.
- **Forced subtitles** (only the foreign-language lines): on some discs this is a flag on part of the normal track, and on others it's a separate track. HandBrake's **Foreign Audio Search** with **Forced** checked can find the first kind. If it comes back empty, look for a short separate track and pick it by hand. Blu-ray subtitles (PGS) are images, so HandBrake can't convert them to SRT. MKV keeps them as-is, and some clients burn them in during playback, which forces a transcode.

## Audio CDs → FLAC

1. **EAC first-time setup:** run the configuration wizard, use **secure mode**, run Detect Read Features for the drive, and let AccurateRip calibrate the drive offset with a CD that's in its database (one time per drive).
2. Encoder: FLAC via EAC's external compression (EAC can set this up in the wizard). Lossless, and roughly half the size of WAV.
3. Rip the CD and keep the **log** (and cue sheet) next to the files. An AccurateRip match on every track means the rip is verified.
4. **Tag with Picard:** Tools → Lookup CD (with the disc in the drive) or **From CD ripper log file** using the EAC log. Check that the release matches the physical CD (country, label, catalog number, track count), then save.
5. Layout: `media\music\Example Artist\Example Album (2010)\01 Track Title.flac`, with `cover.jpg` in the album folder. Jellyfin music is driven by the embedded tags; for multi-disc albums, all discs go in one album folder and the disc-number tag sorts them.

On the future Linux box, whipper replaces EAC (same AccurateRip check and a log that Picard can read).

## What to watch for

These are documented failure modes from the tool docs and forums, so I check for them on every disc:

- **Wrong main title (playlist obfuscation):** some Blu-rays ship dozens or hundreds of playlists with the same length but the scenes in a different order. MakeMKV can mark a likely main feature (it needs Java installed for this), but the guess can be wrong. If the encode has scenes out of order, re-rip with another playlist. The MakeMKV forum often has the right playlist for a given disc.
- **Forced subs missing:** see above. Check a scene with foreign-language dialogue before deleting the raw rip.
- **Episode order:** disc title order isn't always airing order. Check runtimes before renaming.
- **CD with no AccurateRip match:** the disc may just not be in the database, or the rip may have errors. Clean the disc, re-rip, and compare the test and copy CRCs in the log.
- **FLAC playback in browsers:** the Jellyfin docs note that FLAC with embedded WebP art or ID3 tags can fail in Chromium/Firefox. Use JPEG cover art, or turn on "Always remux FLAC audio files" in the client.
- **Encode quality:** RF too high shows up as banding in dark gradients first. Re-encode from the raw rip (not from the encode), which is why I keep the raw rip until the spot-check passes.

## Sources

- MakeMKV: https://www.makemkv.com/
- MakeMKV forum, fake playlist / main feature detection: https://forum.makemkv.com/forum/viewtopic.php?t=16791
- MakeMKV forum, UHD drive guide: https://forum.makemkv.com/forum/viewtopic.php?p=74927
- HandBrake, adjusting quality (RF ranges): https://handbrake.fr/docs/en/latest/workflow/adjust-quality.html
- HandBrake, subtitles and forced subtitles: https://handbrake.fr/docs/en/latest/advanced/subtitles.html
- Jellyfin movies naming: https://jellyfin.org/docs/general/server/media/movies/
- Jellyfin shows naming: https://jellyfin.org/docs/general/server/media/shows/
- Jellyfin music: https://jellyfin.org/docs/general/server/media/music/
- EAC extraction technology (secure mode): https://www.exactaudiocopy.org/extraction-technology/
- EAC AccurateRip: https://exactaudiocopy.org/accurate-rip/
- Hydrogenaudio, EAC and FLAC: https://wiki.hydrogenaud.io/?title=EAC_and_FLAC
- AccurateRip: https://www.accuraterip.com/
- whipper: https://github.com/whipper-team/whipper
- MusicBrainz Picard, CD lookup: https://picard-docs.musicbrainz.org/en/latest/usage/retrieve_lookup_cd.html
- MusicBrainz Picard, when the CD is available: https://picard-docs.musicbrainz.org/en/latest/workflows/workflow_cd.html
- US Copyright Office, Section 1201: https://www.copyright.gov/1201/
