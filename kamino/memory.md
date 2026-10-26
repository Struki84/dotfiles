# kamino — memory

Working notes for the kamino Plex server setup: the conversation that produced
it, what was built, and why. Read this first when picking the work back up.

## Chat history

**Session 1, 2026-10-26** (OpenCode agent, in `~/.dotfiles` on the Omarchy laptop)

1. **Request:** implement `kamino/kamino-setup-spec.md` (an idempotent `setup.sh`
   that turns a clean Ubuntu Server 24.04 install on the 2018 Mac mini into a
   Plex server with Synology shares mounted permanently; the spec says NFS,
   which later changed to SMB, see item 9), and write this `memory.md`.

2. **Research (plan mode, read-only):**
   - Read the repo's style from `quattro/setup.sh` and `quattro/install.sh`:
     `# SECTION ----` headers, small helpers like `link()`/`ensure_line()`,
     `echo` per step, `⚠`/`✗` markers, "Setup complete." at the end.
   - **Fetched the Plex docs, as the spec asked. They had changed:** with PMS
     1.43.0, Plex moved to a new repo and key. The spec's
     `/usr/share/keyrings/plex.gpg` + `plexmediaserver.list` are out of date.
     Current: key `PlexSign.v2.key` (fingerprint
     `6EFFEB478A6559D75C7C4FE706C521790B9CFFDE`), keyring
     `/etc/apt/keyrings/plexmediaserver.v2.gpg`, list
     `/etc/apt/sources.list.d/plex.list`, line
     `deb [signed-by=…] https://repo.plex.tv/deb/ public main`, and remove old
     `plex*` lists first.
   - Fetched the t2-ubuntu-repo README: a common repo plus a release-specific
     repo (`noble` for 24.04), key in `/etc/apt/trusted.gpg.d/`.

3. **Questions asked → answers:**
   | Question | Decision |
   |---|---|
   | Commit or gitignore `config.env` (real NAS IP)? | **Gitignore** (`kamino/config.env` added to root `.gitignore`) |
   | Spec's Plex paths or current Plex docs? | **Current Plex docs** |
   | T2: install packages too? | **Repos only**; packages are manual, documented in the README |

4. **"So I need to create the env file?"** Not now. The example is committed.
   On kamino you run `cp config.env.example config.env` and set the NAS IP. If
   you forget, the script copies it for you and exits. Because it's gitignored,
   creating it on the laptop wouldn't reach kamino.

5. **"My NAS runs as hostname `geonosis`, do I still need an IP?"** Checked from
   the laptop: `geonosis` and `geonosis.lan` don't resolve (the router's DNS
   doesn't know it). `geonosis.local` resolves only via mDNS, and to an **IPv6
   link-local** address (`fe80::9209:d0ff:fe21:bcb5`) first. IPv4 is
   **`192.168.1.9`**. Recommendation: use the IP plus a DHCP reservation.

6. **"OK so we can write the scripts now?"** The session was still in plan mode.
   Proposed defaults: `NAS_HOST="192.168.1.9"` in the example, a warn-only
   preflight NAS check, no shellcheck install.

7. **"lgtm, build it."** Built everything below.

8. **"I need Plex to be always restarted, I might not have access to the
   computer if it crashes."** This found a gap in the spec's design.
   `RequiresMountsFor=` makes the mounts a hard dependency. If the NAS is down
   at boot, the start job is *cancelled*, and `Restart=always` never fires for
   a cancelled job, so Plex would stay down until someone logged in.
   **Changed:** dropped `RequiresMountsFor=` and added an `ExecStartPre=`
   check that requires each share to be a real mount (NFS at the time, SMB
   since item 9). A failing pre-start
   counts as a failed start, so `Restart=always` + `StartLimitIntervalSec=0`
   retries every 10 s, forever, and Plex starts once the NAS is back. It still
   never starts against empty directories.
   Verified with a throwaway systemd user unit: 5 retries while the "NAS" was
   down, then active once it appeared, then back after a `SIGKILL`.
   (The session ran out of credits partway through and was resumed to finish
   the docs.)

9. **"I won't do the Synology NFS step; I didn't need it with my current setup
   (Plex on old macOS with the same drives mounted permanently)."** Probed
   geonosis from the laptop: **NFS 2049 and rpcbind 111 closed, SMB 445 and
   AFP 548 open**, so the Mac mounts over SMB/AFP and NFS would never have
   worked. Anonymous `smbclient -L` is refused (`LOGON_FAILURE`), so the share
   names couldn't be listed. Offered: enable NFS in DSM (recommended), switch
   to SMB, or support both. **User chose: switch to SMB, like the Mac.**
   **Changed:**
   - `cifs-utils` instead of `nfs-common`; fstab entries
     `//192.168.1.9/<share> … cifs credentials=/etc/kamino-nas.credentials,uid=plex,gid=plex,<NAS_MOUNT_OPTIONS>`.
   - Config: `NAS_EXPORT_ROOT` and `NFS_MOUNT_OPTIONS` removed; added
     `NAS_USERNAME` (default `simun`, an assumption) and `NAS_MOUNT_OPTIONS`.
   - The password is never in git or config. Preflight asks for it once (twice
     to confirm, hidden, from `/dev/tty`) and writes it root-only (mode 600) to
     `/etc/kamino-nas.credentials`. It's reused on later runs (unattended),
     asked again if `NAS_USERNAME` changes or with `--reset-credentials`.
     With no terminal, the script stops with a clear message.
   - The pre-start check and verify use fs types `cifs,smb3`; the preflight
     port check uses 445.
   - Preflight rejects `credentials/username/password/uid/gid` in
     `NAS_MOUNT_OPTIONS` (setup.sh owns those) and checks that the `plex` user
     exists before writing mounts.

## What was built

```
kamino/
├── kamino-setup-spec.md       # the original spec (input)
├── setup.sh                   # main entry, sudo ./setup.sh
├── config.env.example         # NAS_HOST=192.168.1.9 (geonosis), NAS_USERNAME, shares movies/tv/music
├── systemd/plexmediaserver.service.d/override.conf
├── README.md                  # prerequisites, run, claim, internals, troubleshooting
└── memory.md                  # this file
.gitignore                     # + kamino/config.env
```

On kamino the script touches: apt sources/keyrings, the `/etc/fstab` managed
block (+ a one-time `/etc/fstab.kamino.bak`), `/etc/kamino-nas.credentials`,
`/etc/systemd/system/plexmediaserver.service.d/`, `$MOUNT_ROOT`, and the
hostname. The credentials file was added for SMB; it's outside the spec's
original list.

### setup.sh structure
One function per spec step, run by `main()`. The script can be `source`d
without running anything (`BASH_SOURCE` guard), which is how it was tested.

1. `preflight`: checks root and Ubuntu (`/etc/os-release`). Copies the example
   config and exits if `config.env` is missing. Validates the settings (no
   `XXX` placeholder, share names `[A-Za-z0-9._-]`, `MOUNT_ROOT` an absolute
   path without spaces, no credential options in `NAS_MOUNT_OPTIONS`). Warns
   if `NAS_HOST` isn't IPv4 or port 445 doesn't answer (bash `/dev/tcp`, no
   extra tools). Ends with `ensure_credentials`, so the only prompt comes
   before anything slow.
2. `install_base`: apt packages, `hostnamectl` only if the name differs,
   `enable --now avahi-daemon`.
3. `install_t2_repo`: only if `INSTALL_T2_REPO=true`. Adds the key if missing
   and writes `t2.list` with fixed content (common + `$VERSION_CODENAME` line)
   instead of upstream's `tee -a`, which isn't idempotent.
4. `install_plex`: removes stale `plex*` lists (before and after the install,
   in case the package drops its own). Adds the key if missing, checking the
   **fingerprint**. Writes `plex.list` only if it differs. Runs
   `apt-get update` only when sources changed.
5. `configure_mounts`: `mkdir` mount points, then compares the existing
   managed block with the generated one; if they're identical, nothing
   happens. Otherwise: backs up `/etc/fstab.kamino.bak` once, stops the
   `.automount`/`.mount` units of the **old** block's mount points, removes the
   old block with `awk`, appends the new one, and writes via `cat >` (keeps the
   inode and permissions). Refuses to touch a broken block (BEGIN/END counts
   mismatch). If the block changes while Plex is running, Plex is stopped
   first so the old mounts aren't busy; step 6 starts it again.
   Then `daemon-reload`, starts the generated `.automount` units
   (or `.mount` if automount was removed from the options), accesses each path
   to trigger it, and checks `findmnt -t cifs,smb3`. Warns only, pointing at
   `journalctl -k --grep CIFS` and `--reset-credentials`.
6. `configure_plex_service`: renders `override.conf` from the repo template,
   replacing the `@KAMINO_MOUNT_POINTS@` and `@KAMINO_FS_TYPES@` placeholders
   (used in the `ExecStartPre=` check) with values from config. Installs
   it only if it differs. Then `daemon-reload` and `enable --now`; if the NAS
   is down this warns, and systemd keeps retrying by itself. If the override
   changed while Plex was running, also `restart`. `MOUNT_ROOT` is validated
   to `^/[A-Za-z0-9._/-]+$`, because the paths go unquoted into the unit's
   shell loop.
7. `verify`: `is-active`, `findmnt` per share (no re-trigger, so an
   unreachable NAS doesn't cost another 30 s per share), and polls `/identity`
   for up to about 30 s. Prints PASS/FAIL and the claim instructions. Exit 2
   if anything failed.

### Deviations from the spec (on purpose)
- **SMB instead of NFS:** geonosis has NFS off and the user doesn't want NAS
  changes (chat item 9). Needs a stored password: root-only
  `/etc/kamino-nas.credentials`.
- **Plex paths:** current Plex docs instead of the spec's (user decision; the
  spec itself said to check the docs).
- **No `mount -a`:** the spec says `daemon-reload` then `mount -a`. But
  util-linux `mount -a` ignores `x-systemd.automount` and would stack a direct
  mount over the systemd automount. The script starts the generated
  `.automount` units instead. Same effect, done the systemd way.
- **Shebang/flags:** `#!/usr/bin/env bash` + `set -euo pipefail` per the spec,
  although the repo's other scripts use `#!/bin/bash` + `set -eEo pipefail`.
- **No `RequiresMountsFor=`:** replaced by the `ExecStartPre=` mount check
  (user requirement: Plex must always come back without anyone logging in).
  See chat item 8.
- Additions not in the spec: Plex key fingerprint check, NAS port preflight
  warning, broken-fstab-block guard, cleanup of old mounts when shares change,
  `--reset-credentials`/`--help`, exit code 2 on failed checks.

### Restart behaviour (the requirement)
| Situation | Result |
|---|---|
| Plex crashes / killed / exits | restarted after 10 s, forever |
| Reboot | starts on boot after the network |
| NAS down at boot | pre-start check fails, retried every ~10 s, starts when the shares mount |
| NAS drops while running | Plex keeps running; automount reconnects on access |
| `systemctl stop plexmediaserver` | stays down (deliberate) until the next boot |

Not covered yet: Plex *hanging* without exiting, a kernel panic or OS freeze,
and power loss (the Mac mini must be set to power on by itself). See the open
items.

## Verification done (on the laptop, not on kamino)
- `bash -n setup.sh`: OK. Shellcheck isn't installed; it was not run.
- Sourced the script under bash and ran the fstab functions against a temp
  file. Run 1 writes, run 2 makes no change (byte-identical), changing the
  shares replaces the block (no duplicates), reverting gives back the run-1
  file byte-for-byte, and other fstab lines are kept.
- `render_override` fills the mount points into `ExecStartPre=`, and
  `systemd-analyze verify` accepts the drop-in against a stub unit.
- The pre-start shell check (with `$$` unescaped the way systemd does it)
  exits 1 for plain directories and 0 for real mounts.
- Restart-forever behaviour checked with a transient `systemd-run --user`
  unit (see chat item 8).
- `write_file_if_changed`: writes the first time, unchanged the second.
- Downloaded the real Plex key: fingerprint check passes, and a wrong
  fingerprint is rejected. The T2 key dearmors.
- `remove_stale_plex_sources` removes `plexmediaserver.list`, keeps
  `plex.list` and other files, and does nothing on the second run.
- Live URLs: `repo.plex.tv/deb/dists/public/Release` has amd64; the T2 `noble`
  release URL resolves.
- `git check-ignore` confirms `kamino/config.env` is ignored.
- After the SMB switch: the cifs fstab block renders and is idempotent; the
  override with `cifs,smb3` passes `systemd-analyze verify`. Credentials,
  tested under a pseudo-terminal: mismatched entries ask again; a password
  with spaces, commas and `=` is stored exactly, mode 600; an existing file
  for the same user is kept without a prompt; a changed username asks again;
  with no terminal it stops with a clear message. (That last check found and
  fixed a bug: `[[ -r /dev/tty ]]` is true even without a terminal, so it now
  actually opens `/dev/tty`.)

**Not yet tested:** a real run on kamino (systemd, apt, SMB mount, Plex).

## Open items / next steps
- [ ] Confirm the exact Synology share names (case-sensitive) and the Synology
      username the Mac uses, and set `NAS_SHARES` / `NAS_USERNAME` in
      `config.env` on kamino. The defaults `movies tv music` / `simun` are guesses.
- [ ] Optional: a dedicated read-only Synology user for kamino, instead of the
      main account.
- [ ] Router: DHCP reservation for geonosis (`192.168.1.9`), and ideally for kamino.
- [ ] On kamino: clone, `cp config.env.example config.env`, `sudo ./setup.sh`,
      then run it **again** to confirm the second run changes nothing.
- [ ] Claim Plex through the SSH tunnel and add libraries at `/mnt/nas/<share>`.
- [ ] Optional: install shellcheck and lint `setup.sh`.
- [ ] In Plex: untick *Settings → Library → Empty trash automatically after
      every scan* (protects the library during NAS outages).
- [ ] On kamino, test unattended recovery: `sudo kill -9 $(pidof "Plex Media Server")`
      should be back in ~10 s; reboot with the NAS off, then turn the NAS on,
      and Plex should start by itself.
- [ ] Undecided (outside the spec's allowed paths, ask first): a health-check
      timer that restarts Plex if `/identity` stops answering (hang), sysctl
      `kernel.panic=10` (auto-reboot on kernel panic), and power-on after
      power loss on the Mac mini.
- [ ] Not committed yet. The repo also has unrelated uncommitted changes in
      `omarchy/` and `quattro/`; commit `kamino/` + `.gitignore` separately.
