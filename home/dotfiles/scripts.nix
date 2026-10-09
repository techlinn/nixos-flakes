# ~/.scripts + ~/.local/bin launcher wrappers.
{ config, lib, pwnboxDisplay ? "preferred", pwnboxMonitors ? [ ], ... }:
let
  h = import ./_lib.nix { inherit config lib pwnboxDisplay pwnboxMonitors; };
in
{
  home.file = {
    # Shell + utility scripts live under dotfiles/scripts and are linked into ~/.scripts.
    ".scripts".source = "${h.dotfiles}/scripts";

    # Wallpapers for the GNOME background picker.
    ".local/share/pwnbox/wallpapers".source = "${h.dotfiles}/gnome/wallpapers";

    # Launcher wrappers so apps go through the pwnbox-managed scripts.
    ".local/bin/spotify" = {
      text = ''
        #!/usr/bin/env bash
        exec "$HOME/.scripts/pwnbox-spotify" launch "$@"
      '';
      executable = true;
    };

    # IDA Pro install helper (see docs/apps.md for the installer file).
    ".local/bin/ida-install" = {
      text = ''
        #!/usr/bin/env bash
        exec "$HOME/.scripts/ida-install" "$@"
      '';
      executable = true;
    };
  };
}
