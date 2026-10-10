# Fonts

pwnbox has three font settings, all in `ALT + S`:

| Setting | Default | Used for |
| --- | --- | --- |
| **System font** | `Manrope` | Everyday apps, the same font Discord uses: GTK apps (virt-manager ...), Qt apps, Zen's interface and pages, Telegram, Spotify, Zathura |
| **System font size** | `11` | The size of that text |
| **Desktop font** | `Berkeley Mono` | The top bar and its panels, the launchers (rofi, fuzzel), the lock screen, window title bars, Zed's interface, and the monospace text inside everyday apps (code blocks in Discord, Spotify, Telegram and Zen, virt-manager's XML editor) |
| **Application font** | `JetBrains Mono` | Code tools only: terminal (kitty, so Vim and everything run in it), Neovim, Zed's editor, IDA's code views, and the tools that ask the system for "monospace" (Ghidra, Binary Ninja, Wireshark ...). Pick an installed one with `ALT + S → Application font` |
| **Application font size** | `9` | The size of that monospace text |

Discord always uses `Manrope` for its text, whatever the system font is.

Berkeley Mono is a commercial font: its two files (`Berkeley Mono Regular.ttf` / `.otf`) are in `dotfiles/gnome/fonts/` on this machine, but they are left out of anything published (see `PUBLIC-ARCHIVE.txt`); without them programs fall back to another font. To add your own copy, drop the files into `dotfiles/gnome/fonts/` and run `upd`. JetBrains Mono is free and installed by the flake.

Manrope also leads the system-wide font fallback for sans-serif and serif, so Qt apps follow it without any setting (that includes the menus of Qt reverse-engineering tools such as IDA and Wireshark; their code views keep the application font). The system-wide "monospace" default is JetBrains Mono, which is what the reverse-engineering tools (Ghidra, Binary Ninja, Wireshark) pick up. The non-code apps that would also pick it up are set explicitly: Zen (its font preferences in `user.js`) and GTK apps such as virt-manager (a generated `gtk-fonts.css`) use the desktop font for monospace text. Websites that name their own fonts keep them.

Sizes are chosen from `7 8 9 10 11 12 13 14 15 16 18 20`. The settings are
stored in `~/.cache/pwnbox/theme/font-ui`, `font-desk`, `font-app`, `font-size-ui` and
`font-size-app`, and re-applied on login.

## Font choices

Pick from a curated list that includes:

`Berkeley Mono`, `JetBrains Mono`, `Manrope`, `Fairfax HD`, `Ubuntu`, the Spleen bitmap fonts,
`Iosevka`, `MesloLGS`, `FiraCode`, `Inconsolata`,
`Noto Sans`, `DejaVu Sans` and `Liberation`. Each comes with its Nerd Font
variants where available. Everything is installed by the flake; nothing is
downloaded at runtime.

## Where each font lands

| App | System font | Application font |
| --- | --- | --- |
| Quickshell (bar/panels) | `fontFamily` + `fontSize` (the desktop font) | icons via Nerd Font |
| kitty | n/a | `font_family` + `font_size` |
| rofi | `font` (the desktop font) | n/a |
| fuzzel | `font` (the desktop font) | n/a |
| GTK 3/4 + GNOME | `gtk-font-name` / gsettings | n/a |
| Hyprlock | `font_family` (the desktop font) | n/a |
| Zed | `ui_font_family` (the desktop font) + `ui_font_size` | `buffer_font_family` + `buffer_font_size` |
| Discord (Equibop) | always `Manrope`, root size follows the system font size; code blocks use the desktop font | n/a |
| Spotify | body text + root size; code uses the desktop font | n/a |
| Telegram (AyuGram) | text (the system's sans-serif); `monoFont` uses the desktop font | n/a |
| Zathura | `set font` | n/a |
| Zen | `font.name.*` preferences: pages use the system font, code blocks the desktop font | n/a |
| GTK apps (virt-manager ...) | `gtk-font-name`; monospace text via `gtk-fonts.css` (the desktop font) | n/a |
| IDA | n/a | code views (set through `idat`) |

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
