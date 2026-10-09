# Homelab notes in Obsidian

I keep ops notes in an Obsidian vault inside the stack folder, so a backup of the stack includes the runbooks.

## Layout

```text
obsidian-vault/
├── 00-Home.md
├── Homelab/          # Docker, Hardware, Backups, Troubleshooting, Media-Stack, Networking, Gaming
├── Networking/       # DNS, remote access, LAN
├── Media/            # Jellyfin, disc ripping, encode settings
├── Gaming/           # Gaming Mode, launchers
├── IT/               # tickets / learning scratch
└── Personal/         # inbox, projects, daily
```

Category folders hold topic notes; I split further inside a category when one note would get noisy (e.g. Media-Stack vs Networking).

## What stays out of the vault

- API keys, `.env`, and admin passwords live in the stack's config tree, not in markdown.
- Network specifics (addresses, hostnames, how things are reachable) stay out of anything I might mirror publicly.
- Personal library lists stay out of notes I might mirror elsewhere.

## Related stack docs

| Topic | Doc |
|-------|-----|
| Disc ripping workflow | [disc-ripping.md](disc-ripping.md) |
| Remote access | [tailscale.md](tailscale.md) |
| Gaming Mode | [gaming-mode.md](gaming-mode.md) |
| Public portfolio mirror | this repo — sanitized copies only |
