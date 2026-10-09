{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "pwnbox-gnome-fonts";
  version = "1.0.0";

  src = ../dotfiles/gnome/fonts;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/fonts/gnome"
    cp -a . "$out/share/fonts/gnome/"
    runHook postInstall
  '';

  meta = {
    description = "Fonts from the pwnbox GNOME dotfiles (Berkeley Mono, Fairfax Hax HD, ...)";
    # Berkeley Mono is a paid font (your own licence): do not publish this folder.
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
