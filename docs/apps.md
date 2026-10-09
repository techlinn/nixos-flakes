# Apps

pwnbox themes far more than the desktop shell. This page explains how each app
gets its colours and fonts, and which ones update live while running.

## Live theming (no restart)

When you change the theme, three apps refresh themselves in place (OBS, Zen and IDA
need a restart, see further down):

| App | Mechanism |
| --- | --- |
| **Spotify** | Spicetify `watch` refreshes the injected CSS and reloads the UI |
| **Discord (Equibop)** | Equibop watches `quickCss.css` and hot-applies it |
| **Telegram (AyuGram)** | AyuGram watches the theme file and reloads it |

You can keep them open. `ALT + S` is enough.

| App | When it changes |
| --- | --- |
| **OBS Studio** | The next time OBS starts |
| **Zen** | The next time Zen starts |
| **IDA Pro** | The next time IDA starts |

## Spotify

Spotify is patched with [Spicetify](https://spicetify.app) so it can be
themed. Because nixpkgs' Spotify lives read-only in the Nix store,
`pwnbox-spotify` keeps a writable copy under `~/.local/share/pwnbox/spotify`
and patches that.

- Palette → `~/.config/spicetify/Themes/pwnbox/color.ini`: black and neutral
  greys (computed from white and black, never from the theme's tinted text
  colour) and the theme's outline colour as the accent.
- Layout + full theming → `user.css`, composed at runtime from the managed
  `user-base.css` plus two generated blocks: the outline colour and corner radius
  (`--pwnbox-outline`, `--pwnbox-radius`) and the fonts.
- The outline colour is the theme's border colour (`border` in `theme.conf`, the
  same one the window border uses), otherwise the focused-window colour. It is
  drawn on the edges of the four panels (library, main view, now-playing sidebar,
  player bar), text fields, menus, dialogs and tooltips, and on the primary
  button (play, log in), which is an outline and not a filled block. It is never
  used for big fills. Corners follow the **UI corner radius** setting.
- Each thing has ONE outline. The top search box is outlined once, on its outer
  box (Spotify nests five elements in it); a play button is outlined on the span
  inside it, which is what Spotify fades in on hover, so the empty squares over
  Home cards do not show; a row of filter chips is not boxed as a whole. The
  chosen chip is outlined instead of a white pill, the "now playing" bars and the
  verified tick are in the outline colour, toasts are dark with an outline, and
  the round scroll arrows and pills are square.
- Two small things (the pale "Artist pick" label and the blue "#8 in the world"
  circle) are matched by Spotify's generated class names (`Jd9liNKX5WkQCz9T`,
  `UaFGUZb384McvxOx` in `user-base.css`); a Spotify update can rename them. If
  one turns pale or blue again, inspect it in the debug window (port 9222) and
  swap in the new class name. The rules that must beat the older copy of the
  stylesheet Spotify may still carry are written as `:root:not(#_) ...`.
- Spotify's window gets the same pink border as every other window (there used
  to be a rule that painted it black).
- The base CSS themes **inputs, search fields, context menus, popovers, modals,
  tooltips and buttons**, flattens Spotify's artwork gradients and **removes
  every scrollbar**.
- Fonts follow the System (body) and Application (code) fonts.

Live updates use `spicetify watch -s -l`. The launcher passes
`--remote-debugging-port` so the watcher can attach without relaunching
Spotify; a background helper keeps the watcher alive.

Commands:

```bash
pwnbox-spotify apply
pwnbox-spotify fonts
pwnbox-spotify launch
```

## Discord (Equibop)

Equibop is the Discord client (Equicord). On every theme change `pwnbox-theme`
writes `~/.config/equibop/settings/quickCss.css`, which Equibop watches and
applies live. No `Ctrl + R` needed. The file has two parts:

1. **Your own CSS**, `~/.config/equibop/theme-base.css` (snippets and tweaks),
   with every colour written in it swapped for the nearest colour of the
   current theme.
2. **The theme's palette**, added at the end. Discord paints almost everything
   with its own named colours (`--background-base-low`, `--text-default`,
   `--control-primary-background-default`, links, status dots, code blocks ...),
   and the snippets above never mention most of them, so recolouring alone left
   the buttons and links grey. This part sets those names from the theme:
   a short block of `--pw-*` colours written by the script, followed by
   `~/.config/equibop/pwnbox-tokens.css` (from `dotfiles/config/equibop/`),
   which only refers to those. It also feeds the old-style variables that the
   DiscordRecolor and BlurpleRecolor snippets read (`--accentcolor`,
   `--textdark` ...).

Text is kept readable on every theme: the script works out a link colour and
status colours that contrast with the chat background, and a text colour for
buttons filled with the accent.

Fonts are set through `--font` (System) and `--font-code` (Application), plus a
generated root font size. The network font imports were removed; local fonts
are used instead.

## Telegram (AyuGram)

AyuGram is configured through `tg-config`, which writes into Telegram's
encrypted `tdata`.

- Palette → `~/.config/telegram/pwnbox.tdesktop-theme` (generated from
  `awesome.tdesktop-theme`, with a flat solid chat background colour).
- AyuGram watches that file, so rewriting it reloads the colours **live**.
- Fonts: the application font is written into AyuGram's `monoFont` setting;
  Telegram's UI uses the system font.

- A theme can carry its own Telegram colours in a
  `telegram.tdesktop-theme` file next to its `theme.conf`: each `key: value;`
  line replaces that key in the generated theme. Acanthus uses it to give
  Telegram its red and rose where the base theme has plain white and blue.

`pwnbox-theme` only syncs `tdata` (which requires Telegram to be closed) when
AyuGram is not running. While it is running, the theme file is rewritten and
AyuGram reloads itself.

## GitHub Desktop

Installed from the flake as `github-desktop`, but through `pkgs/github-desktop.nix`
rather than straight from nixpkgs. nixpkgs builds the upstream source, which
ignores the link GitHub sends back after "Sign in with browser" on Linux, so
the app waits on "signing in" forever. The package reuses the built app and
only patches that one file; see the comments at the top of the file. If a
nixpkgs update makes the build stop with `patch did not apply`, check whether
upstream has fixed it (then use plain `pkgs.github-desktop` again) or adjust the
pattern in that file. Troubleshooting: [Troubleshooting](troubleshooting.md).

## OBS Studio (recording and streaming)

`obs-studio` is installed from the flake (`system/packages.nix`, the
`apps` list). It is also in the optional `creative` list, but that list stays
off, so OBS comes on its own. Open it from the launcher (`CTRL + SPACE`, type
"OBS").

- **Capturing the screen on Wayland:** add a **Screen Capture (PipeWire)**
  source. It uses the screen-sharing portal (see Troubleshooting if the picker
  does not appear), and the same picker is used for a single window.
- **Hardware encoding:** the NVIDIA encoder is available as *NVIDIA NVENC* in
  Settings, then Output, which keeps recording light on the CPU.
- **Microphone:** add an **Audio Input Capture** source. Use *Easy Effects
  Source* for the gated microphone or the headset itself for the raw one.
- **Colours:** `pwnbox-theme` writes `~/.config/obs-studio/themes/Pwnbox.ovt`
  (a variant of OBS's own *Yami* theme with the current palette) and selects it
  in `user.ini`. OBS reads it when it starts, so close and reopen OBS after
  changing the theme. If OBS is open at the time, the theme file is still
  updated, and the selection is written the next time you change theme with
  OBS closed (you can also pick *Pwnbox* under Settings, General, Theme).

## Zen (browser)

`pwnbox-theme` writes `chrome/userChrome.css` (the browser window: sidebar, tabs,
address bar, menus) and `chrome/userContent.css` (Zen's own pages: settings,
new tab, downloads) into the Zen profile, and turns on
`toolkit.legacyUserProfileCustomizations.stylesheets` in the profile's `user.js`,
which Zen needs before it reads them. Zen reads these files **only when it
starts**, so restart Zen after changing the theme. Web pages keep their own
colours.

Zen normally paints its window with a per-space gradient; the theme replaces it
with the flat theme colour. If you want Zen's own space colours back, delete
`userChrome.css` in the profile folder (`~/.config/zen/<profile>/chrome/`) and
stop the script from rewriting it by removing `apply_zen` from `apply_borders`
in `dotfiles/scripts/pwnbox-theme`.

## IDA Pro

### Installing it

IDA is commercial software, so the flake cannot contain it: you supply the
installer (`ida-pro_*_x64linux.run`), and the licence is yours too. Everything
around it is in the flake: the libraries a downloaded program like IDA needs
(`programs.nix-ld` in `system/nix.nix`), the theme, and the command that
puts it together:

```bash
ida-install                      # uses the newest installer found in ~/Downloads
ida-install /path/to/ida-pro_94_x64linux.run
IDA_PREFIX=~/tools/ida ida-install   # another install folder (default: ~/IDA)
```

It runs the installer unattended, writes `~/.idapro/ida-config.json` if the
installer did not, links IDAPython to the Python of the system profile
(`/run/current-system/sw/lib/libpython3.*.so.1.0`; that path is kept up to date
by every rebuild, whereas the `/nix/store` path `idapyswitch` finds on its own
is removed by the garbage collection after a Python update, which would quietly
break IDAPython), and applies the theme. Run again at any time: an existing
install is kept and only the setup steps are repeated. Nothing is downloaded
and nothing touches licences. Start IDA from the launcher the installer adds
(IDA Professional) and accept the first-run screens as usual.

### The theme

IDA's look is CSS (`themes/<name>/theme.css`), so it gets its own theme called
**pwnbox**. `dotfiles/config/ida/pwnbox-theme.css` is the fixed look (menus,
buttons, tabs, scrollbars, disassembly, graph, hex view, navigation band); it
only uses `${pw_*}` colour names. `pwnbox-theme` writes the values for those
names from the current palette, puts both in `~/.idapro/themes/pwnbox/theme.css`
and redraws the combo-box arrow in the theme colours.

The look is pure black with neutral greys (editor `#000`, panels `#0a0a0a`,
hover `#141414`, selection `#1c1c1c` on a black theme) and the theme's border
colour as the outline: the colour of the window border (`border` in
`theme.conf`, otherwise the accent, colour 4). That red is used for outlines
only, never as a fill: buttons, inputs, combo boxes, menus, tooltips and list
frames, check boxes, the active tab's underline, graph edges and the frame of
the selected graph node. Every grey is computed from white and black, never
from the theme's tinted text colour, so nothing reads as a dim version of the
accent. Code is light grey. Colour is kept only where tokens need telling
apart: strings (colour 2), numbers (3), registers (6), imports (11), library
functions (14), cross references (10, 14) and errors (red). Every colour is
nudged so it reads on the black and on a selected line, whatever the theme.
Square or rounded controls follow the **UI corner radius** setting (up to 6 px).

IDA reads the theme **only when it starts**, so restart IDA after changing the
theme. IDA keeps its chosen theme in `~/.idapro/ida.reg`, which it rewrites when
it quits, so that setting is never edited by hand: the script uses `idat` (IDA's
console version) to select **pwnbox** once, while IDA is closed. If IDA is open
when you change theme, a small background watcher waits for it to quit and does
it then. If you ever pick another theme under Options, Colors, the next theme
change puts pwnbox back. Fonts are left to IDA (Options, Font), because the
disassembly needs a fixed-width font.

If IDA is installed somewhere other than `~/IDA`, nothing needs changing: the
script reads the install folder from `~/.idapro/ida-config.json`.

## EasyEffects (microphone gate)

`easyeffects` is installed and started in the background at login by
`~/.scripts/pwnbox-easyeffects` (`exec-once` in `hyprland.conf`). The script
makes sure one preset, **Mic-Gate**, is loaded: a plain noise gate on the
microphone that makes no change to the volume and only turns the microphone
down between words. The preset is kept in `dotfiles/config/easyeffects/input/`
and copied to `~/.local/share/easyeffects/input/` when missing, so changes you
make to it are kept. To change the gate, open EasyEffects from the launcher
(`CTRL + SPACE`, type "Easy Effects") and use the **Input** tab.

EasyEffects creates a virtual microphone called **Easy Effects Source**; only
programs that use it get the effects. It has no connection to the headset while
no program is recording from it, which is normal.

### Which microphone is used

`hosts/tower/audio.nix` makes the Logitech G522 headset the preferred
microphone and speaker (the rule gives it the highest priority) and switches off
the webcam's sound card, so the webcam's microphone can never be chosen.
Before this, the headset and the webcam microphone ranked exactly the same and
the default could flip between them, and Discord opened a stream on every
microphone it could see, including the webcam's. To bring the webcam
microphone back, delete the first rule in that file and run `upd`, or, until the
next restart of the audio service, turn its profile on again in `pavucontrol`
under Configuration. Other machines need their own names (`wpctl status`).

## Editors & terminals

| App | Theme | Fonts |
| --- | --- | --- |
| **kitty** | generated `kitty.conf` include | Application font + size |
| **Zed** | `~/.config/zed/themes/pwnbox.json` | UI + buffer fonts/sizes |
| **Neovim** | generated `nvim-palette.lua` | inherits the terminal |
| **micro / ranger** | terminal colours + config | inherit the terminal |

## GTK & launchers

- **GTK 3 / 4 / GNOME.** `~/.cache/pwnbox/theme/gtk-colors.css` is imported by
  the GTK config, and `gsettings`/`dconf` keep fonts and colour scheme in sync.
- **rofi.** Imports `~/.cache/pwnbox/theme/rofi.rasi`.
- **fuzzel.** Uses `~/.cache/pwnbox/theme/fuzzel.ini`.
- **Zathura.** A generated include (`~/.cache/pwnbox/theme/zathura.conf`) sets
  the application font.

## Desktop shell

Quickshell, Hyprland borders, Hyprlock and the notification daemon all read
`~/.config/quickshell/Theme.js` and the generated Hyprland include. See
[Desktop](desktop.md).

The Alt+Tab switcher runs as a second Quickshell instance from
`~/.config/quickshell-overlays`. It reads the same `Theme.js`, and
`pwnbox-theme` restarts that instance together with the bar, so it follows
every theme change.
