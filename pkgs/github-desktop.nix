# GitHub Desktop with a working "Sign in with browser" on Linux.
#
# nixpkgs builds GitHub Desktop from the upstream source, which has no Linux
# handling for the link GitHub sends back after you approve the sign-in
# (x-github-desktop-dev-auth://oauth?code=...). Upstream only listens for
# macOS's `open-url` event, and the code that receives a second launch only
# understands --cli-open and --cli-clone, so the link is thrown away and the
# app waits on "signing in" forever (nixpkgs issue #344911).
#
# The fix: when a second launch carries an x-github... link, hand it to the same
# handler the macOS event uses. Everything else is reused from the already
# built nixpkgs package (every file is a link to it), so nothing is recompiled:
# only main.js is a patched copy, and the launcher is rebuilt to point at it.
# The launcher also fixes nixpkgs' own, whose Wayland flags end up as literal
# unexpanded text.
#
# The patch must match exactly once. If a nixpkgs update changes the code so it
# no longer does, the build stops with "patch did not apply" instead of
# shipping an app that cannot sign in. Then check whether upstream has fixed it
# (drop this package) or adjust the pattern in `signInFix` below.
{
  lib,
  runCommand,
  makeWrapper,
  perl,
  electron,
  github-desktop,
}:

let
  signInFix = ''
    $c = s/(\w+)\.app\.on\("second-instance",\(\((\w+),(\w+),(\w+)\)=>\{/$1.app.on("second-instance",(($2,$3,$4)=>{$3.forEach(a=>{\/^x-github(-desktop)?(-dev)?-(auth|client):\\\/\\\/\/.test(a)&&$1.app.emit("open-url",{preventDefault(){}},a)});/g;
    END { die "patch did not apply exactly once (matched $c)\n" unless $c == 1 }
  '';
in
runCommand "github-desktop-${github-desktop.version}"
  {
    nativeBuildInputs = [
      makeWrapper
      perl
    ];
    inherit (github-desktop) meta;
  }
  ''
    mkdir -p $out
    cp -rs --no-preserve=mode ${github-desktop}/. $out/

    app=$out/share/github-desktop/resources/app
    rm $app/main.js
    perl -0777 -pe '${signInFix}' ${github-desktop}/share/github-desktop/resources/app/main.js > $app/main.js

    rm $out/bin/github-desktop
    makeWrapper ${lib.getExe electron} $out/bin/github-desktop \
      --add-flag $app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0
  ''
