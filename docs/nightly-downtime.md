# Nightly downtime

Nobody in the house is streaming between 1 AM and 8 AM, so I shut the media side down overnight. It saves some power and RAM, and the PC isn't scanning libraries while it sits idle. DNS stays up the whole time, so the rest of the network doesn't notice.

Two Windows scheduled tasks run two scripts in `bin/`.

| Task | When | Script | What it does |
|------|------|--------|--------------|
| Homelab Downtime Start | daily 1:00 AM | `bin/downtime-start.ps1` | Stops the Jellyfin service, then stops the media containers |
| Homelab Downtime End | daily 8:00 AM | `bin/downtime-end.ps1` | Starts Jellyfin and the containers again, then logs UP/DOWN for each one, DNS included |

## What stays up

- Pi-hole and Unbound (DNS for the LAN)
- Docker Desktop / WSL itself. I only stop containers, never the engine

## Setup

From an elevated PowerShell in the stack root, once:

```powershell
powershell -ExecutionPolicy Bypass -File .\bin\register-downtime-tasks.ps1
```

Before turning it on I ran both scripts with `-DryRun` (`-WhatIf` works too). It only logs what it would do:

```powershell
.\bin\downtime-start.ps1 -DryRun
.\bin\downtime-end.ps1 -DryRun
```

Everything goes to `bin/downtime.log`.

## Things I had to think about

- **Docker Desktop only runs when I'm signed in.** It starts at login, so the tasks run as my user with "run only when user is logged on" and highest privileges. If I'm signed out, nothing runs, and the script logs that Docker wasn't reachable.
- **A missed start is skipped, a missed end is not.** The start task has "run as soon as possible after a missed start" turned off. If the PC was off at 1 AM, I don't want it shutting Jellyfin down at 7:30 when I boot up. The end task has it turned on, so if the PC was off at 8 AM it still brings things back after I sign in.
- **Late boot vs. Docker.** After a late boot the end task can fire before Docker Desktop is ready. The end script polls `docker info` for up to 10 minutes before it gives up and logs it.
- **No conflict with Gaming Mode.** Both scripts only stop or start containers that exist. Starting a container that's already running does nothing, so Gaming Mode OFF and downtime end can overlap safely ([gaming-mode.md](gaming-mode.md)).
- **Exit codes.** 0 means everything worked, 1 means Docker wasn't reachable, and 2 means something failed to stop or start. Task Scheduler's "Last Run Result" shows which one.

## Turning it off

```powershell
Disable-ScheduledTask -TaskName 'Homelab Downtime Start'
Disable-ScheduledTask -TaskName 'Homelab Downtime End'
```

`Enable-ScheduledTask` brings them back. `Unregister-ScheduledTask -TaskName '<name>' -Confirm:$false` removes them.

## First night

The first real run went clean. At 1:00 Jellyfin and the containers stopped and only DNS was left running. At 8:00 everything came back and the log showed every service UP.
