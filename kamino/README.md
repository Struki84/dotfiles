# kamino

Setup for **kamino**, a 2018 Mac mini (A1993, T2) running headless Ubuntu Server
24.04. It runs Plex Media Server and gets its media from a Synology NAS over
**SMB**, the same way the old macOS Plex server did. Nothing needs to change on
the NAS.

The NAS IP and username are deliberately **not** in this repo. They live only
in the gitignored `config.env` on kamino. Placeholders below: `<NAS_IP>`,
`<user>`.

`setup.sh` takes a clean Ubuntu Server install (with OpenSSH) to a working Plex
server with the NAS shares mounted permanently. It is idempotent: re-running it
after a `git pull` or a config change updates things, and running it again
changes nothing.

```
kamino/
├── setup.sh                 # main entry, run with sudo
├── config.env.example       # all settings (committed)
├── config.env               # your copy (gitignored)
├── systemd/plexmediaserver.service.d/override.conf
└── README.md
```

## 1. Before you start

Nothing to set up on the Synology: SMB is already on (the Mac uses it). Have
these ready:

- **NAS IP:** a fixed IPv4 address. Recommended: a **DHCP reservation** for the
  NAS, and ideally for kamino, in the router so the IPs never change.
- **Share names:** the Synology shared folder names, exactly as in Finder on
  the Mac (*Go → Connect to Server → smb://<NAS_IP>*) or in DSM under
  *Control Panel → Shared Folder*. They are case-sensitive (`Movies` ≠ `movies`),
  and spaces are fine (see below).
- **Synology username and password:** the account the Mac logs in with. It
  needs at least read access to those shares.

Optional and safer: create a dedicated Synology user (e.g. `kamino`) with
**read-only** access to the media shares, and use that instead of your own
account. Then the password stored on kamino can only read media.

### Share names and local folders
`NAS_SHARES` is a bash array with one quoted name per share:

```bash
NAS_SHARES=("Data" "Movie Library" "TV Library" "Music Library")
```

Each share mounts at a folder named after it, in lowercase with dashes, so the
local paths never contain spaces (easier over SSH, in Plex, and in systemd):

| Synology share | Mounted at |
|---|---|
| `Data` | `/mnt/nas/data` |
| `Movie Library` | `/mnt/nas/movie-library` |
| `TV Library` | `/mnt/nas/tv-library` |
| `Music Library` | `/mnt/nas/music-library` |

Accents are simplified (`Čarobni` → `carobni`). The script stops with a clear
message if a name contains `/ \ , "`, or if two shares would land on the same
folder. **Plex only starts once every listed share is mounted.**

## 2. Run on a fresh install

```bash
git clone https://github.com/Struki84/dotfiles ~/.dotfiles
cd ~/.dotfiles/kamino
cp config.env.example config.env && nano config.env   # NAS_HOST, NAS_USERNAME, NAS_SHARES
sudo ./setup.sh
```

If you skip the copy, the first run creates `config.env` from the example, asks
you to fill it in, and exits.

On the first run it asks for the **Synology password** (twice, not echoed) and
stores it in `/etc/kamino-nas.credentials` (root-only, mode 600, never in git).
Later runs reuse it and run unattended. To change it, run
`sudo ./setup.sh --reset-credentials`.

What it does, in order:

1. **Preflight:** checks for root and Ubuntu, loads `config.env`, warns
   (without stopping) if the NAS doesn't answer on SMB port 445, and asks for
   the NAS password if it isn't stored yet.
2. **Base:** installs `cifs-utils curl gnupg ca-certificates avahi-daemon`,
   sets the hostname if it differs, and enables Avahi so `kamino.local`
   resolves.
3. **T2 repos** (only if `INSTALL_T2_REPO="true"`). See below.
4. **Plex:** adds the official Plex apt repo and installs `plexmediaserver`
   (this creates the `plex` user the mounts belong to).
5. **SMB:** creates the mount folders, writes a managed block into
   `/etc/fstab`, and brings the mounts up.
6. **Plex service:** installs the systemd override and enables and starts Plex.
7. **Verify:** checks that Plex is active, the mounts are present, and
   `/identity` answers, then prints a PASS/FAIL summary. Exit code 2 if a check
   failed.

To add or remove a share, edit `NAS_SHARES` and re-run. The fstab block and the
Plex mount check are regenerated, and Plex is stopped briefly while the mounts
change. Mount directories of removed shares are left in place (empty).

## 3. Claim the Plex server (first time, headless)

From your desktop:

```bash
ssh -L 8888:localhost:32400 <user>@kamino.local
```

Then open <http://localhost:8888/web>, sign in, and claim the server. Plex only
allows the unclaimed setup from localhost, which is why you need the tunnel. Add
libraries pointing at the mount folders, e.g. `/mnt/nas/movie-library`,
`/mnt/nas/tv-library`, `/mnt/nas/music-library` (`setup.sh` prints the list at
the end). After that the server is reachable normally at
`http://kamino.local:32400/web`.

## How it works

### Plex apt repo
This follows [Plex's current instructions][plex-repo]. The repo changed with
PMS 1.43.0:

| | |
|---|---|
| Key | `https://downloads.plex.tv/plex-keys/PlexSign.v2.key`, checked against fingerprint `6EFFEB47…0B9CFFDE` |
| Keyring | `/etc/apt/keyrings/plexmediaserver.v2.gpg` |
| Source | `/etc/apt/sources.list.d/plex.list`: `deb [signed-by=…] https://repo.plex.tv/deb/ public main` |

Any other `/etc/apt/sources.list.d/plex*` file (the old repo, or a list dropped
by the package) is removed, so apt doesn't hit *Conflicting values for
Signed-By*. Plex updates then come with `apt upgrade`.

### Managed fstab block
```
# BEGIN kamino-nas (managed by dotfiles/kamino/setup.sh)
//<NAS_IP>/Data  /mnt/nas/data  cifs  credentials=/etc/kamino-nas.credentials,uid=plex,gid=plex,file_mode=0644,dir_mode=0755,iocharset=utf8,_netdev,nofail,x-systemd.automount,x-systemd.mount-timeout=30  0 0
//<NAS_IP>/Movie\040Library  /mnt/nas/movie-library  cifs  credentials=…  0 0
# END kamino-nas
```
- Spaces in share names are written as `\040`, fstab's escape for a space,
  because fstab separates its fields with whitespace. `mount` and systemd read
  it back as `Movie Library`.
- On every run the whole block is replaced, never appended. If it's already
  correct, fstab isn't touched.
- The original fstab is backed up **once** to `/etc/fstab.kamino.bak` before
  the first edit.
- Don't edit lines inside the block by hand; change `config.env` instead.
- `credentials=` keeps the password out of fstab, which any user can read.
  `uid=plex,gid=plex` makes Plex the owner of everything on the shares, so it
  can always read them. `setup.sh` adds these three options itself;
  `NAS_MOUNT_OPTIONS` holds the rest.
- `nofail` + `x-systemd.automount` mean the server still boots if the NAS is
  down, and a share mounts on first access once the NAS is back.
- The SMB protocol version is negotiated automatically (SMB 3.x with DSM's
  defaults). To pin it, add e.g. `vers=3.0` to `NAS_MOUNT_OPTIONS`.
- The script brings mounts up by starting the systemd automount units generated
  from fstab, instead of running `mount -a`. `mount -a` doesn't know about
  `x-systemd.automount` and would stack a direct mount on top of the
  automount.

### Plex systemd override
`/etc/systemd/system/plexmediaserver.service.d/override.conf` (generated from
`systemd/…/override.conf`, with mount points from `NAS_SHARES`):
```ini
[Unit]
Wants=network-online.target
After=network-online.target remote-fs.target
StartLimitIntervalSec=0

[Service]
ExecStartPre=+/bin/sh -c '…every mount folder must be a real SMB (cifs) mount, else exit 1…'
Restart=always
RestartSec=10
```

**Plex always comes back on its own; no one needs to log in:**

| Situation | What happens |
|---|---|
| Plex crashes, is killed, or exits | restarted after 10 s, forever (`StartLimitIntervalSec=0`) |
| Reboot / power back on | starts on boot after the network |
| NAS down at boot (or NAS reboots while kamino boots) | the pre-start check fails, systemd retries every ~10 s, and Plex starts as soon as the shares mount |
| NAS goes away while Plex runs | Plex keeps running; the shares reconnect on next access |

Why `ExecStartPre` and not `RequiresMountsFor=` (the spec's original
version): with a hard mount dependency, a NAS that's down at boot **cancels**
Plex's start job, and `Restart=` never fires for a cancelled job. Plex would
stay down until someone logged in. A failing `ExecStartPre` counts as a
failed start, so `Restart=always` keeps retrying. Plex still never starts
against empty mount directories.

Only `systemctl stop plexmediaserver` keeps it down (until the next boot).

Recommended Plex setting: **Settings → Library → untick "Empty trash
automatically after every scan"**, so a scan during a NAS outage can't drop
items from the library.

### Optional T2 support
With `INSTALL_T2_REPO="true"`, the script adds the [t2-ubuntu-repo][t2-repo]
common repo and the release-specific repo for your Ubuntu codename (`noble`)
in `/etc/apt/sources.list.d/t2.list`, with the key in
`/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg`. **No packages are installed.** The
stock Ubuntu kernel is enough for a headless Mac mini. If you want more, install
by hand, for example:

```bash
sudo apt install t2fanrd         # fan control daemon
sudo apt install linux-t2        # T2 kernel (has apple-bce etc. built in)
```

Don't combine `linux-t2` with the `apple-bce` / `applesmc-t2` / `apfs-dkms`
packages. After a release upgrade, re-run `setup.sh` so the release repo
follows the new codename.

## Why an IP and not `<nas-name>.local`
A Synology without a DNS entry on the router is only reachable by name through
mDNS, and `<nas-name>.local` resolves to an **IPv6 link-local** address first.
That's unreliable for a boot-time mount, and mDNS also has to be ready at boot.
If you still want the name, set `NAS_HOST="<nas-name>.local"`. Not recommended.

## Why SMB and not NFS
The original spec used NFS. The NAS has NFS turned off, and enabling it needs
per-share permission rules in DSM. SMB is already on and is what the old Mac
used, so kamino uses it too. The cost: kamino has to store a Synology password
(root-only file; see the dedicated read-only user tip in section 1).

## Troubleshooting

```bash
systemctl status plexmediaserver                     # "activating (auto-restart)" = waiting for NAS
journalctl -u plexmediaserver -b                     # shows "NAS share … not mounted yet" while waiting
findmnt -t cifs,smb3                                 # what's mounted
systemctl status 'mnt-nas-movie\x2dlibrary.automount' 'mnt-nas-movie\x2dlibrary.mount'   # (- is \x2d in unit names)
journalctl -b -k --grep CIFS                         # kernel SMB errors (login, share name)
sudo mkdir -p /mnt/test && sudo mount -t cifs "//<NAS_IP>/Movie Library" /mnt/test -o credentials=/etc/kamino-nas.credentials   # manual test (quote names with spaces)
curl -s http://localhost:32400/identity
```

- **`Permission denied` / `STATUS_LOGON_FAILURE`**: wrong username or
  password. Fix `NAS_USERNAME` in `config.env`, or run
  `sudo ./setup.sh --reset-credentials`.
- **`No such file or directory` on mount**: the share name in `NAS_SHARES`
  doesn't match the Synology folder (check the case and the spaces).
- **Plex can't see files**: the Synology account lacks read permission on
  that shared folder (DSM → Shared Folder → Edit → Permissions).
- **Restore fstab**: `sudo cp /etc/fstab.kamino.bak /etc/fstab && sudo systemctl daemon-reload`.

[plex-repo]: https://support.plex.tv/articles/235974187-enable-repository-updating-for-supported-linux-server-distributions/
[t2-repo]: https://github.com/AdityaGarg8/t2-ubuntu-repo
