# Desktop stack: Hyprland (wayland) + GNOME services + fonts + login manager.
{ ... }:
{
  imports = [
    ./xserver.nix        # X11 fallback + display manager plumbing
    ./sddm.nix           # sddm: graphical login manager (pwnbox.desktop.loginManager)
    ./ly.nix             # ly: console TUI login manager, the other half of that option
    ./accessibility.nix  # at-spi2 bus (off if pwnbox.desktop.accessibility = false)
    ./hyprland.nix       # Hyprland compositor
    ./gnome.nix          # GNOME services (keyring, portals, settings-daemon)
    ./fonts.nix          # system fonts (Berkeley Mono + JetBrains Mono)
    ./gtk.nix            # system GTK theming
  ];
}
