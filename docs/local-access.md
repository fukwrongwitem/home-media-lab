# Local access notes

General lessons from opening the stack's web UIs on the same Windows PC that runs Docker Desktop.

## Use localhost on the server itself

From the media PC, open the UIs at `http://localhost:<port>`. Using the PC's own LAN IP from the PC itself often hangs (Docker Desktop hairpin behavior). Other devices on the LAN use `http://<server-lan-ip>:<port>`.

## Dashboards don't need custom DNS

The dashboard and apps work by IP/localhost with the router's default DNS. I don't rely on Pi-hole hostnames just to open a UI, so the dashboard still works when the `dns` profile is stopped.

## Dashboard status checks

In Homarr, tile **links** point at what the browser can reach (`localhost:<port>` on this PC), while tile **status pings** use Docker service names (`http://jellyfin:<container-port>`), because the pings run from inside the container network.

## Host port conflicts

Before publishing a new web UI port, check that nothing on the Windows host already owns it:

```powershell
Get-NetTCPConnection -LocalPort <port> -State Listen
Get-Process -Id <OwningProcess>
```

I hit this once with another app already listening on a common web port. The fix was to change only the **host** side of the port mapping and leave the container port alone, so other containers that talk to it by service name didn't need changes.
