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
| *(file)* `discord.css` | Optional, next to `theme.conf`: CSS added after the generated Discord palette, for a theme that wants its own accent there. See `Acanthus/discord.css`. |
| *(file)* `zen.css`, `obs.txt`, `gtk.css` | Optional, next to `theme.conf`: extra CSS for Zen, extra variable lines for OBS's theme, and extra GTK colours, added after the generated ones. See `Acanthus/`. |
| *(file)* `nvim.lua` | Optional, next to `theme.conf`: Neovim colours (`highlights` per group, `lualine` mode-chip colours). See `Acanthus/nvim.lua` and `config/nvim/lua/config/theme.lua`. |
| *(file)* `zed.json` | Optional, next to `theme.conf`: Zed style keys (`syntax`, `editor.*`, `text` ...) laid over the generated Zed theme. See `Acanthus/zed.json`. |
| *(file)* `telegram.tdesktop-theme` | Optional, next to `theme.conf`: `key: value;` lines that replace those keys in the generated Telegram theme. See `Acanthus/telegram.tdesktop-theme`. |
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
