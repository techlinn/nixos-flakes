{ config, lib, pkgs, ... }:
{
  # Image/video/audio/3D creation. Enable with pwnbox.packages.creative = true;
  environment.systemPackages = lib.mkIf config.pwnbox.packages.creative (with pkgs; [
    gimp inkscape libreoffice-fresh kdePackages.kdenlive
    obs-studio audacity blender krita
  ]);
}
