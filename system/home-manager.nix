# Hooks home-manager into NixOS so your user's home/ settings get applied too.
{ config, lib, ... }:
let
  user = config.pwnbox.username;
in
{
  home-manager.extraSpecialArgs = {
    pwnboxDisplay = config.pwnbox.desktop.resolution;
    pwnboxMonitors = config.pwnbox.desktop.monitors;
  };

  home-manager.users.${user} = {
    imports = [ ../home ];

    home.username = user;
    home.homeDirectory = lib.mkDefault "/home/${user}";
    home.stateVersion = "26.05";
  };
}
