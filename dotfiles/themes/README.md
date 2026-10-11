# Custom pwnbox themes

Each **subfolder** here that contains a `theme.conf` is a custom colour theme.
It appears in the `ALT + S` settings menu under **THEME → Custom** as a
thumbnail card: its wallpaper with the theme name below.

```
dotfiles/themes/
├── Monochrome/             # the built-in grey theme (the ALT+S default)
│   ├── theme.conf
│   └── wallpaper.png
├── Tokyo-Night/            # a theme
│   ├── theme.conf          # the colours (required)
│   └── wallpaper.jpg       # the wallpaper it uses (optional but recommended)
├── Catppuccin-Mocha/
│   ├── theme.conf
│   └── wallpaper.png
├── Autumn-Camp/  Seaside/  Ash/  Post-Town/  Overcast/  Back-Alley/
├── Dusk-Indigo/  Violet-Hour/  City-Lights/  Snowfall/  Lantern-Forest/
├── Cream-Outline/  Terracotta/  Vending-Snow/  Neon-Haze/
├── Silhouette/  Statue/  Mist/  Night-Dune/  Fog-Lamps/  Dot-Matrix/
└── Dune-River/  Smoke-Grain/  Dark-Room/  Voxel-Dusk/  Acanthus/
    ├── theme.conf          # hand-tuned from the wallpaper next to it
    └── wallpaper.jpg       # (or .png)
```

Unlike the wallpaper picker (which extracts a palette from an image with
pywal), a custom theme has a **fixed** palette that you write down yourself and
a **fixed** wallpaper, so the colours do not depend on the image.

## `theme.conf`

An INI-style file: `key = value`, one per line. Blank lines are ignored and
`#` or `;` only start a comment at the beginning of a line (so hex colours such
as `#1a1b26` are fine).

| Key | Meaning |
| --- | --- |
| `name` | Label shown in the picker. Defaults to the folder name. |
| `wallpaper` | Image used by the theme, relative to this folder (or absolute). Defaults to the first image in the folder, then to the bundled default wallpaper. |
| `background` | Window/terminal background. |
| `foreground` | Main text colour. |
| `cursor` | Text cursor. Defaults to `foreground`. |
| `color0` … `color15` | The 16-colour terminal palette. |
| `border` | Optional. Colour of the focused window's border and of panel outlines; otherwise it is worked out from the palette. |
| `accent_strong`, `accent_fill`, `accent_deep`, `on_accent`, `link`, `selection`, `success`, `success_text`, `warning`, `error` | Optional. The colours a theme names for itself instead of letting them be derived. Use them when the palette cannot say it: a fill that is darker than the accent, a status colour the palette has no hue for, text that must read on the accent. Each one is a single hex in this file and reaches every app that needs it. Anything left out stays derived, so a theme that names none looks exactly as before. See `Acanthus/theme.conf`. |

A theme is only ever these two things. There is no per-app file: a `discord.css`,
`nvim.lua`, `zed.json`, `zen.css`, `obs.txt`, `gtk.css` or
`telegram.tdesktop-theme` next to `theme.conf` is **ignored**. Every app's
colours are worked out from the palette and the keys above, so a colour is
written down once and reaches all of them.
| `bar_style`, `window_radius`, `ui_radius`, `transparency`, `app_font` | Optional "look": the bar style, corner radii (px) and window opacity (%) that go with the theme. They are applied when the theme is chosen and your previous values come back when you choose another theme. See `Acanthus/theme.conf`. |

Any colour you leave out falls back to the monochrome palette, so a minimal
theme is just:

```ini
name = My theme
background = #101014
foreground = #e6e6e6
```

The Quickshell bar/notifications, rofi, GTK apps, window borders and the
editor's accent colours are all derived from the 16 colours above (see
`dotfiles/config/wal/templates/`), exactly like a wallpaper theme.

## Adding a theme

1. Create `dotfiles/themes/<Name>/theme.conf` (copy `Tokyo-Night` as a base).
2. Drop a wallpaper in the same folder.
3. `nixos-rebuild switch` (the folders are linked from the flake), then choose
   it from `ALT + S → THEME → Custom`.

The command line equivalent is `pwnbox-theme custom`.
