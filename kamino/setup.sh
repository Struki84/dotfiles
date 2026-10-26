#!/usr/bin/env bash
# Kamino (2018 Mac mini, Ubuntu Server 24.04) -> Plex server with NAS media on SMB.
# Idempotent: safe to re-run; a second run changes nothing.
#   sudo ./setup.sh                       normal run (asks for the NAS password once)
#   sudo ./setup.sh --reset-credentials   ask for the NAS password again
# Settings come from kamino/config.env (copied from config.env.example).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"
CONFIG_EXAMPLE_FILE="$SCRIPT_DIR/config.env.example"
OVERRIDE_TEMPLATE="$SCRIPT_DIR/systemd/plexmediaserver.service.d/override.conf"

FSTAB_PATH="/etc/fstab"
FSTAB_BACKUP_PATH="/etc/fstab.kamino.bak"
FSTAB_BLOCK_BEGIN="# BEGIN kamino-nas (managed by dotfiles/kamino/setup.sh)"
FSTAB_BLOCK_END="# END kamino-nas"

# SMB login for the NAS. Root-only, never in git; created by the password prompt.
CREDENTIALS_PATH="/etc/kamino-nas.credentials"
# Filesystem types findmnt reports for SMB mounts.
SHARE_FS_TYPES="cifs,smb3"
# Plex runs as this user; mounted files are presented as owned by it.
PLEX_SERVICE_USER="plex"

APT_SOURCES_DIR="/etc/apt/sources.list.d"
APT_KEYRINGS_DIR="/etc/apt/keyrings"

# Plex repo, per https://support.plex.tv/articles/235974187 (repo changed with PMS 1.43.0)
PLEX_KEY_URL="https://downloads.plex.tv/plex-keys/PlexSign.v2.key"
PLEX_KEY_FINGERPRINT="6EFFEB478A6559D75C7C4FE706C521790B9CFFDE"
PLEX_KEYRING_PATH="$APT_KEYRINGS_DIR/plexmediaserver.v2.gpg"
PLEX_SOURCE_LIST_PATH="$APT_SOURCES_DIR/plex.list"
PLEX_SOURCE_LINE="deb [signed-by=$PLEX_KEYRING_PATH] https://repo.plex.tv/deb/ public main"
PLEX_OVERRIDE_DIR="/etc/systemd/system/plexmediaserver.service.d"
PLEX_OVERRIDE_PATH="$PLEX_OVERRIDE_DIR/override.conf"
PLEX_IDENTITY_URL="http://localhost:32400/identity"

# T2 repo, per https://github.com/AdityaGarg8/t2-ubuntu-repo README
T2_KEY_URL="https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg"
T2_KEYRING_PATH="/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg"
T2_SOURCE_LIST_PATH="$APT_SOURCES_DIR/t2.list"

BASE_PACKAGES=(cifs-utils curl gnupg ca-certificates avahi-daemon)

RESET_CREDENTIALS=false
PASSED_CHECKS=()
FAILED_CHECKS=()
MOUNT_POINTS=()
TEMP_DIR=""

# HELPERS ---------------------------------------------------------------------
step() { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    ⚠ %s\n' "$*" >&2; }
die() {
  printf '✗ %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n $TEMP_DIR && -d $TEMP_DIR ]]; then rm -rf "$TEMP_DIR"; fi
}

# Write content to a file only if it differs. Returns 0 if written, 1 if unchanged.
write_file_if_changed() {
  local desired_content=$1 destination_path=$2
  if [[ -f $destination_path ]] && [[ "$(cat "$destination_path")" == "$desired_content" ]]; then
    return 1
  fi
  mkdir -p "$(dirname "$destination_path")"
  printf '%s\n' "$desired_content" >"$destination_path"
  chmod 644 "$destination_path"
  return 0
}

# Download an armored key, optionally check its fingerprint, dearmor to a keyring.
install_keyring() {
  local key_url=$1 keyring_path=$2 expected_fingerprint=${3:-}
  local downloaded_key="$TEMP_DIR/$(basename "$keyring_path").asc"

  curl -fsSL --compressed "$key_url" -o "$downloaded_key"
  if [[ -n $expected_fingerprint ]]; then
    if ! gpg --show-keys --with-colons "$downloaded_key" 2>/dev/null |
      grep -q "^fpr:*${expected_fingerprint}:"; then
      die "Key from $key_url does not match fingerprint $expected_fingerprint"
    fi
  fi
  mkdir -p "$(dirname "$keyring_path")"
  gpg --batch --yes --dearmor -o "$keyring_path" "$downloaded_key"
  chmod 644 "$keyring_path"
}

mount_unit_name() { systemd-escape --path --suffix="$2" "$1"; }

share_is_mounted() { findmnt -n -t "$SHARE_FS_TYPES" --mountpoint "$1" >/dev/null 2>&1; }

# Access the path so x-systemd.automount mounts it, then check findmnt.
trigger_and_check_mount() {
  local mount_point=$1
  timeout -k 5 40 ls "$mount_point" >/dev/null 2>&1 || true
  share_is_mounted "$mount_point"
}

# Options for every share: login + Plex ownership first, then the user's options.
full_mount_options() {
  printf 'credentials=%s,uid=%s,gid=%s,%s' \
    "$CREDENTIALS_PATH" "$PLEX_SERVICE_USER" "$PLEX_SERVICE_USER" "$NAS_MOUNT_OPTIONS"
}

# Print the current managed block from fstab (empty if none).
read_fstab_block() {
  awk -v begin="$FSTAB_BLOCK_BEGIN" -v end="$FSTAB_BLOCK_END" '
    $0 == begin { inside = 1 }
    inside      { print }
    $0 == end   { inside = 0 }
  ' "$FSTAB_PATH"
}

build_fstab_block() {
  local share_name mount_options
  mount_options="$(full_mount_options)"
  printf '%s\n' "$FSTAB_BLOCK_BEGIN"
  for share_name in "${NAS_SHARE_LIST[@]}"; do
    printf '//%s/%s  %s/%s  cifs  %s  0 0\n' \
      "$NAS_HOST" "$share_name" "$MOUNT_ROOT" "$share_name" "$mount_options"
  done
  printf '%s' "$FSTAB_BLOCK_END"
}

# Username from config, password typed once; stored root-only for mount.cifs.
# Kept as-is on re-runs unless the username changed or --reset-credentials.
ensure_credentials() {
  step "NAS login (SMB credentials in $CREDENTIALS_PATH)"

  if [[ $RESET_CREDENTIALS == "false" && -f $CREDENTIALS_PATH ]] &&
    grep -qxF "username=$NAS_USERNAME" "$CREDENTIALS_PATH"; then
    chmod 600 "$CREDENTIALS_PATH"
    chown root:root "$CREDENTIALS_PATH"
    info "already present for user $NAS_USERNAME"
    return 0
  fi

  # Actually open the terminal: /dev/tty is "readable" even without one.
  { : </dev/tty; } 2>/dev/null ||
    die "Need the NAS password for $NAS_USERNAME but there is no terminal. Run setup.sh interactively."

  local nas_password password_confirmation
  while true; do
    IFS= read -r -s -p "    Synology password for '$NAS_USERNAME' on $NAS_HOST: " nas_password </dev/tty
    printf '\n'
    IFS= read -r -s -p "    Repeat password: " password_confirmation </dev/tty
    printf '\n'
    [[ -n $nas_password && $nas_password == "$password_confirmation" ]] && break
    warn "passwords were empty or didn't match; try again"
  done

  (
    umask 077
    printf 'username=%s\npassword=%s\n' "$NAS_USERNAME" "$nas_password" >"$CREDENTIALS_PATH"
  )
  chown root:root "$CREDENTIALS_PATH"
  info "saved (root-only, mode 600)"
}

# Replace (or append) the managed block, keeping every other fstab line intact.
write_fstab_block() {
  local new_block=$1
  local stripped_fstab="$TEMP_DIR/fstab.stripped"

  awk -v begin="$FSTAB_BLOCK_BEGIN" -v end="$FSTAB_BLOCK_END" '
    $0 == begin { skipping = 1; next }
    $0 == end   { skipping = 0; next }
    !skipping   { print }
  ' "$FSTAB_PATH" >"$stripped_fstab"

  # Drop trailing blank lines so repeated edits don't grow the file.
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$stripped_fstab"

  {
    cat "$stripped_fstab"
    printf '\n%s\n' "$new_block"
  } >"$FSTAB_PATH.kamino.tmp"
  # cat > keeps the original file's owner, mode and inode.
  cat "$FSTAB_PATH.kamino.tmp" >"$FSTAB_PATH"
  rm -f "$FSTAB_PATH.kamino.tmp"
}

render_override() {
  local mount_point_list="${MOUNT_POINTS[*]}"
  local template_line rendered_line
  while IFS= read -r template_line || [[ -n $template_line ]]; do
    rendered_line="${template_line//@KAMINO_MOUNT_POINTS@/$mount_point_list}"
    printf '%s\n' "${rendered_line//@KAMINO_FS_TYPES@/$SHARE_FS_TYPES}"
  done <"$OVERRIDE_TEMPLATE"
}

record_check() {
  local check_name=$1 check_passed=$2
  if [[ $check_passed == "true" ]]; then
    PASSED_CHECKS+=("$check_name")
  else
    FAILED_CHECKS+=("$check_name")
  fi
}

# 1. PREFLIGHT ----------------------------------------------------------------
preflight() {
  step "Preflight checks"

  [[ $EUID -eq 0 ]] || die "Run as root:  sudo $0"

  local os_id
  os_id="$(. /etc/os-release && echo "${ID:-}")"
  [[ $os_id == "ubuntu" ]] || die "This script is for Ubuntu (found: ${os_id:-unknown})."
  OS_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"

  if [[ ! -f $CONFIG_FILE ]]; then
    cp "$CONFIG_EXAMPLE_FILE" "$CONFIG_FILE"
    [[ -n ${SUDO_USER:-} ]] && chown "$SUDO_USER": "$CONFIG_FILE"
    printf '✗ No config found. Created %s from the example.\n' "$CONFIG_FILE" >&2
    printf '  Fill it in (NAS_HOST, NAS_SHARES, ...), then re-run:  sudo %s\n' "$0" >&2
    exit 1
  fi

  # shellcheck source=config.env.example
  source "$CONFIG_FILE"

  local required_setting
  for required_setting in HOSTNAME_TARGET NAS_HOST NAS_USERNAME NAS_SHARES \
    MOUNT_ROOT NAS_MOUNT_OPTIONS INSTALL_T2_REPO; do
    [[ -n ${!required_setting:-} ]] || die "$required_setting is not set in $CONFIG_FILE"
  done
  [[ $NAS_HOST == *XXX* ]] && die "NAS_HOST still has the placeholder value; edit $CONFIG_FILE"
  [[ $NAS_MOUNT_OPTIONS =~ (^|,)(credentials|username|user|password|pass|uid|gid)= ]] &&
    die "NAS_MOUNT_OPTIONS must not set credentials/username/password/uid/gid; setup.sh adds those"

  MOUNT_ROOT="${MOUNT_ROOT%/}"
  # Mount points end up unquoted in fstab and in the override's shell loop.
  [[ $MOUNT_ROOT =~ ^/[A-Za-z0-9._/-]+$ ]] ||
    die "MOUNT_ROOT must be an absolute path without spaces (got '$MOUNT_ROOT')"

  read -r -a NAS_SHARE_LIST <<<"$NAS_SHARES"
  [[ ${#NAS_SHARE_LIST[@]} -gt 0 ]] || die "NAS_SHARES is empty in $CONFIG_FILE"
  local share_name
  for share_name in "${NAS_SHARE_LIST[@]}"; do
    [[ $share_name =~ ^[A-Za-z0-9._-]+$ ]] ||
      die "Share name '$share_name' in NAS_SHARES may only use letters, digits, . _ - (no spaces)"
    MOUNT_POINTS+=("$MOUNT_ROOT/$share_name")
  done

  if [[ ! $NAS_HOST =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
    warn "NAS_HOST '$NAS_HOST' is not an IPv4 address; an IP is more reliable at boot (see README)."
  fi
  if timeout 5 bash -c ": </dev/tcp/$NAS_HOST/445" 2>/dev/null; then
    info "NAS $NAS_HOST answers on SMB port 445"
  else
    warn "NAS $NAS_HOST does not answer on port 445; mounts will be set up but may not come up yet."
  fi

  info "config: $CONFIG_FILE"
  info "shares: ${NAS_SHARE_LIST[*]} -> $MOUNT_ROOT/<share> (SMB as $NAS_USERNAME)"

  # Ask for the password now, so the rest of the run needs no one at the keyboard.
  ensure_credentials
}

# 2. BASE PACKAGES AND HOSTNAME -----------------------------------------------
install_base() {
  step "Installing base packages: ${BASE_PACKAGES[*]}"
  apt-get update -q
  apt-get install -y -q "${BASE_PACKAGES[@]}"

  step "Setting hostname"
  local current_hostname
  current_hostname="$(hostnamectl hostname --static 2>/dev/null || cat /etc/hostname)"
  if [[ $current_hostname == "$HOSTNAME_TARGET" ]]; then
    info "already $HOSTNAME_TARGET"
  else
    hostnamectl set-hostname "$HOSTNAME_TARGET"
    info "changed $current_hostname -> $HOSTNAME_TARGET"
  fi

  step "Enabling avahi-daemon ($HOSTNAME_TARGET.local)"
  systemctl enable --now avahi-daemon
}

# 3. OPTIONAL T2 SUPPORT ------------------------------------------------------
install_t2_repo() {
  [[ $INSTALL_T2_REPO == "true" ]] || return 0
  step "Adding T2 Mac apt repos (common + $OS_CODENAME)"

  local t2_sources_changed=false
  if [[ ! -s $T2_KEYRING_PATH ]]; then
    install_keyring "$T2_KEY_URL" "$T2_KEYRING_PATH"
    t2_sources_changed=true
  fi

  local t2_source_content
  t2_source_content="deb [signed-by=$T2_KEYRING_PATH] https://adityagarg8.github.io/t2-ubuntu-repo ./
deb [signed-by=$T2_KEYRING_PATH] https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/$OS_CODENAME ./"
  if write_file_if_changed "$t2_source_content" "$T2_SOURCE_LIST_PATH"; then
    t2_sources_changed=true
  fi

  if [[ $t2_sources_changed == "true" ]]; then
    apt-get update -q
    info "T2 repos added; no packages installed (see README)"
  else
    info "already present"
  fi
}

# 4. PLEX MEDIA SERVER --------------------------------------------------------
# Remove old/duplicate Plex source lists (pre-1.43 repo, or ones the package drops).
remove_stale_plex_sources() {
  local source_file removed_any=1
  for source_file in "$APT_SOURCES_DIR"/plex*; do
    [[ -e $source_file ]] || continue
    [[ $source_file == "$PLEX_SOURCE_LIST_PATH" ]] && continue
    rm -f "$source_file"
    info "removed stale source $source_file"
    removed_any=0
  done
  return "$removed_any"
}

install_plex() {
  step "Installing Plex Media Server from the official repo"

  local plex_sources_changed=false
  if remove_stale_plex_sources; then plex_sources_changed=true; fi

  if [[ ! -s $PLEX_KEYRING_PATH ]]; then
    install_keyring "$PLEX_KEY_URL" "$PLEX_KEYRING_PATH" "$PLEX_KEY_FINGERPRINT"
    info "added signing key $PLEX_KEYRING_PATH"
    plex_sources_changed=true
  fi

  if write_file_if_changed "$PLEX_SOURCE_LINE" "$PLEX_SOURCE_LIST_PATH"; then
    info "wrote $PLEX_SOURCE_LIST_PATH"
    plex_sources_changed=true
  fi

  [[ $plex_sources_changed == "true" ]] && apt-get update -q
  apt-get install -y -q plexmediaserver

  if remove_stale_plex_sources; then apt-get update -q; fi
}

# 5. SMB MOUNTS ---------------------------------------------------------------
configure_mounts() {
  step "Configuring SMB mounts in $FSTAB_PATH"

  id "$PLEX_SERVICE_USER" >/dev/null 2>&1 ||
    die "User '$PLEX_SERVICE_USER' not found; the plexmediaserver package should have created it."

  local mount_point
  for mount_point in "${MOUNT_POINTS[@]}"; do
    [[ -d $mount_point ]] || { mkdir -p "$mount_point" && info "created $mount_point"; }
  done

  local begin_count end_count
  begin_count="$(grep -cxF "$FSTAB_BLOCK_BEGIN" "$FSTAB_PATH" || true)"
  end_count="$(grep -cxF "$FSTAB_BLOCK_END" "$FSTAB_PATH" || true)"
  if [[ $begin_count -gt 1 || $begin_count -ne $end_count ]]; then
    die "$FSTAB_PATH has a broken kamino-nas block (BEGIN=$begin_count END=$end_count); fix it by hand."
  fi

  local current_block new_block
  current_block="$(read_fstab_block)"
  new_block="$(build_fstab_block)"

  if [[ $current_block == "$new_block" ]]; then
    info "managed block already up to date"
  else
    if [[ ! -e $FSTAB_BACKUP_PATH ]]; then
      cp -a "$FSTAB_PATH" "$FSTAB_BACKUP_PATH"
      info "backed up $FSTAB_PATH -> $FSTAB_BACKUP_PATH"
    fi

    # Unmount entries from the old block so changed/removed shares don't linger.
    # Stop Plex first so it doesn't keep the shares busy; step 6 starts it again.
    if [[ -n $current_block ]] && systemctl is-active --quiet plexmediaserver; then
      systemctl stop plexmediaserver
      info "stopped plexmediaserver while the mounts change"
    fi
    local old_mount_point
    while read -r old_mount_point; do
      [[ -n $old_mount_point ]] || continue
      systemctl stop "$(mount_unit_name "$old_mount_point" automount)" \
        "$(mount_unit_name "$old_mount_point" mount)" 2>/dev/null ||
        warn "could not unmount $old_mount_point (in use?); a reboot will apply the change"
    done < <(printf '%s\n' "$current_block" | awk '!/^#/ && NF >= 2 { print $2 }')

    write_fstab_block "$new_block"
    info "wrote managed block (${#MOUNT_POINTS[@]} shares)"
  fi

  systemctl daemon-reload
  # Bring the fstab entries up through the units systemd generated from them.
  # This is the systemd equivalent of `mount -a`: plain `mount -a` ignores
  # x-systemd.automount and would stack a direct mount over the automount.
  local unit_suffix="mount"
  [[ ,$NAS_MOUNT_OPTIONS, == *,x-systemd.automount,* ]] && unit_suffix="automount"
  for mount_point in "${MOUNT_POINTS[@]}"; do
    share_is_mounted "$mount_point" && continue
    systemctl start "$(mount_unit_name "$mount_point" "$unit_suffix")" 2>/dev/null ||
      warn "could not start $unit_suffix unit for $mount_point"
  done

  for mount_point in "${MOUNT_POINTS[@]}"; do
    if trigger_and_check_mount "$mount_point"; then
      info "mounted $mount_point"
    else
      warn "$mount_point is not mounted (NAS down, wrong share name, or wrong password?)"
      warn "  details: journalctl -b -k --grep CIFS ; wrong password -> sudo $0 --reset-credentials"
    fi
  done
}

# 6. PLEX AUTO-RESTART AND MOUNT DEPENDENCY -----------------------------------
configure_plex_service() {
  step "Installing Plex systemd override"

  local plex_was_active=false override_changed=false
  systemctl is-active --quiet plexmediaserver && plex_was_active=true

  if write_file_if_changed "$(render_override)" "$PLEX_OVERRIDE_PATH"; then
    override_changed=true
    info "wrote $PLEX_OVERRIDE_PATH"
  else
    info "override already up to date"
  fi

  systemctl daemon-reload
  # If the NAS is down this start fails, but systemd keeps retrying every
  # RestartSec until the shares mount, so no one has to step in.
  systemctl enable --now plexmediaserver ||
    warn "plexmediaserver not up yet (NAS shares missing?); systemd retries every 10s on its own"
  if [[ $override_changed == "true" && $plex_was_active == "true" ]]; then
    systemctl restart plexmediaserver || warn "plexmediaserver failed to restart"
  fi
}

# 7. VERIFY AND REPORT --------------------------------------------------------
verify() {
  step "Verifying"

  if systemctl is-active --quiet plexmediaserver; then
    record_check "plexmediaserver is active" true
  else
    record_check "plexmediaserver is active" false
  fi

  # Step 5 already triggered the automounts; just look, so an unreachable NAS
  # doesn't cost another timeout per share.
  local mount_point
  for mount_point in "${MOUNT_POINTS[@]}"; do
    if share_is_mounted "$mount_point"; then
      record_check "SMB share mounted at $mount_point" true
    else
      record_check "SMB share mounted at $mount_point" false
    fi
  done

  # Plex takes a few seconds to answer after (re)starting.
  local identity_ok=false attempt
  for attempt in {1..15}; do
    if curl -fsS --max-time 3 "$PLEX_IDENTITY_URL" >/dev/null 2>&1; then
      identity_ok=true
      break
    fi
    sleep 2
  done
  record_check "Plex answers on $PLEX_IDENTITY_URL" "$identity_ok"

  local check_name
  printf '\n---------------- SUMMARY ----------------\n'
  for check_name in "${PASSED_CHECKS[@]}"; do printf '  PASS  %s\n' "$check_name"; done
  for check_name in "${FAILED_CHECKS[@]}"; do printf '  FAIL  %s\n' "$check_name"; done
  printf -- '-----------------------------------------\n'

  cat <<EOF

Next step (first time only) - claim the server from your desktop:
  ssh -L 8888:localhost:32400 ${SUDO_USER:-simun}@$HOSTNAME_TARGET.local
  then open http://localhost:8888/web, sign in, and add libraries at $MOUNT_ROOT/<share>.
EOF

  if [[ ${#FAILED_CHECKS[@]} -gt 0 ]]; then
    printf '\n⚠ %d check(s) failed. See README.md -> Troubleshooting.\n' "${#FAILED_CHECKS[@]}"
    return 2
  fi
  printf '\nSetup complete.\n'
}

main() {
  local argument
  for argument in "$@"; do
    case $argument in
      --reset-credentials) RESET_CREDENTIALS=true ;;
      -h | --help)
        sed -n '2,6p' "${BASH_SOURCE[0]}"
        exit 0
        ;;
      *) die "Unknown option: $argument (try --help)" ;;
    esac
  done

  preflight
  TEMP_DIR="$(mktemp -d)"
  trap cleanup EXIT
  export DEBIAN_FRONTEND=noninteractive

  install_base
  install_t2_repo
  install_plex
  configure_mounts
  configure_plex_service
  verify
}

# Allow sourcing the functions for testing without running anything.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  main "$@"
fi
