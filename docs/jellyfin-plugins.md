# Jellyfin plugins

Notes from Jellyfin Server **10.10+/12.x** (`jellyfin/jellyfin:latest`) on Windows + Docker Desktop.

## Plugins in use

| Plugin | Role |
|--------|------|
| **Jellyfin Enhanced** | UI QoL (keyboard shortcuts, playback and display tweaks) |
| **Intro Skipper** | Detect/skip TV intros & credits |
| **Media Bar** | Featured bar on the home screen |
| **File Transformation** | Dependency for Media Bar (also recommended for Enhanced) |

Plugin files live under `config/jellyfin/plugins/` (gitignored with other app config).

## Plugin repositories

Dashboard → Plugins → Repositories (or `POST /Repositories`):

| Name | Manifest |
|------|----------|
| Jellyfin Stable (default) | `https://repo.jellyfin.org/files/plugin/manifest.json` |
| Jellyfin Enhanced | `https://raw.githubusercontent.com/n00bcodr/jellyfin-plugins/main/manifest.json` |
| Intro Skipper | `https://intro-skipper.org/manifest.json` |
| IAmParadox Plugins (Media Bar + File Transformation) | `https://www.iamparadox.dev/jellyfin/plugins/manifest.json` |

Sources:

- [Jellyfin Enhanced install docs](https://n00bcodr.github.io/Jellyfin-Enhanced/installation/installation/)
- [intro-skipper/intro-skipper](https://github.com/intro-skipper/intro-skipper)
- [IAmParadox27/jellyfin-plugin-media-bar](https://github.com/IAmParadox27/jellyfin-plugin-media-bar)

## Install / restart outline

1. Add community repositories via Dashboard or API.
2. Install packages from Catalog.
3. Restart the `jellyfin` container so plugins load.
4. Confirm **Active** under Dashboard → Plugins.

```powershell
cd <STACK_ROOT>
docker restart jellyfin
# or: docker compose --profile core restart jellyfin
```

## After install

1. Hard-refresh every Jellyfin **web** client.
2. Media Bar: configure featured content if options appear; requires File Transformation.
3. Intro Skipper: enable detection scheduled tasks (first library pass can take a while).
