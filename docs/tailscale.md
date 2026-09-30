# Jellyfin + Tailscale (remote access)

Stream from phones, laptops, and TVs when you are away — over your **private Tailscale mesh**, without opening Jellyfin to the public internet.

## Recommended setup on this gaming PC

Install **Tailscale on the Windows host** (Docker Desktop + a Tailscale container is awkward on Windows). Jellyfin stays in Docker on port **8096**; Tailscale makes that port reachable to your other devices on the same tailnet.

### 1. Host Tailscale

1. Install Tailscale for Windows: https://tailscale.com/download
2. Sign in with the same account/tailnet you will use on phones and other PCs.
3. Confirm the machine appears in the Tailscale admin console and note:
   - **MagicDNS** name (e.g. `desktop-fh9ksh7`) or
   - **100.x.y.z** Tailscale IP

### 2. Point Jellyfin at Tailscale

In the stack `.env` (copy from `.env.example` if needed):

```env
JELLYFIN_PublishedServerUrl=http://desktop-fh9ksh7:8096
```

Or use the Tailscale IP:

```env
JELLYFIN_PublishedServerUrl=http://100.x.y.z:8096
```

Recreate Jellyfin so the env applies:

```powershell
docker compose --profile core up -d jellyfin
```

In Jellyfin **Dashboard → Networking**, you can also set the same public/LAN URL if the wizard asks. Prefer HTTPS only if you terminate TLS yourself; plain HTTP over Tailscale is normal for a private mesh.

### 3. Client devices

1. Install the Tailscale app (iOS / Android / TV / another PC) and join the **same tailnet**.
2. Open Jellyfin at `http://<magicdns>:8096` or `http://100.x.y.z:8096`.
3. Official Jellyfin apps: add that URL as the server.

### 4. Firewall

Windows Firewall usually allows Tailscale. If the UI loads on the PC but not remotely:

- Confirm Tailscale shows **Connected** on both devices.
- Allow inbound TCP **8096** for Docker/WSL if a rule blocks it (Tailscale traffic still lands on the host port mapping).

## What not to do

- **Do not** port-forward `8096` on your home router for “easy remote.” Tailscale replaces that.
- **Do not** enable Tailscale **Funnel** unless you intentionally want a public URL (that exposes Jellyfin to the internet). Prefer private tailnet only.
- Optional **Tailscale Serve** can put HTTPS on the tailnet hostname. I use it for Obsidian’s Local REST API (tailnet only) — [obsidian-rest-api.md](obsidian-rest-api.md). Host Tailscale + `:8096` is still enough for Jellyfin alone.

## Moving to a dedicated box later

1. Install Tailscale on the new machine; join the same tailnet.
2. Update `JELLYFIN_PublishedServerUrl` to the **new** MagicDNS/IP.
3. `docker compose up -d jellyfin`
4. Clients keep the same Tailscale account — just point the Jellyfin app at the new hostname (or rename the machine in Tailscale to keep the old name).

Internal Docker names (`sonarr`, `qbittorrent`, …) stay unchanged; only the **host** Tailscale identity changes.

## Overseerr / *arr from remote

Those admin UIs are also on localhost ports. You *can* reach them via Tailscale the same way (`http://<magicdns>:5055`, etc.), but lock them down with strong auth. Many people only expose **Jellyfin** remotely and leave *arr on LAN/Tailscale for themselves.
