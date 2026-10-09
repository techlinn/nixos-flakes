# Bootloader for the "nixos" template host.
{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = false;
  };
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.compressor = "xz";
}
