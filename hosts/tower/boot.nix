# Bootloader (GRUB) + boot-time options for this machine.
{ ... }:
{
  # GRUB on the existing Windows EFI partition. os-prober adds Windows to the menu.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };
  boot.loader.timeout = 5;
}
