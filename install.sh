#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$SCRIPT_DIR"
LOG="${TMPDIR:-/tmp}/pwnbox-install.log"

action="switch"
do_gc=1
verbose=0
host=""
extra=()

usage() {
  cat <<'EOF'
Usage: ./install.sh [ACTION] [OPTIONS] [-- EXTRA...]

Rebuild this NixOS flake.  By default it collects garbage first (which removes
old generations) and then activates the configuration.

Actions:
  switch        build + activate, persistent               [default]
  test          build + activate for this boot only
  boot          build + set as the default for the next boot
  build         build only, do not activate
  dry-activate  build + show what would change, do not activate

Options:
  -H, --host HOST   flake host to build (default: short hostname)
  -n, --no-gc       skip garbage collection before rebuilding
  -v, --verbose     stream all command output (default: quiet)
  -h, --help        show this help

Examples:
  ./install.sh
  ./install.sh build
  ./install.sh test -H nixos
  ./install.sh switch --verbose
  ./install.sh switch -- --show-trace
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    switch | test | boot | build | dry-activate) action="$1"; shift ;;
    -H | --host)
      if [ "$#" -lt 2 ]; then
        echo "install.sh: --host needs a value" >&2
        exit 2
      fi
      host="$2"
      shift 2
      ;;
    --host=*)
      host="${1#*=}"
      shift
      ;;
    -n | --no-gc) do_gc=0; shift ;;
    -v | --verbose) verbose=1; shift ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      extra=("$@")
      break
      ;;
    *)
      echo "install.sh: unknown argument '$1'" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_BLUE=$'\033[34m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
else
  C_RESET=""
  C_BOLD=""
  C_DIM=""
  C_BLUE=""
  C_GREEN=""
  C_YELLOW=""
  C_RED=""
fi

step() { printf '%s==>%s %s%s%s\n' "$C_BLUE$C_BOLD" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '    %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
ok() { printf '%s  ok%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s==> %s%s\n' "$C_YELLOW" "$*" "$C_RESET" >&2; }
die() { printf '%s==> %s%s\n' "$C_RED" "$*" "$C_RESET" >&2; exit 1; }

run() {
  if [ "$verbose" -eq 1 ]; then
    "$@"
  else
    "$@" >/dev/null 2>&1
  fi
}

if [ ! -f "$FLAKE_DIR/flake.nix" ]; then
  die "no flake.nix found in $FLAKE_DIR"
fi

command -v nixos-rebuild >/dev/null 2>&1 || die "nixos-rebuild not found in PATH"

if [ -z "$host" ]; then
  if command -v hostname >/dev/null 2>&1; then
    host="$(hostname -s 2>/dev/null || hostname)"
  fi
  host="${host:-nixos}"
fi

user="${PWNBOX_USER:-${SUDO_USER:-$(id -un 2>/dev/null || echo pwnbox)}}"
system="${PWNBOX_SYSTEM:-$(nix eval --impure --raw --expr builtins.currentSystem 2>/dev/null || echo x86_64-linux)}"

if [ "$(id -u)" -eq 0 ]; then
  SUDO=()
else
  SUDO=(sudo)
fi

home="$HOME"
if command -v getent >/dev/null 2>&1; then
  h="$(getent passwd "$user" 2>/dev/null | cut -d: -f6 || true)"
  [ -n "$h" ] && home="$h"
fi
for _c in kitty rofi fuzzel alacritty zathura; do
  _p="$home/.config/$_c"
  if [ -L "$_p" ]; then
    case "$(readlink "$_p")" in
      /nix/store/*home-manager-files/*)
        run rm -f "$_p"
        info "migrated ~/.config/$_c (directory link -> per-file)"
        ;;
    esac
  fi
done

step "pwnbox install"
info "flake : $FLAKE_DIR"
info "host  : $host   user: $user   system: $system"

host_dir="$FLAKE_DIR/hosts/$host"
if [ ! -f "$host_dir/default.nix" ]; then
  step "Creating configuration for host '$host'"
  mkdir -p "$host_dir"
  cp "$FLAKE_DIR/hosts/nixos/default.nix" "$host_dir/default.nix"
  sed -i "s/hostName = \"nixos\"/hostName = \"$host\"/" "$host_dir/default.nix" 2>/dev/null || true
  # Write the user name into the host file. Without it the name is only known
  # while this script runs, and a later plain `upd` would fall back to a user
  # called "pwnbox".
  sed -i "s/^\\(  *\\)hostName = \"$host\";/&\\n\\1username = \"$user\";\\n\\1fullName = \"$user\";/" "$host_dir/default.nix" 2>/dev/null || true
  info "user     : $user"

  tz="$(timedatectl show -p Timezone --value 2>/dev/null || true)"
  if [ -n "$tz" ]; then
    sed -i "s#timeZone = \"[^\"]*\"#timeZone = \"$tz\"#" "$host_dir/default.nix" 2>/dev/null || true
    info "time zone: $tz"
  fi

  if [ -f /etc/nixos/hardware-configuration.nix ]; then
    cp /etc/nixos/hardware-configuration.nix "$host_dir/hardware-configuration.nix"
    info "hardware : /etc/nixos/hardware-configuration.nix"
  else
    # Not through `run`: in quiet mode that sends the command's output to /dev/null,
    # which would leave this file empty while reporting success.
    if "${SUDO[@]}" nixos-generate-config --show-hardware-config >"$host_dir/hardware-configuration.nix" 2>/dev/null \
      && [ -s "$host_dir/hardware-configuration.nix" ]; then
      info "hardware : nixos-generate-config"
    else
      rm -f "$host_dir/hardware-configuration.nix"
      die "could not generate hardware-configuration.nix (run nixos-generate-config yourself and copy the result to $host_dir)"
    fi
  fi

  # An NVIDIA graphics card needs its own driver, and the hardening module's
  # kernel-module lock has to be off for that driver to load.
  has_nvidia=0
  for _d in /sys/bus/pci/devices/*; do
    [ "$(cat "$_d/vendor" 2>/dev/null)" = "0x10de" ] || continue
    case "$(cat "$_d/class" 2>/dev/null)" in 0x03*) has_nvidia=1 ;; esac
  done
  if [ "$has_nvidia" -eq 1 ]; then
    cat >"$host_dir/nvidia.nix" <<'EOF'
{ lib, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # The open kernel modules support GTX 16-series, RTX 20-series and newer.
    # For an older card set this to false.
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false;
  };

  # The hardening module locks kernel modules after boot, which would stop the
  # NVIDIA driver from loading.
  security.lockKernelModules = lib.mkForce false;
}
EOF
    sed -i 's#^\(  *\)\./boot\.nix#&\n\1./nvidia.nix#' "$host_dir/default.nix" 2>/dev/null || true
    info "graphics : NVIDIA card found, driver enabled (nvidia.nix)"
  fi

  if [ -d /sys/firmware/efi ]; then
    cat >"$host_dir/boot.nix" <<'EOF'
{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
}
EOF
    info "boot     : systemd-boot (EFI)"
  else
    disk=""
    root_src="$(findmnt -no SOURCE / 2>/dev/null || true)"
    if [ -n "$root_src" ]; then
      parent="$(lsblk -no PKNAME "$root_src" 2>/dev/null | head -1)"
      [ -n "$parent" ] && disk="/dev/$parent"
    fi
    if [ -z "$disk" ]; then
      disk="/dev/sda"
      warn "could not detect the boot disk, edit $host_dir/boot.nix"
    fi
    cat >"$host_dir/boot.nix" <<EOF
{ ... }:
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "$disk";
  boot.loader.grub.useOSProber = false;
  boot.loader.timeout = 1;
}
EOF
    info "boot     : GRUB on $disk"
  fi
fi

need_sudo=0
[ "$do_gc" -eq 1 ] && need_sudo=1
[ "$action" != "build" ] && need_sudo=1
if [ "${#SUDO[@]}" -gt 0 ] && [ "$need_sudo" -eq 1 ]; then
  step "Requesting administrator privileges"
  "${SUDO[@]}" -v || die "sudo failed"
fi

if [ "$do_gc" -eq 1 ]; then
  step "Collecting garbage"
  info "removes old generations, skip with --no-gc"
  run "${SUDO[@]}" nix-collect-garbage -d
else
  step "Skipping garbage collection"
fi

case "$action" in
  build) RUN=() ;;
  *) RUN=("${SUDO[@]}") ;;
esac

step "Building and activating ($action)"
info "this can take a while"
: >"$LOG"

set +e
if [ "$verbose" -eq 1 ]; then
  "${RUN[@]}" env "PWNBOX_USER=$user" "PWNBOX_SYSTEM=$system" \
    nixos-rebuild "$action" --impure --flake "$FLAKE_DIR#$host" "${extra[@]}" 2>&1 | tee "$LOG"
  rc=${PIPESTATUS[0]}
else
  "${RUN[@]}" env "PWNBOX_USER=$user" "PWNBOX_SYSTEM=$system" \
    nixos-rebuild "$action" --impure --flake "$FLAKE_DIR#$host" "${extra[@]}" >"$LOG" 2>&1
  rc=$?
fi
set -e

if [ "$rc" -ne 0 ]; then
  warn "Build failed (exit $rc)"
  if [ "$verbose" -eq 0 ]; then
    printf '\n%s---- last lines of the log ----%s\n' "$C_DIM" "$C_RESET"
    tail -n 40 "$LOG" || true
    printf '%s--------------------------------%s\n\n' "$C_DIM" "$C_RESET"
    info "full log: $LOG  (rerun with --verbose)"
  fi
  exit "$rc"
fi

ok "Done ($action on '$host')"
info "reload if needed: 'qs -n' for Quickshell, or log out/in for GNOME"
