# Zen with the pwnbox site-styles extension built in and the prefs from dotfiles/config/zen/user.js.
{
  lib,
  runCommand,
  wrapFirefox,
  zen-browser-unwrapped,
  zip,
}:
let
  browserForWrapper = zen-browser-unwrapped // {
    version = zen-browser-unwrapped.firefoxVersion;
  };

  # The extension re-reads the recoloured site styles over localhost and
  # restyles open tabs, so a theme change needs no Zen restart.
  pwnboxStyles = runCommand "pwnbox-styles.xpi" { nativeBuildInputs = [ zip ]; } ''
    mkdir src
    cp ${../dotfiles/config/zen/extension}/* src/
    (cd src && zip -q -r "$out" .)
  '';

  # user.js is the single source of these prefs; parse it instead of repeating it.
  parsePref =
    line:
    let
      m = builtins.match ''^[[:space:]]*user_pref\("([^"]+)",[[:space:]]*([^;]+)\);[[:space:]]*$'' line;
    in
    if m == null then null else lib.nameValuePair (builtins.elemAt m 0) (builtins.fromJSON (builtins.elemAt m 1));

  prefsFromUserJs = builtins.listToAttrs (
    builtins.filter (p: p != null) (
      map parsePref (lib.splitString "\n" (builtins.readFile ../dotfiles/config/zen/user.js))
    )
  );

  wrapped = wrapFirefox browserForWrapper {
    pname = "zen-browser";
    version = zen-browser-unwrapped.version;
    extraPolicies = {
      DisableAppUpdate = true;
      Preferences = prefsFromUserJs // {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # the side-loaded styles extension is built here, so it is unsigned
        "xpinstall.signatures.required" = false;
      };
    };
  };
in
wrapped.overrideAttrs (old: {
  buildCommand = (old.buildCommand or "") + ''
    mkdir -p "$out/lib/${browserForWrapper.libName}/distribution/extensions"
    cp ${pwnboxStyles} "$out/lib/${browserForWrapper.libName}/distribution/extensions/styles@pwnbox.one.xpi"
  '';
})
