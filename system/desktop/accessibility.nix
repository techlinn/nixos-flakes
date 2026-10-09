# at-spi2 accessibility bus. Off when pwnbox.desktop.accessibility = false.
{
  config,
  lib,
  ...
}:
lib.mkIf (config.pwnbox.desktop.enable && !config.pwnbox.desktop.accessibility) {
  services.gnome.at-spi2-core.enable = lib.mkForce false;
}