# Jellyfin + Tailscale (remote access)

Stream from my other devices when I'm away — over your **private Tailscale mesh**, without opening Jellyfin to the public internet.

## Recommended setup on this gaming PC

Install **Tailscale on the Windows host** (Docker Desktop + a Tailscale container is awkward on Windows). Jellyfin stays in Docker on port **8096**; Tailscale makes that port reachable to your other devices on the same tailnet.

### 1. Host Tailscale

1. Install Tailscale for Windows: https://tailscale.com/download
2. Sign in with the same account/tailnet you will use on your other devices.
3. Confirm the machine appears in the Tailscale admin console and note:
   - **MagicDNS** hostname (`<tailscale-hostname>`) or
   - Tailscale IP (`<tailscale-ip>`)

### 2. Point Jellyfin at Tailscale

In the stack `.env` (copy from `.env.example` if needed):

```env
JELLYFIN_PublishedServerUrl=http://<tailscale-hostname>:8096
```

Or use the Tailscale IP:

```env
JELLYFIN_PublishedServerUrl=http://<tailscale-ip>:8096
```

Recreate Jellyfin so the env applies:

```powershell
docker compose --profile core up -d jellyfin
```

In Jellyfin **Dashboard → Networking**, you can also set the same public/LAN URL if the wizard asks. Prefer HTTPS only if you terminate TLS yourself; plain HTTP over Tailscale is normal for a private mesh.

### 3. Client devices

1. Install the Tailscale app on the client device and join the **same tailnet**.
2. Open Jellyfin at `http://<tailscale-hostname>:8096` or `http://<tailscale-ip>:8096`.
3. Official Jellyfin apps: add that URL as the server.

### 4. Firewall

Windows Firewall usually allows Tailscale. If the UI loads on the PC but not remotely:

- Confirm Tailscale shows **Connected** on both devices.
- Check that the host firewall isn't blocking the Jellyfin port (Tailscale traffic still lands on the host port mapping).

## What not to do

- **Do not** port-forward `8096` on your home router for “easy remote.” Tailscale replaces that.
- **Do not** enable Tailscale **Funnel** unless you intentionally want a public URL (that exposes Jellyfin to the internet). Prefer private tailnet only.
- Tailscale **Serve** can put HTTPS on the tailnet hostname if a service needs it. Host Tailscale plus the Jellyfin port is enough for Jellyfin alone.

## Moving to a dedicated box later

1. Install Tailscale on the new machine; join the same tailnet.
2. Update `JELLYFIN_PublishedServerUrl` to the **new** Tailscale hostname/IP.
3. `docker compose up -d jellyfin`
4. Clients keep the same Tailscale account — just point the Jellyfin app at the new hostname (or rename the machine in Tailscale to keep the old name).

Internal Docker names (`jellyfin`, `pihole`, …) stay unchanged; only the **host** Tailscale identity changes.

## Admin UIs

The other admin UIs are also on host ports, so they're technically reachable over the tailnet too. Keep strong auth on them, and treat Jellyfin as the only thing meant for regular remote use.
