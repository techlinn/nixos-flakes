# Desktop

pwnbox ships two Wayland sessions. **Hyprland** is the default; **GNOME** is
kept as a second choice at the login screen (LY).

## Sessions

| Session | Notes |
| --- | --- |
| Hyprland | Default; Quickshell bar, notifications and power menu |
| GNOME | Full GNOME Shell, also themed from the same palette |

At login, LY shows the clock and the session picker. GNOME is configured with
`dconf` so its fonts, colours and extensions match the rest of the system.

## Hyprland

Window management is configured in `dotfiles/config/hypr/hyprland.conf`:

- `general`. Gaps, borders (border colour is generated from the theme).
- `decoration`. Rounding, opacity (solid when focused, except the terminal), shadow and blur (all driven by `ALT + S`).
- `animations`. Toggled from the settings menu.
- `monitor = , <resolution>, auto, auto`. From `pwnbox.desktop.resolution`.

Autostarted at login:

- `swaybg` with the last wallpaper
- `pwnbox-theme restore`. Re-applies the saved theme
- `hypridle`. Locks the screen before a manual sleep. Nothing happens on its own when the PC is idle: no automatic lock, screen-off or sleep (see `hypr/hypridle.conf` to turn that back on)
- `hyprpolkitagent`
- `qs -n`. Quickshell
- `gnome-keyring-daemon`
- `cliphist` (text + images)

### Screen sharing

Discord, browsers and OBS capture the screen through
`xdg-desktop-portal-hyprland`. Its settings are in `dotfiles/config/hypr/xdph.conf`
(deployed to `~/.config/hypr/xdph.conf`): capture is limited to 60 frames per
second, because the 164 Hz monitor would otherwise feed Discord frames faster
than it can send them, and frames are copied through ordinary memory
(`force_shm = true`) because NVIDIA's direct hand-over let recorders read a
frame that was still being drawn, which showed as tearing whenever a lot
redrew at once. The portal reads the file when it starts:

```bash
systemctl --user restart xdg-desktop-portal-hyprland
```

## Quickshell

The bar, notifications, volume OSD, power menu, calendar and system panel are
built with Quickshell. The shell root is
`dotfiles/config/quickshell/shell.qml`.

### Bar styles

`ALT + S → Style` switches between eleven bar layouts. The selected style is
stored in `~/.cache/pwnbox/theme/barstyle` and applied live.

| Style | Description |
| --- | --- |
| `islands` | Boxed groups (default) |
| `floating` | Floating islands |
| `flat` | Classic flat bar |
| `pill` | Centered pill |
| `capsule` | Rounded capsule |
| `bottom` | Bottom dock |
| `split` | Split pills |
| `blocky` | Blocky groups |
| `ghost` | Ghost outlines |
| `minipills` | Mini pills |
| `noir` | Noir pills |

**Noir** is the one with buttons. Six fully round pills on a clear bar, as
see-through as your windows (`ALT + S → Transparency`):

| Pill | What it does |
| --- | --- |
| Far left | The icon opens the app launcher. The arrow slides a drawer open with quick actions: terminal, files, browser, screenshot of an area, themes (`ALT + S`), system panel |
| Workspaces | A Pac-Man sits on the workspace you are on and glides to the next one. Rings are the others (filled in when they have windows). Click a ring to go there, scroll to step through. Six are shown, more while a higher workspace is in use. A music note appears while a player is running: click for play/pause, scroll for next/previous |
| Clock | The time; the date slides out while the pointer is on it. Click for the calendar |
| App bar | One icon for every app that has a window open; apps that only run in the background (Steam, or Discord closed to the tray) follow. Left click goes to the app, and again steps through its windows; middle click closes its window; right click opens its tray menu if it has one. The app you are in has a small mark under its icon. The terminal, Discord, the file manager, Spotify and Obsidian have icons of their own (`dotfiles/config/quickshell/icons/*.png`: your icon set, 128 px) drawn in the bar's accent colour, so they follow the theme; every other app gets the same look made from its own icon: a pink glyph on a small dark tile (an app with no icon at all gets its initial in a pink ring). Status icons in the tray, such as Mullvad's lock, keep their own colours. To give another app one, add a PNG there (a light symbol on a dark tile works best) and its name to `customIcons` in `NoirApps.qml` |
| Status | **Bluetooth**: its switch, scanning, and the devices to connect or disconnect. **Sound**: output and microphone volume, which device each uses, and one slider per app that is playing (scroll on the icon changes the volume, middle click mutes). **Network**: the wired link with its address and speed, the Wi-Fi switch and the networks in range (a new protected one asks for its password) |
| Far right | The arrow or the power icon slides the session drawer open: lock, log out, suspend, reboot, shut down. Log out, reboot and shut down need a second click within three seconds, so a slip does nothing |

Every icon shows a small label when the pointer rests on it. A drawer closes by
itself a few seconds after the pointer leaves it, and a panel closes when you
click anywhere else or press Escape.

The highlight colour is the focused window's border colour, so bar, panels and
windows match in every theme. The files are in `dotfiles/config/quickshell`:
`BarStyle11.qml` (the bar), `NoirWorkspaces.qml`, `Pacman.qml`, `NoirStatus.qml`,
`NoirApps.qml`, `NoirPanels.qml` with `NoirBluetoothPanel.qml`,
`NoirAudioPanel.qml` and `NoirNetworkPanel.qml`, and the shared pieces
`NoirState.qml`, `NoirSlider.qml`, `NoirSwitch.qml`, `NoirTip.qml`.

Each style's geometry (height, edge, exclusive zone, clock alignment) is
defined once in `dotfiles/config/quickshell/BarStyles.js` and shared by the bar
and the calendar, so the calendar popup always opens against the real bar,
including the bottom dock.

### Panels

- **Clock.** Click to toggle the calendar (`qs ipc call calendar toggle`).
- **Calendar.** Date, current time, media controls and a month view.
- **System panel.** CPU, memory, disk, swap and network.
- **Power menu.** Lock, logout, suspend, reboot, shutdown.
- **Notifications.** Popups plus an overlay, with actions and images.
- **Volume OSD.** Appears on volume changes.

### Reloading Quickshell

The theme scripts restart it automatically when needed. To do it by hand:

```bash
qs -n
```

## Rofi

Rofi is used for the launcher (`CTRL + SPACE`), the theme/settings menu
(`ALT + S`), the wallpaper and custom-theme pickers and the bar-style picker.
All of them import the generated palette from
`~/.cache/pwnbox/theme/rofi.rasi`.

## Fuzzel

Fuzzel is used for the clipboard history picker
(`SUPER + \``).

## Lock screen

`hyprlock` shows the current wallpaper (blurred) with the theme's colours, the
system font and the same corner radius as the panels; a theme that names a
border colour gets it as the outline of the password field. `pwnbox-theme`
writes these to `~/.cache/pwnbox/theme/hyprlock.conf` whenever the theme, the
wallpaper or the fonts change, and `~/.config/hypr/hyprlock.conf` reads them.
