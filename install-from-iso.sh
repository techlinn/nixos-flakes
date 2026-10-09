#!/usr/bin/env bash
# Run this from the NixOS live USB, inside the Flakes folder:
#     sudo bash install-from-iso.sh
# Installs NixOS (host "tower") next to Windows. It never formats anything:
# you create the empty ext4 partition labelled NIXOS first (see START-HERE.md).
# Safe to run again if it stops halfway (for example a network drop).
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST="${PWNBOX_HOST:-tower}"   # another machine: PWNBOX_HOST=<name> sudo -E bash install-from-iso.sh
WORK="/tmp/Flakes"
ESP_GUID="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"

say() { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || exec sudo bash "$0" "$@"
[ -f "$HERE/flake.nix" ] || die "Run this from inside the Flakes folder (flake.nix is not next to the script)."
[ -d /sys/firmware/efi ] || die "The USB booted in legacy (BIOS) mode. Reboot and choose the UEFI entry for the USB."

USER_NAME="$(grep -oP 'username = "\K[^"]+' "$HERE/hosts/$HOST/default.nix" | head -1)"
[ -n "$USER_NAME" ] || die "Could not read the username from hosts/$HOST/default.nix"

say "Checking internet"
curl -fsS --max-time 20 -o /dev/null https://cache.nixos.org/nix-cache-info \
  || die "No internet. Plug in ethernet (or connect Wi-Fi from the top-right menu), then run this again."

say "Looking for the NixOS partition"
ROOT="$(blkid -L NIXOS 2>/dev/null || true)"
if [ -z "$ROOT" ]; then
  lsblk -o NAME,SIZE,FSTYPE,LABEL
  die "No partition labelled NIXOS. Create it in GParted first (ext4, label NIXOS), then run this again."
fi
[ "$(blkid -o value -s TYPE "$ROOT")" = ext4 ] || die "$ROOT is not ext4."

if ! mountpoint -q /mnt; then
  printf '\nNixOS will be installed on %s (%s).\nNothing gets formatted and Windows is not touched.\nType yes to continue: ' "$ROOT" "$(lsblk -dno SIZE "$ROOT")"
  read -r answer
  [ "$answer" = yes ] || die "Cancelled."
  mount "$ROOT" /mnt
fi
if [ ! -d /mnt/nix ] && [ -n "$(ls -A /mnt | grep -v '^lost+found$' || true)" ]; then
  die "$ROOT already has files on it. Use a new, empty ext4 partition labelled NIXOS."
fi

say "Looking for the Windows EFI boot partition"
ESP=""
for p in $(lsblk -prno NAME,PARTTYPE | awk -v g="$ESP_GUID" 'tolower($2)==g {print $1}'); do
  t="$(mktemp -d)"
  if mount -o ro "$p" "$t" 2>/dev/null; then
    [ -f "$t/EFI/Microsoft/Boot/bootmgfw.efi" ] && ESP="$p"
    umount "$t"
  fi
  rmdir "$t"
  [ -z "$ESP" ] || break
done
[ -n "$ESP" ] || die "Could not find the Windows EFI partition. Ask for help and show what 'lsblk -f' prints."

mkdir -p /mnt/boot/efi
mountpoint -q /mnt/boot/efi || mount "$ESP" /mnt/boot/efi
[ "$(df --output=avail -k /mnt/boot/efi | tail -1)" -ge 30000 ] \
  || die "The EFI partition ($ESP) has less than 30 MB free. Ask for help."

say "Preparing the configuration"
rm -rf "$WORK"
cp -r "$HERE" "$WORK"
nixos-generate-config --root /mnt --show-hardware-config > "$WORK/hosts/$HOST/hardware-configuration.nix"
grep -q 'fileSystems."/"' "$WORK/hosts/$HOST/hardware-configuration.nix" \
  || die "Hardware config looks wrong (no root filesystem found)."

say "Installing NixOS. This downloads a lot and can take 30 to 90 minutes. Leave it running."
export NIX_CONFIG="experimental-features = nix-command flakes"
nixos-install --root /mnt --flake "path:$WORK#$HOST" --no-root-passwd

say "Choose the password for $USER_NAME (you log in and use sudo with it)"
until nixos-enter --root /mnt -c "passwd $USER_NAME"; do
  echo "That did not work, try again."
done

say "Copying the config to /home/$USER_NAME/Flakes"
rm -rf "/mnt/home/$USER_NAME/Flakes"
mkdir -p "/mnt/home/$USER_NAME"
cp -r "$WORK" "/mnt/home/$USER_NAME/Flakes"
nixos-enter --root /mnt -c "chown -R $USER_NAME: /home/$USER_NAME"

sync
umount -R /mnt
say "Done! Type: reboot   (unplug the USB when the screen goes black)"
