# Shared helpers for the dotfiles/ sub-files. Not a module — imported directly.
{ config, lib, pwnboxDisplay, pwnboxMonitors }:
rec {
  # Where the raw dotfiles live, relative to the flake root.
  dotfiles = ../../dotfiles;
  themes = ../../dotfiles/themes;
  homeDir = config.home.homeDirectory;

  # Symlink an entire ~/.config/<name> directory from dotfiles/config/<name>.
  configDir = name: { source = "${dotfiles}/config/${name}"; };

  # Read a file and substitute @HOME@ with the actual home directory.
  tpl = path: {
    text = builtins.replaceStrings [ "@HOME@" ] [ homeDir ] (builtins.readFile "${dotfiles}/${path}");
  };

  # One Hyprland `monitor =` line per entry in pwnbox.desktop.monitors.
  monitorRules = lib.concatMapStrings (m: "monitor = ${m}\n") pwnboxMonitors;

  # The templated Hyprland config: monitors + resolution + home dir baked in.
  hyprlandConf = builtins.replaceStrings
    [ "@MONITORS@\n" "@RESOLUTION@" "@HOME@" ]
    [ monitorRules pwnboxDisplay homeDir ]
    (builtins.readFile "${dotfiles}/config/hypr/hyprland.conf");

  # Discover every theme in dotfiles/themes/<name>/ with a theme.conf.
  customThemes = builtins.listToAttrs (
    map (name: { name = "pwnbox/themes/${name}"; value.source = "${themes}/${name}"; })
      (builtins.attrNames (lib.filterAttrs
        (name: type: type == "directory" && builtins.pathExists "${themes}/${name}/theme.conf")
        (builtins.readDir themes)))
  );
}
