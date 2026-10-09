# Packages, grouped by purpose. To add/remove a package, open the matching file.
{ ... }:
{
  imports = [
    ./base.nix       # CLI tools everyone gets (git, curl, zsh, tree, etc)
    ./desktop.nix    # Hyprland + wayland apps (pwnbox.desktop.enable)
    ./apps.nix       # GUI apps (messaging, browsers, media)
    ./languages.nix  # Compilers + runtimes (rust, zig, go, java, …)
    ./gaming.nix     # Steam + launchers + Proton (pwnbox.packages.gaming)
    ./creative.nix   # Image/video/audio/3D (pwnbox.packages.creative)
    ./hacking.nix    # Pentest tool bundles (pwnbox.packages.hacking)
    ./custom.nix     # Packages defined in pkgs/custom.nix
  ];
}

