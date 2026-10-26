# Kamino server setup — spec for agent

Write an idempotent setup script that turns a clean Ubuntu Server install on the Mac mini into a Plex server with NAS media mounted permanently. Add it to the dotfiles repo.

## Context

- **Machine:** 2018 Mac mini (A1993, T2 chip), headless
- **OS:** Ubuntu Server 24.04 LTS, OpenSSH installed
- **Hostname / user:** `kamino` / `simun`, reached as `simun@kamino.local`
- **NAS:** Synology, shares exported over **NFS**
- **Dotfiles repo:** `github.com/Struki84/dotfiles`, cloned to `~/.dotfiles`
- **Location for this work:** new folder `~/.dotfiles/kamino/`

## Files to create

```
kamino/
├── setup.sh                                   # main entry, run with sudo
├── config.env.example                         # all settings, committed
├── systemd/
│   └── plexmediaserver.service.d/
│       └── override.conf                      # restart + mount dependency
└── README.md                                  # how to run, NAS prerequisites
```

`setup.sh` reads `kamino/config.env` (copied from the example by the user). If `config.env` is missing, copy the example, print a message telling the user to fill it in, and exit.

## config.env.example

```bash
HOSTNAME_TARGET="kamino"
NAS_HOST="192.168.1.XXX"             # Synology IP (prefer IP over .local for NFS)
NAS_EXPORT_ROOT="/volume1"           # Synology volume path
NAS_SHARES="movies tv music"         # space-separated share names
MOUNT_ROOT="/mnt/nas"                # each share mounts at $MOUNT_ROOT/<share>
NFS_MOUNT_OPTIONS="nfsvers=4.1,_netdev,nofail,noatime,x-systemd.automount,x-systemd.mount-timeout=30"
INSTALL_T2_REPO="false"              # optional T2 Mac support packages
```

## What setup.sh must do (in order)

1. **Preflight**
   - `#!/usr/bin/env bash` with `set -euo pipefail`
   - Exit with a clear message if not run as root or not on Ubuntu
   - Load `config.env`
   - Print each step as it runs

2. **Base packages and hostname**
   - `apt-get update`, install: `nfs-common curl gnupg ca-certificates avahi-daemon`
   - Set hostname to `$HOSTNAME_TARGET` with `hostnamectl` only if it differs
   - Enable `avahi-daemon` so `kamino.local` works

3. **Optional T2 support**
   - Only if `INSTALL_T2_REPO="true"`: add the t2-ubuntu-repo (github.com/AdityaGarg8/t2-ubuntu-repo) following its README
   - Skip silently otherwise

4. **Install Plex from the official apt repo**
   - Add Plex signing key to `/usr/share/keyrings/plex.gpg`
   - Add the repo to `/etc/apt/sources.list.d/plexmediaserver.list` with `signed-by=`
   - **Check current Plex docs for the exact key URL and repo line** before writing them in, since Plex has changed these before
   - `apt-get install -y plexmediaserver`
   - Skip key/repo steps if already present

5. **NFS mounts (permanent)**
   - For each share in `NAS_SHARES`: create `$MOUNT_ROOT/<share>`
   - Write entries into `/etc/fstab` inside a managed block:
     ```
     # BEGIN kamino-nas (managed by dotfiles/kamino/setup.sh)
     192.168.1.XXX:/volume1/movies  /mnt/nas/movies  nfs  <NFS_MOUNT_OPTIONS>  0 0
     # END kamino-nas
     ```
   - On re-run, replace the whole block (don't append duplicates). Back up fstab once before the first edit.
   - `systemctl daemon-reload`, then `mount -a`
   - Verify each mount with `findmnt`; warn (don't fail) if the NAS is unreachable

6. **Plex auto-restart and mount dependency**
   - Install `systemd/plexmediaserver.service.d/override.conf` to `/etc/systemd/system/plexmediaserver.service.d/override.conf`
   - Generate the `RequiresMountsFor=` line from `NAS_SHARES` (don't hardcode share names)
   - Content:
     ```ini
     [Unit]
     Wants=network-online.target
     After=network-online.target remote-fs.target
     RequiresMountsFor=/mnt/nas/movies /mnt/nas/tv /mnt/nas/music
     StartLimitIntervalSec=0

     [Service]
     Restart=always
     RestartSec=10
     ```
   - `systemctl daemon-reload`, `systemctl enable --now plexmediaserver`

7. **Verify and report**
   - `systemctl is-active plexmediaserver`
   - Each mount present in `findmnt`
   - `curl -s http://localhost:32400/identity` returns a response
   - Print a summary: what passed, what failed, and the next manual step (claiming the server, see README)

## Result of each piece

- **Override file:** Plex restarts 10 seconds after any crash or exit, retries forever, starts on boot, and waits for the network and NAS mounts.
- **fstab with `nofail` + `x-systemd.automount`:** mounts come back after every reboot; if the NAS is down, the server still boots and the share mounts as soon as it's accessed.
- **Managed fstab block:** re-running the script updates mounts instead of duplicating them.

## README.md must cover

**Synology prerequisites (manual, once):**
1. Control Panel → File Services → NFS → enable NFS (v4.1)
2. For each shared folder: Edit → NFS Permissions → Create:
   - Hostname/IP: kamino's IP
   - Privilege: Read-only (or Read/Write if Plex should manage files)
   - Squash: **Map all users to admin**
   - Tick: Allow users to access mounted subfolders

**Run on a fresh install:**
```bash
git clone https://github.com/Struki84/dotfiles ~/.dotfiles
cd ~/.dotfiles/kamino
cp config.env.example config.env && nano config.env
sudo ./setup.sh
```

**Claim the Plex server (first time, headless):**
```bash
ssh -L 8888:localhost:32400 simun@kamino.local
```
Then open `http://localhost:8888/web` on the desktop and sign in. Add libraries pointing at `/mnt/nas/<share>`.

## Rules for the agent

- Bash only, no extra dependencies beyond what's listed
- Fully idempotent: running twice changes nothing the second time
- Descriptive variable names, never single-letter
- Follow the existing structure and conventions of the dotfiles repo (look at `install.sh` / `setup.sh` at the repo root for style)
- No secrets in the repo; `config.env` with the real NAS IP may be committed or gitignored, ask the user
- Don't touch anything outside: apt sources, `/etc/fstab` managed block, `/etc/systemd/system/plexmediaserver.service.d/`, `$MOUNT_ROOT`, hostname
