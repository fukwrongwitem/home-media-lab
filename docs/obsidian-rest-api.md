# Obsidian Local REST API over Tailscale Serve

I expose Obsidian’s **Local REST API** plugin to my **private Tailscale mesh** so other machines on the same tailnet can read/write vault notes. Funnel stays off — this is not a public URL.

## Pieces

1. **Obsidian** running on the gaming PC with the Local REST API plugin enabled (HTTPS on loopback, default `27124`).
2. **Tailscale Serve** on the Windows host, proxying the MagicDNS hostname to that loopback listener.
3. API key stored on disk under the stack secrets tree — never committed, never pasted into vault notes.

## Serve (host)

```powershell
# Tailnet-only HTTPS on :443 → Obsidian Local REST API (self-signed on loopback)
tailscale serve --bg --yes https+insecure://127.0.0.1:27124

# Disable later
tailscale serve --https=443 off
```

Clients on the same tailnet hit `https://<magicdns>/` (vault API under `/vault/`, etc.). Verify with a simple GET to `/vault/` over the tailnet — expect HTTP 200 while Obsidian is open.

## Ops notes

- Obsidian must be running; Serve alone is not enough.
- Do **not** enable Tailscale **Funnel** for this — that would publish outside the tailnet.
- Rotate the Local REST API key if it ever leaks; keep the key file outside the vault.
- Jellyfin remote access still uses host Tailscale + `:8096` as in [tailscale.md](tailscale.md); Serve here is only for the Obsidian API.
