{ config, lib, pkgs, ... }:
{
  # Gaming + launchers + Proton. Enable with pwnbox.packages.gaming = true;
  environment.systemPackages = lib.mkIf config.pwnbox.packages.gaming (with pkgs; [
    lutris gamemode mangohud wineWowPackages.stable protonup-ng
  ]);

  programs.steam = lib.mkIf config.pwnbox.packages.gaming {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
