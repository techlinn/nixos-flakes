# System-wide NixOS config. Imports every system/ sub-file.
# To turn a feature off, delete its line from this list or edit its file.
{ ... }:
{
  imports = [
    ./options.nix          # pwnbox.* option declarations
    ./locale.nix           # timezone + locale
    ./networking.nix       # hostname + NetworkManager + DNS
    ./nix.nix              # nix daemon config
    ./security.nix         # polkit, gpg-agent, rtkit
    ./sound.nix            # pipewire
    ./swap.nix             # zram
    ./users.nix            # user account + groups
    ./vpn.nix              # mullvad
    ./virtualisation.nix   # docker, libvirt, wireshark
    ./vm-evasion           # KVM anti-VM-detection patches + boot params
    ./desktop              # hyprland + gnome + fonts
    ./packages             # system packages (base, apps, gaming, etc)
    ./hardening            # kernel/sysctl/service hardening
  ];

  system.stateVersion = "26.05";

  systemd.oomd.enable = false;
}
