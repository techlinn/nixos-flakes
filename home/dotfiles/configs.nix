# ~/.config/* symlinks for every app whose settings this flake owns.
{ config, lib, pwnboxDisplay ? "preferred", pwnboxMonitors ? [ ], ... }:
let
  h = import ./_lib.nix { inherit config lib pwnboxDisplay pwnboxMonitors; };
in
{
  xdg.enable = true;

  # Everything in ~/.config/* that this flake owns. Keep in alphabetical-ish
  # order so adding/removing an app is easy to spot.
  xdg.configFile =
    {
      "bat" = h.configDir "bat";
      "cava" = h.configDir "cava";
      "fuzzel/fuzzel.ini" = h.tpl "config/fuzzel/fuzzel.ini";

      # Alt+Tab overlay runs as a second Quickshell instance. Linked file-by-file
      # so Theme.js can be a symlink into the live theme folder.
      "quickshell-overlays" = {
        source = "${h.dotfiles}/config/quickshell-overlays";
        recursive = true;
      };
      "quickshell-overlays/Theme.js".source =
        config.lib.file.mkOutOfStoreSymlink "${h.homeDir}/.config/quickshell/Theme.js";

      "kitty/kitty.conf" = h.tpl "config/kitty/kitty.conf";
      "neofetch" = h.configDir "neofetch";
      "rofi/config.rasi" = h.tpl "config/rofi/config.rasi";
      "rofi/menu.rasi" = h.tpl "config/rofi/menu.rasi";
      "rofi/picker.rasi" = h.tpl "config/rofi/picker.rasi";
      "rofi/barstyle.rasi" = h.tpl "config/rofi/barstyle.rasi";
      "rofi/custom.rasi" = h.tpl "config/rofi/custom.rasi";

      "wal/templates".source = "${h.dotfiles}/config/wal/templates";
      "wal/monochrome".source = "${h.dotfiles}/config/wal/monochrome";

      "zed/settings.json".source = "${h.dotfiles}/config/zed/settings.json";

      "micro/settings.json".source = "${h.dotfiles}/config/micro/settings.json";
      "micro/bindings.json".source = "${h.dotfiles}/config/micro/bindings.json";
      "micro/colorschemes".source = "${h.dotfiles}/config/micro/colorschemes";

      "zathura/zathurarc" = h.tpl "config/zathura/zathurarc";

      "telegram/awesome.tdesktop-theme".source = "${h.dotfiles}/config/telegram/awesome.tdesktop-theme";

      "equibop/theme-base.css".source = "${h.dotfiles}/config/equibop/theme-base.css";
      "equibop/pwnbox-tokens.css".source = "${h.dotfiles}/config/equibop/pwnbox-tokens.css";

      "ida/pwnbox-theme.css".source = "${h.dotfiles}/config/ida/pwnbox-theme.css";
      # IDA's arrows and checkboxes, recoloured per theme by pwnbox-theme.
      "ida/icons".source = "${h.dotfiles}/config/ida/icons";
      # IDA's icon-swapping plugin. Available, not loaded: copy it into
      # ~/.idapro/plugins/ to enable (it is untested on this machine).
      "ida/plugin".source = "${h.dotfiles}/config/ida/plugin";

      # Zen: the per-site styles pwnbox-theme recolours. user.js is not linked
      # here on purpose, pkgs/zen-browser.nix reads it at build time instead.
      "pwnbox/zen/userstyles".source = "${h.dotfiles}/config/zen/userstyles";

      "spicetify/Themes/pwnbox/user-base.css".source = "${h.dotfiles}/config/spicetify/Themes/pwnbox/user-base.css";

      "nvim/lua".source = "${h.dotfiles}/config/nvim/lua";

      "hypr/hypridle.conf".source = "${h.dotfiles}/config/hypr/hypridle.conf";
      "hypr/hyprlock.conf".source = "${h.dotfiles}/config/hypr/hyprlock.conf";
      "hypr/xdph.conf".source = "${h.dotfiles}/config/hypr/xdph.conf";
      "hypr/wall.png".source = "${h.dotfiles}/config/hypr/wall.png";
      "hypr/hyprland.conf".text = h.hyprlandConf;

      "ranger/rc.conf".source = "${h.dotfiles}/config/ranger/rc.conf";
      "ranger/commands.py".source = "${h.dotfiles}/config/ranger/commands.py";
      "ranger/rifle.conf".source = "${h.dotfiles}/config/ranger/rifle.conf";
      "ranger/scope.sh".source = "${h.dotfiles}/config/ranger/scope.sh";
      "ranger/plugins".source = "${h.dotfiles}/config/ranger/plugins";
    }
    # Auto-import every file in dotfiles/config/quickshell/ (except Theme.js).
    // builtins.listToAttrs (map
      (name: { name = "quickshell/${name}"; value.source = "${h.dotfiles}/config/quickshell/${name}"; })
      (builtins.filter (n: n != "Theme.js")
        (builtins.attrNames (builtins.readDir "${h.dotfiles}/config/quickshell"))))
    # And every theme directory from dotfiles/themes/.
    // h.customThemes;
}
