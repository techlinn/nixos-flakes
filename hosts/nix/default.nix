# This machine (nix): identity, hardware, NVIDIA, audio, enabled features.
{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./nvidia.nix
    ./audio.nix
  ];

  pwnbox = {
    # Who you are + where you are.
    hostName = "nix";
    username = "techh";
    fullName = "techh";
    timeZone = "Europe/Berlin";

    # Desktop: Hyprland + GNOME.
    desktop = {
      enable = true;
      accessibility = false;
      # Graphical login screen. Set to "ly" for the old console one.
      loginManager = "sddm";
      resolution = "highrr";
      # Hyprland monitor rules: "name, mode, position, scale". Run `hyprctl monitors` to see names.
      monitors = [
        "HDMI-A-1, 1920x1080@60, 0x0, 1"
        "DP-2, 1920x1080@164.5, 1920x0, 1"
      ];
    };

    # Mullvad VPN daemon. Log in once with `mullvad account login <number>`.
    vpn.mullvad = true;

    # VMs, containers, packet sniffing.
    virtualisation = {
      docker = true;
      libvirtd = true;
      wireshark = true;
      # KVM anti-VM-detection patches. See system/vm-evasion/README.md.
      vmEvasion.enable = true;
    };

    # Full pentest toolset (26 categories). Set to false and `upd` to shrink the install.
    packages.hacking = true;
  };

  # Hardening normally locks kernel modules after boot; that blocks NVIDIA, VMs, USB sticks.
  security.lockKernelModules = lib.mkForce false;
}
