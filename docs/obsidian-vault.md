# Homelab notes in Obsidian

I keep ops notes next to the stack so a backup of the media-server folder includes the runbooks.

## Layout

Vault path on this PC: `D:\media-server\obsidian-vault` (open that folder as a vault in Obsidian).

```text
obsidian-vault/
├── 00-Home.md
├── Homelab/          # Docker, Hardware, Backups, Troubleshooting, Media-Stack, Networking, Gaming
├── Networking/       # DNS, Tailscale, VPN pointers, LAN
├── Media/            # Jellyfin, *arr, downloads, quality profiles
├── Gaming/           # Gaming Mode, launchers
├── IT/               # tickets / learning scratch
└── Personal/         # inbox, projects, daily
```

Category folders hold topic notes; I split further inside a category when one note would get noisy (e.g. Media-Stack vs Networking).

## What stays out of the vault

- API keys, VPN private keys, `.env`, and download-client passwords live under the stack’s secrets/config tree — not in markdown.
- Indexer shopping lists and release names stay out of notes I might mirror elsewhere.

## Related stack docs

| Topic | Doc |
|-------|-----|
| Proton / gluetun for qBit (planned) | [proton-vpn-qbit.md](proton-vpn-qbit.md) |
| Tailscale + Serve for Local REST API | [tailscale.md](tailscale.md), [obsidian-rest-api.md](obsidian-rest-api.md) |
| Gaming Mode | [gaming-mode.md](gaming-mode.md) |
| Public portfolio mirror | this repo — sanitized copies only |
