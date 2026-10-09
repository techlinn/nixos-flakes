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