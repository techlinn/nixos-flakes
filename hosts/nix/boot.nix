# Bootloader (GRUB) + boot-time options for this machine.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The name GRUB registers in EFI NVRAM. nixpkgs derives it the same way:
  # distro name + the ESP mount point with "/" turned into "-".
  bootloaderId =
    config.system.nixos.distroName
    + lib.replaceStrings [ "/" ] [ "-" ] config.boot.loader.efi.efiSysMountPoint;
in
{
  # GRUB on the existing Windows EFI partition. The Windows entries are written
  # out below instead of by os-prober, which names them all the same thing.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = false;
    # Same chainloads os-prober found, with names that say which is which.
    # nvme0n1p1 is the 100M ESP holding the live BCD: this is the Windows you use.
    # nvme0n1p4 is a second 2G ESP with its own boot manager (OEM, from the factory).
    extraEntries = ''
      menuentry "Windows 11" --class windows --class os {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root DA78-5A0D
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
      menuentry "Windows 11 - factory ESP (p4, not the one you use)" --class windows --class os {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root 4C7D-8A70
        chainloader /efi/Microsoft/Boot/bootmgfw.efi
      }
    '';
  };
  # Long enough to still catch the menu and pick Windows, 2s shorter than before.
  boot.loader.timeout = 3;

  # Windows puts its own EFI entry back in front of this one whenever it
  # updates, and the firmware then boots Windows directly without ever showing
  # GRUB. Put the NixOS entry first again, but only when it is not already
  # first, so NVRAM is written at most once per change.
  systemd.services.efi-boot-order = {
    description = "Keep the NixOS entry first in the EFI boot order";
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathIsDirectory = "/sys/firmware/efi/efivars";
    path = with pkgs; [
      efibootmgr
      coreutils
      gnugrep
      gnused
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      out=$(efibootmgr) || exit 0
      want=$(printf '%s\n' "$out" \
        | grep -E "^Boot[0-9A-Fa-f]{4}\*? ${bootloaderId}(\s|$)" \
        | head -1 | sed -E 's/^Boot([0-9A-Fa-f]{4}).*/\1/')
      order=$(printf '%s\n' "$out" | sed -n 's/^BootOrder: //p' | head -1)
      [ -n "$want" ] && [ -n "$order" ] || exit 0
      case "$order" in "$want" | "$want",*) exit 0 ;; esac
      rest=$(printf '%s' "$order" | tr ',' '\n' | grep -vx "$want" | paste -sd, -)
      echo "EFI boot order was $order; putting $want (${bootloaderId}) first"
      efibootmgr -o "$want''${rest:+,$rest}" >/dev/null
    '';
  };
}
