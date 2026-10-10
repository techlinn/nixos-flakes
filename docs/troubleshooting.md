# Troubleshooting

## A theme change didn't apply everywhere

Re-apply from saved state:

```bash
~/.scripts/pwnbox-theme restore
```

Some apps only pick up colours when a new window opens (GTK apps). Log out and
back in for a full refresh.

## A theme's new colours did not show up after `upd`

`upd` applies the current theme again when the theme's files changed (a new
Neovim, Zed, Telegram or Discord scheme, a new look). If something still looks
old, apply it by hand from a terminal; it needs no password:

```bash
~/.scripts/pwnbox-theme borders
```

Then reopen Neovim once (it loads its theme code when it starts; after that it
follows theme changes by itself). Programs that watch their files, such as
Discord, Zed and Telegram, change on their own.

## The bar is missing or looks wrong

Start Quickshell again. Let Hyprland start it, so it gets the session's
settings:

```bash
hyprctl dispatch exec "qs -n"
hyprctl dispatch exec "qs -n -p ~/.config/quickshell-overlays"   # Alt+Tab
```

(Quickshell started from anywhere else, such as a background service, can fail
with "No PanelWindow backend loaded" and then shows nothing. Check with
`qs log` if the bar does not appear.)

**Why a rebuild must never take the bar down, and what stops it.** `upd` applies
the theme from a background service. That service imports the session's
`WAYLAND_DISPLAY`, so it looks like the desktop, but it forces
`QT_QPA_PLATFORM=offscreen` and has no `HYPRLAND_INSTANCE_SIGNATURE`. A bar
restarted from there cannot open its window, so the old one was killed and the
new one never appeared. Three things prevent that now (all in
`dotfiles/scripts/pwnbox-theme`):

1. `session_ok` refuses to touch the bar or other running programs unless it is
   really in the session: it needs `HYPRLAND_INSTANCE_SIGNATURE`, a platform that
   is not `offscreen`, and no rebuild marker (the rebuild sets `PWNBOX_REBUILD`;
   the service itself sets `HOME_MANAGER_BACKUP_EXT`).
2. `start_qs` always sets `QT_QPA_PLATFORM=wayland;xcb` instead of inheriting it,
   and `restart_quickshell` ends by asking Hyprland to start the bar if its own
   attempts fail.
3. After every rebuild, `borders` calls `ensure_bar`: if the bar or the Alt+Tab
   switcher is not running it is started through Hyprland, and `qs -n` never
   starts a second copy. If it is running but was started with older files (a
   rebuild swaps the bar's files without the running bar noticing, so a changed
   icon or panel would not show), Hyprland is asked to run
   `pwnbox-theme restart-bar` inside the session. The files the bar was started
   with are fingerprinted in `~/.cache/pwnbox/theme/bar-loaded`; a rebuild that
   did not change them restarts nothing, and theme colours (`Theme.js`) do not
   count.

The bar style is read from `~/.cache/pwnbox/theme/barstyle`. Check it with
`cat ~/.cache/pwnbox/theme/barstyle`. If a style looks broken, switch to
another from `ALT + S → Style`.

## The calendar opens in the wrong place

This is fixed: the calendar now follows the active bar's geometry (including
the bottom dock), defined once in
`dotfiles/config/quickshell/BarStyles.js`. If it is still off, make sure you
rebuilt after the change and that Quickshell restarted.

## Kitty shows "N by M cells" while resizing

That is kitty's live-resize overlay. It is drawn unconditionally by
`draw_resizing_text()` in `kitty/shaders.c` and has **no config option**, so
pwnbox patches it out in `overlays/default.nix` (`kitty.overrideAttrs` →
`postPatch`). If it comes back after a kitty update, the patch's
`--replace-fail` makes the build fail; update the matched string in the overlay
to the new one in `kitty/shaders.c`.

## Spotify

- **Theme not applied.** Run `pwnbox-spotify apply`, then check
  `~/.local/share/pwnbox/spotify/.applied` exists. If Spotify was updated, the
  writable copy is rebuilt automatically.
- **Changes don't show while running.** The live update uses
  `spicetify watch -s -l`. Check it is running with `pgrep -af 'spicetify watch'`
  and look at `~/.cache/pwnbox/spotify-watch.log`. The launcher passes
  `--remote-debugging-port`, so relaunch Spotify if you started it long ago.
- **Scrollbars are gone.** That is intentional. The base CSS hides them.
- **Fonts look wrong.** Run `pwnbox-spotify fonts` and reopen Spotify if the
  watcher isn't attached.

## Discord (Equibop)

- The theme is hot-applied by Equibop watching its `quickCss.css`. Make sure
  the built-in **QuickCSS** feature is enabled in Equibop settings.
- If it ever lags, focusing the window is enough; no reload is sent anymore.
- **Some things are still the old colour.** Run `~/.scripts/pwnbox-theme restore`
  and check that the end of `~/.config/equibop/settings/quickCss.css` has a
  `/* pwnbox palette: <theme> */` block. If it does not,
  `~/.config/equibop/pwnbox-tokens.css` is missing (rebuild with `upd`).
- A colour that a snippet sets with a fixed value (for example a hard-coded
  `#1a2433 !important`) is recoloured to the nearest theme colour but is not
  tied to the palette. The palette block comes last, so it wins for everything
  Discord names; for anything else, add a rule at the end of `theme-base.css`
  that uses `var(--pw-accent)`, `var(--pw-fg)`, `var(--pw-card)` and the other
  `--pw-*` colours.

## OBS and Zen do not change colour

Both read their colours only when they start, so close and reopen them after
changing the theme.

- **OBS:** check `~/.config/obs-studio/themes/Pwnbox.ovt` exists and that
  `~/.config/obs-studio/user.ini` has `Theme=com.obsproject.Yami.Pwnbox` under
  `[Appearance]`. The line is only written while OBS is closed. You can also
  choose *Pwnbox* under Settings, General, Theme.
- **Zen:** check `chrome/userChrome.css` exists in the profile folder
  (`~/.config/zen/profiles.ini` names it) and that `user.js` there contains
  `toolkit.legacyUserProfileCustomizations.stylesheets`. In `about:config` the
  same setting must be `true`.

## Screen sharing does nothing (Discord, browsers, OBS)

Sharing the screen goes through a small helper called
`xdg-desktop-portal-hyprland`. When the Share button does nothing, check it:

```bash
systemctl --user status xdg-desktop-portal-hyprland
```

If it says `failed` (often with `start-limit-hit`), it crashed several times in
a row and systemd gave up. Start it again:

```bash
systemctl --user reset-failed xdg-desktop-portal-hyprland
systemctl --user start xdg-desktop-portal-hyprland
```

If it fails again straight away, the usual cause is that the systemd user
session has the wrong display. The portal needs `WAYLAND_DISPLAY` and
`XDG_CURRENT_DESKTOP` to be the ones of the running Hyprland. Check them:

```bash
systemctl --user show-environment | grep -E 'WAYLAND_DISPLAY|HYPRLAND_INSTANCE|XDG_CURRENT'
```

`WAYLAND_DISPLAY` should be `wayland-1` and the instance signature should match
the one in `hyprctl instances`. If they are wrong (for example after starting a
second Hyprland inside a window for testing), put the right values back and
start the portal again:

```bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP
systemctl --user reset-failed xdg-desktop-portal-hyprland
systemctl --user start xdg-desktop-portal-hyprland
```

The portal's own settings (frame-rate limit and the NVIDIA fallback) are in
`~/.config/hypr/xdph.conf`; see [Desktop](desktop.md#screen-sharing).

## GitHub Desktop stays on "signing in"

After you approve the sign-in in the browser, GitHub sends the app a link that
starts with `x-github-desktop-dev-auth://`. The upstream app does not act on
that link on Linux, which is a known problem on NixOS (nixpkgs issue 344911).
This flake ships a patched build (`pkgs/github-desktop.nix`) that does.

- Use the copy from the flake, not one installed with `nix profile install`.
  The profile copy comes first on `PATH` and is the unpatched one. Check with
  `type -a github-desktop` (the first line should start with `/run/current-system`)
  and remove the profile copy with `nix profile remove github-desktop`.
- Quit GitHub Desktop completely and start it again after a rebuild. A copy that
  is already running keeps the old code.
- The first time, the browser asks whether to open the link in GitHub Desktop.
  Allow it (and tick "always allow"). If you clicked cancel with "remember"
  ticked, clear the saved choice for `x-github-desktop-dev-auth` in the
  browser's settings under Applications.
- To see whether the app received the link, look at its log
  (`~/.config/GitHub Desktop/logs/`). A received link writes
  `Processing protocol url`. You can test the hand-off without signing in:
  `gio open 'x-github-desktop-dev-auth://oauth?code=test&state=test'` should add
  that line. (Use `gio open`, not `xdg-open`: with `xdgOpenUsePortal` on, plain
  `xdg-open` sends custom links through the portal, which does not deliver them
  to this app here. Browsers use the direct route that `gio open` tests.)
- After the link arrives, the app saves the token in the keyring (gnome-keyring,
  started by Hyprland). If sign-in still hangs after `Processing protocol url`
  appears, check that the keyring is unlocked:
  `gdbus call --session --dest org.freedesktop.secrets --object-path /org/freedesktop/secrets/collection/login --method org.freedesktop.DBus.Properties.Get org.freedesktop.Secret.Collection Locked`

## Microphone goes silent with EasyEffects running

Discord (and other apps) listen to **Easy Effects Source**, which only has sound
when EasyEffects is connecting the real microphone to its effect chain. If its
saved settings are lost (EasyEffects 8 has been seen to do this), that connection
can be missing while an app is recording, and everything hears silence even
though the microphone is fine.

- Run `~/.scripts/pwnbox-easyeffects`. It starts EasyEffects if it is not
  running and loads the **Mic-Gate** preset if it is not the loaded one.
- To check the connection, an app must be recording first; with nothing
  recording, EasyEffects shows no connections and that is normal. Then
  `pw-link -l` should show the microphone (`alsa_input.usb-Logitech_G522...`)
  feeding `ee_sie_gate`, then `easyeffects_source`.
- Load the preset by hand with `easyeffects --load-preset Mic-Gate`. Do it once;
  it does not need repeating.
- If EasyEffects does not quit, find its process with `ps -eo pid,args | grep
  easyeffects`, stop that, and run the script again.

## The wrong microphone is used

The microphone in use is decided in three places: the system default
(`wpctl status`, the line with `*` under Sources), what each program asks for
(Discord opens one stream per microphone it can see), and EasyEffects, which
moves programs that use the default onto its virtual microphone. The G522 is
pinned in `hosts/nix/audio.nix` (see [Apps](apps.md#which-microphone-is-used)).
To look at it:

```bash
wpctl status                       # the default microphone has a * in front
wpctl set-default <number>         # choose another one by its number
pw-dump | grep -E 'node.name|target.object'
```

## Telegram (AyuGram)

- While AyuGram runs, the theme file is rewritten and AyuGram reloads it live.
- The first time (or after the theme path changes), the path must be
  registered, which requires Telegram to be closed. Close and reopen it once;
  after that updates are live.
- Fonts are written to AyuGram's settings only while Telegram is closed.

## Fonts or font sizes didn't change

Run the pickers again and confirm the state files:

```bash
cat ~/.cache/pwnbox/theme/font-ui ~/.cache/pwnbox/theme/font-app
cat ~/.cache/pwnbox/theme/font-size-ui ~/.cache/pwnbox/theme/font-size-app
~/.scripts/pwnbox-theme borders
```

kitty is signalled automatically; Quickshell is restarted automatically.

## A build failed

Re-run verbosely and read the tail:

```bash
./install.sh switch --verbose
```

The full log is at `/tmp/pwnbox-install.log`. If the system is unusable, boot
an older generation from the boot menu.

## GTK apps keep the old colours

GTK reloads its colour scheme awkwardly. The theme script toggles the GNOME
colour scheme to nudge it; if a specific app still lags, restart that app.

## Out of disk space

Garbage collection runs daily and keeps 7 days. To reclaim more:

```bash
sudo nix-collect-garbage -d
```

## Ly / login screen

LY reads the palette statically from `system/desktop/ly.nix`, so it does
not follow wallpaper themes at runtime. Change it there if needed.

## Mullvad does not connect

```bash
mullvad status                      # Disconnected / Connecting / Connected
mullvad account get                 # shows the account, or that you are not logged in
systemctl status mullvad-daemon     # the daemon must be running
```

If it says you are not logged in: `mullvad account login <your account number>`.
The defaults (connect at boot, allow the local network) are applied once by
`mullvad-defaults.service`; to apply them again, delete
`/var/lib/pwnbox/mullvad-defaults-v1` and run `sudo systemctl restart mullvad-defaults`.
If the network is down after turning the kill switch on, turn it off:
`mullvad lockdown-mode set off`.

## Where to look

| Area | Path |
| --- | --- |
| Theme engine | `~/.scripts/pwnbox-theme` |
| Saved state | `~/.cache/pwnbox/theme/` |
| Spotify watcher log | `~/.cache/pwnbox/spotify-watch.log` |
| Quickshell Theme | `~/.config/quickshell/Theme.js` |
| Installer log | `/tmp/pwnbox-install.log` |
