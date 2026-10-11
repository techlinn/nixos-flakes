{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  pname = "pwnbox-sddm-theme";
  version = "1.0.0";

  src = ../dotfiles/sddm/pwnbox;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/sddm/themes/pwnbox"
    cp -a . "$out/share/sddm/themes/pwnbox/"
    runHook postInstall
  '';

  meta = {
    description = "Login screen matching the pwnbox lock screen (SDDM theme)";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
