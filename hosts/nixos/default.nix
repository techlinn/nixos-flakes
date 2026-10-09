# Template host called "nixos" — used by a fresh install from the ISO.
# Replace or copy this directory under a new name to add another machine.
{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
  ];

  pwnbox = {
    hostName = "nixos";
    timeZone = "Europe/Berlin";

    desktop = {
      enable = true;
      accessibility = false;
    };

    # Mullvad VPN: the daemon starts at boot and connects by itself once you have logged
    # in (`mullvad account login <account number>`). See docs/privacy.md.
    vpn.mullvad = true;

    virtualisation = {
      docker = true;
      libvirtd = true;
      wireshark = true;
    };

    packages = {
      hacking = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
