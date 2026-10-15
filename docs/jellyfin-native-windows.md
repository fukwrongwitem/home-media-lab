# Jellyfin as a native Windows service

I moved Jellyfin off Docker on this PC and installed Jellyfin Server for Windows as a service. The compose file still has a `jellyfin` service. I kept it so the same folder can move to a Linux box later.

## Why I did it

Jellyfin went down every time I stopped Docker Desktop. That happened a lot, since I restart it for updates and stop things before games. Family playback should not depend on that.

I also wanted a better shot at AMD hardware encode. Docker Desktop on Windows is a poor fit for that. I have not turned hardware encode on yet. I still use software encode until I have checked quality and CPU load.

The libraries did not move. Movies and Shows point at the same `media/movies` and `media/tv` folders as before, so rips and HandBrake output land in the same places ([disc-ripping.md](disc-ripping.md)).

## How it is set up

- Installed Jellyfin Server for Windows with the normal installer.
- It runs as the `JellyfinServer` service, start type Automatic, under the default NetworkService account.
- It listens on the same HTTP port as the compose example, `<JELLYFIN_PORT>`.
- Config and metadata live under ProgramData, not under `config/jellyfin` in the compose folder. Easy to forget when backing up.
- Libraries use absolute Windows paths into `<STACK_ROOT>/media/...`.

I do not start the compose `jellyfin` service on this PC. Two things cannot both listen on the same port.

## What is different from the Docker setup

The first-run steps are the same as in [wire-up.md](wire-up.md) and [jellyfin-plugins.md](jellyfin-plugins.md). I open it at `http://localhost:<JELLYFIN_PORT>` on the server.

Library paths are Windows paths now, not `/media/movies` inside a container.

File watching is better on a plain NTFS folder than on a Docker Desktop bind mount. I still left the hourly library scan on as a backup ([jellyfin-library-updates.md](jellyfin-library-updates.md)).

Remote access did not change. I still use Tailscale and no router port forward ([tailscale.md](tailscale.md)).

## Gaming Mode

`docker compose stop` cannot touch the Windows service. Gaming Mode only stops Homarr and Unmanic now, and Jellyfin keeps running ([gaming-mode.md](gaming-mode.md)). If playback is down, I check Services for `JellyfinServer`. It will not show up in `docker compose ps`.

## Moving back to compose later

1. Stop the Windows service and set it to Disabled.
2. Make sure the library folders are still under `MEDIA_ROOT`.
3. Run `docker compose --profile core up -d`.
4. Check the published server URL in the Jellyfin dashboard again.
