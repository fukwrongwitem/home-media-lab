# Sonarr anime quality loosen

Some long-running anime packs sit under Sonarr’s default per-minute size floors (short episode runtimes, WEB/HDTV encodes). I loosened **Sonarr only** for one series; Radarr movie profiles stayed untouched.

## What I changed

### 1. Quality profile `Anime-Loose`

- Allowed: Unknown, SDTV, WEB 480p/720p/1080p, DVD, Bluray up through 1080p, HDTV 720p/1080p
- Disallowed: Remux, Raw-HD, 2160p
- Upgrades off; cutoff HDTV-720p
- Assigned **only** to the series that needed it — everything else stayed on the normal HD profile

### 2. Global quality-definition minimums (Sonarr)

Lowered MB/min on HDTV/WEB 720p and 1080p so short anime episodes are not rejected as undersized. Bluray mins unchanged.

These mins are **global** in Sonarr (they affect every series). Snapshot the quality definitions before editing so you can roll back. Radarr definitions were not touched.

### 3. Monitoring

Turn on the seasons you actually want. Incomplete season monitoring is a common reason “complete pack” grabs fail with episode-not-monitored.

## Gotchas I hit

- Fansub / iTunes-style titles often land as quality **Unknown** — allow Unknown on the loose profile if that is intentional.
- Zero-seed packs still fail seeder checks; Interactive Search is fine when auto-search stalls.
- Occasional packs fail size checks when Sonarr treats runtime as the full series length.
- Next **Recyclarr** sync with `quality_definition: type: series` can reset those mins — re-apply or exclude if anime grabs break again.

## What I did not change

- Radarr quality profiles / definitions
- Recyclarr’s `radarr:` block
- Other Sonarr series’ profiles
