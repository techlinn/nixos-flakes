{ pkgs }:
{
  dotfiles = pkgs.callPackage ./dotfiles.nix { };
  manrope = pkgs.callPackage ./manrope.nix { };
  colloid-cursors = pkgs.callPackage ./colloid-cursors.nix { };
  gnome-fonts = pkgs.callPackage ./gnome-fonts.nix { };
  tg-config = pkgs.callPackage ./tg-config.nix { };
}
