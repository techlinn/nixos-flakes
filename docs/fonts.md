# Fonts

pwnbox has two independent font settings, both in `ALT + S`:

| Setting | Default | Used for |
| --- | --- | --- |
| **System font** | `Manrope` | UI text: bar, rofi, fuzzel, GTK, Discord, Spotify |
| **System font size** | `11` | The size of that UI text |
| **Application font** | `Berkeley Mono` | Monospace text: terminal, code, Zed buffers. Berkeley Mono is a commercial font: its two files (`Berkeley Mono Regular.ttf` / `.otf`) are in `dotfiles/gnome/fonts/` on this machine, but they are left out of anything published (see `PUBLIC-ARCHIVE.txt`); without them programs fall back to another monospace font (the terminal to Iosevka). To add your own copy, drop the files into `dotfiles/gnome/fonts/` and run `upd`. Pick an installed one with `ALT + S → Application font` |
| **Application font size** | `9` | The size of that monospace text |

Sizes are chosen from `7 8 9 10 11 12 13 14 15 16 18 20`. The settings are
stored in `~/.cache/pwnbox/theme/font-ui`, `font-app`, `font-size-ui` and
`font-size-app`, and re-applied on login.

## Font choices

Pick from a curated list that includes:

`Manrope`, `Fairfax HD`, `Ubuntu`, `Berkeley Mono`, the Spleen bitmap fonts,
`Iosevka`, `JetBrains Mono`, `MesloLGS`, `FiraCode`, `Inconsolata`,
`Noto Sans`, `DejaVu Sans` and `Liberation`. Each comes with its Nerd Font
variants where available. Everything is installed by the flake; nothing is
downloaded at runtime.

## Where each font lands

| App | System font | Application font |
| --- | --- | --- |
| Quickshell (bar/panels) | `fontFamily` + `fontSize` | icons via Nerd Font |
| kitty | n/a | `font_family` + `font_size` |
| rofi | `font` | n/a |
| fuzzel | `font` | n/a |
| GTK 3/4 + GNOME | `gtk-font-name` / gsettings | n/a |
| Hyprlock | `font_family` | n/a |
| Zed | `ui_font_family` + `ui_font_size` | `buffer_font_family` + `buffer_font_size` |
| Discord (Equibop) | `--font` + root size | `--font-code` |
| Spotify | body text + root size | code / monospace |
| Telegram (AyuGram) | system (Qt) | `monoFont` |
| Zathura | n/a | `set font` |

Apps that run inside the terminal (micro, Neovim, ranger, btop, neofetch, …)
inherit the kitty font automatically.

## How it is applied

`~/.scripts/pwnbox-theme` regenerates each app's font configuration whenever
the font or size changes:

- managed config files stay read-only; a generated *include* or a generated
  companion file carries the font (for example `~/.cache/pwnbox/theme/kitty.conf`
  is included at the end of `kitty.conf`).
- Spotify reads `~/.config/spicetify/Themes/pwnbox/user.css`, which is composed
  from a managed base plus a generated font block.
- Zathura reads a generated `zathura.conf` through an `include` in `zathurarc`.

When a font changes, kitty is signalled to reload and Quickshell is restarted
automatically.
