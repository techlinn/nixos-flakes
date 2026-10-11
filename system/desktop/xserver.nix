# X11 server + display-manager plumbing (fallback for X-only apps).
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.pwnbox.desktop.enable {
  services.xserver = {
    enable = true;
    xkb = {
      layout = "se";
      variant = "";
    };
    excludePackages = [ pkgs.xterm ];
  };

  # Which session the login manager starts by default, whichever one it is.
  services.displayManager.defaultSession = "hyprland";

  services.libinput.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}