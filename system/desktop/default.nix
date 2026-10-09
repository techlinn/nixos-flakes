# Desktop stack: Hyprland (wayland) + GNOME services + fonts + login manager.
{ ... }:
{
  imports = [
    ./xserver.nix        # X11 fallback + display manager plumbing
    ./ly.nix             # ly: console TUI login manager
    ./accessibility.nix  # at-spi2 bus (off if pwnbox.desktop.accessibility = false)
    ./hyprland.nix       # Hyprland compositor
    ./gnome.nix          # GNOME services (keyring, portals, settings-daemon)
    ./fonts.nix          # system fonts (Manrope + Berkeley Mono)
    ./gtk.nix            # system GTK theming
  ];
}
