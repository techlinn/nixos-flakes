# Per-rebuild hooks: seed configs that apps/scripts overwrite at runtime.
{ config, lib, pwnboxDisplay ? "preferred", pwnboxMonitors ? [ ], ... }:
let
  h = import ./_lib.nix { inherit config lib pwnboxDisplay pwnboxMonitors; };
in
{
  # These run after home-manager writes files, so they can seed/copy things
  # that pwnbox-theme or apps rewrite at runtime.

  # Zathura used to be a symlink; drop it so a fresh dir can be made.
  home.activation.pwnboxMigrateZathura = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    if [ -L "$HOME/.config/zathura" ]; then
      run rm -f "$HOME/.config/zathura"
    fi
  '';

  # EasyEffects presets are copied (not linked) so EasyEffects can save over them.
  home.activation.pwnboxEasyEffects = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    preset_dir="$HOME/.local/share/easyeffects/input"
    run mkdir -p "$preset_dir"
    if [ ! -e "$preset_dir/Mic-Gate.json" ]; then
      run cp ${h.dotfiles}/config/easyeffects/input/Mic-Gate.json "$preset_dir/Mic-Gate.json"
      run chmod u+w "$preset_dir/Mic-Gate.json"
    fi
  '';

  # Equibop rewrites its own settings file at runtime, so just seed it once.
  home.activation.pwnboxEquibop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    eq_dir="$HOME/.config/equibop/settings"
    run mkdir -p "$eq_dir"
    if [ ! -e "$eq_dir/settings.json" ]; then
      run cp ${h.dotfiles}/config/equibop/settings-seed.json "$eq_dir/settings.json"
      run chmod u+w "$eq_dir/settings.json"
    fi
  '';

  # Theme state lives in ~/.cache/pwnbox/theme/. ALT+S writes here at runtime;
  # we seed only the defaults so your choices survive rebuilds.
  home.activation.pwnboxTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    theme_dir="$HOME/.cache/pwnbox/theme"
    run mkdir -p "$theme_dir"
    run rm -f "$HOME/.config/hypr/hyprlock.conf.hm-backup"
    run cp -n ${h.dotfiles}/config/wal/monochrome/* "$theme_dir"/ 2>/dev/null || true
    run mkdir -p "$HOME/.config/quickshell"
    if [ ! -e "$HOME/.config/quickshell/Theme.js" ]; then
      run cp -f ${h.dotfiles}/config/wal/monochrome/Theme.js "$HOME/.config/quickshell/Theme.js"
    fi
    run chmod -R u+w "$theme_dir"
    run chmod u+w "$HOME/.config/quickshell/Theme.js"

    # First boot on a new machine: start with City-Lights, not plain grey.
    if [ ! -e "$theme_dir/custom-theme" ] && [ ! -e "$theme_dir/wallpaper" ]; then
      run sh -c "printf '%s\n' City-Lights > '$theme_dir/custom-theme'"
      run sh -c ": > '$theme_dir/first-run'"
    fi

    # Defaults for everything ALT+S doesn't persist yet.
    if [ ! -e "$theme_dir/barstyle" ]; then
      run sh -c "printf '%s' capsule > '$theme_dir/barstyle'"
    fi
    if [ ! -e "$theme_dir/radius-window" ]; then
      run sh -c "printf '%s' 9 > '$theme_dir/radius-window'"
    fi
    if [ ! -e "$theme_dir/radius-ui" ]; then
      run sh -c "printf '%s' 9 > '$theme_dir/radius-ui'"
    fi
    if [ ! -e "$theme_dir/blur" ]; then
      run sh -c "printf '%s' on > '$theme_dir/blur'"
    fi
    if [ ! -e "$theme_dir/opacity" ]; then
      if [ "$(cat "$theme_dir/blur" 2>/dev/null || echo on)" = "off" ]; then
        run sh -c "printf '%s' 100 > '$theme_dir/opacity'"
      else
        run sh -c "printf '%s' 88 > '$theme_dir/opacity'"
      fi
    fi
    if [ ! -e "$theme_dir/animations" ]; then
      run sh -c "printf '%s' on > '$theme_dir/animations'"
    fi
    # One-time switch of the system font (everyday apps) to Manrope, the font Discord
    # uses; the bar and the desktop keep Berkeley Mono ("Desktop font"). Afterwards
    # the fonts are whatever ALT + S sets.
    if [ ! -e "$theme_dir/font-ui-manrope" ]; then
      run sh -c "printf '%s' 'Manrope' > '$theme_dir/font-ui' && printf '%s' 'Berkeley Mono' > '$theme_dir/font-desk' && : > '$theme_dir/font-ui-manrope'"
    fi
    if [ ! -e "$theme_dir/font-size-ui" ]; then
      run sh -c "printf '%s' 11 > '$theme_dir/font-size-ui'"
    fi
    if [ ! -e "$theme_dir/font-size-app" ]; then
      run sh -c "printf '%s' 10 > '$theme_dir/font-size-app'"
    fi

    # Clean up a leftover Spicetify symlink.
    if [ -L "$HOME/.config/spicetify/Themes/pwnbox/user.css" ]; then
      run rm -f "$HOME/.config/spicetify/Themes/pwnbox/user.css"
    fi

    # Zed themes come from the dotfiles tree, writable copies.
    run mkdir -p "$HOME/.config/zed/themes"
    if [ ! -e "$HOME/.config/zed/themes/pwnbox.json" ]; then
      run cp -f ${h.dotfiles}/config/wal/monochrome/pwnbox.json "$HOME/.config/zed/themes/pwnbox.json"
    fi
    run cp -f ${h.dotfiles}/config/zed/themes/kerne.json "$HOME/.config/zed/themes/kerne.json"
    run chmod u+w "$HOME/.config/zed/themes/pwnbox.json" "$HOME/.config/zed/themes/kerne.json"

    # Re-apply theme files on rebuild (PWNBOX_REBUILD=1 means "files only, don't
    # try to touch running bars"). A running bar is restarted inside the session
    # by Hyprland, not here, see pwnbox-theme's ensure_bar.
    if [ -x "$HOME/.scripts/pwnbox-theme" ]; then
      run env PWNBOX_REBUILD=1 sh -c '"$HOME/.scripts/pwnbox-theme" borders >/dev/null 2>&1 || true'
    fi
  '';
}
