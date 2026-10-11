# sddm: graphical login manager, coloured from the palette drop in /var/lib/pwnbox-greeter.
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.pwnbox.desktop.enable && config.pwnbox.desktop.loginManager == "sddm") {
  services.displayManager.sddm = {
    enable = true;
    theme = "pwnbox";

    settings = {
      # The same pointer the desktop uses, so it does not change at login.
      Theme.CursorTheme = "Colloid-dark-cursors";
    };
  };

  # Puts the theme under /run/current-system/sw/share/sddm/themes, where
  # sddm's ThemeDir points.
  environment.systemPackages = [ pkgs.pwnbox.sddm-theme ];

  # sddm runs as its own user before anyone has logged in, so it cannot read
  # ~/.cache/pwnbox/theme. pwnbox-theme writes the palette and a copy of the
  # wallpaper here instead, and the greeter reads them at start.
  systemd.tmpfiles.rules = [
    "d /var/lib/pwnbox-greeter 0755 ${config.pwnbox.username} users -"
  ];
}
