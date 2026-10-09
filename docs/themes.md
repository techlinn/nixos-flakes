# Themes & customization

Everything visual is driven from one palette. You can either let pywal extract
that palette from a wallpaper, or pin it with a custom theme.

## The `ALT + S` menu

| Entry | What it changes |
| --- | --- |
| **Pywal** | Pick a wallpaper; extract a palette from it |
| **Custom** | Pick one of the fixed-palette themes |
| **Style** | Bar layout (11 styles) |
| **Corner radius** | Window rounding, in px |
| **UI corner radius** | Bar / panel / rofi rounding, in px |
| **System font** | UI font |
| **System font size** | UI font size |
| **Application font** | Monospace/app font |
| **Application font size** | App font size |
| **Blur** | Window blur on/off |
| **Transparency** | How see-through unfocused windows and the terminal are (%) |
| **Animations** | Hyprland animations on/off |

Every choice is written to `~/.cache/pwnbox/theme/` and re-applied on login.

**Transparency.** The window you are working in is always solid. The windows
around it are see-through (with blur behind them, if blur is on), and the
terminal (kitty) is see-through all the time, focused or not. Both are set by
the one percentage. The rules are written by `pwnbox-theme` into
`~/.cache/pwnbox/theme/hyprland.conf`: `active_opacity = 1.0`, `inactive_opacity`
from the percentage, and a `windowrule = opacity ... override` line for kitty.
To make another app behave like the terminal, add its window class to that
rule's `match:class` in `apply_borders` (find the class with `hyprctl clients`).

## Wallpaper themes (Pywal)

`ALT + S → Pywal` scans `~/.local/share/pwnbox/wallpapers` (the flake's
`dotfiles/gnome/wallpapers`, linked read-only). Pick an image and pywal derives
a 16-colour palette from it. That palette is then written everywhere:

- Quickshell (`~/.config/quickshell/Theme.js`)
- kitty, rofi, fuzzel
- GTK 3 / 4 and GNOME settings
- Hyprland borders, Hyprlock
- Neovim, Zed
- Telegram, Equibop (Discord), Spotify
- OBS Studio and Zen (applied the next time they start)

Automatic palettes are checked for readability before they are used. Pictures
that are dark or nearly grey can make pywal produce a "red", "green" and
"yellow" that are dark greys on a dark background, which vanish on the bar. Any
colour below a minimum contrast against the background is made lighter, keeping
its hue (text 9:1, the soft white 7.5:1, colours 1-6 4.8:1, their bright
versions 5.5:1). Palettes that are already readable are not touched.

Add wallpapers by dropping images into `dotfiles/gnome/wallpapers/` and
rebuilding. A picture that has a folder in `dotfiles/themes/` with the same
wallpaper uses that theme's hand-made palette instead of an automatic one.

## Custom themes

A custom theme is a folder under `dotfiles/themes/<Name>/` with a `theme.conf`
and (optionally) a wallpaper:

```
dotfiles/themes/
├── Monochrome/          the default grey theme
├── Amoled/
├── Catppuccin-Mocha/
├── Tokyo-Night/
└── 18 hand-made wallpaper themes, one folder per wallpaper, each with
    theme.conf  +  wallpaper.jpg (or .png)
```

### The wallpaper themes

Twenty-six themes were written by hand from your own wallpapers. Each palette was
designed from that picture's colours (its dominant hues, its small accents such
as a lantern or a scarf, and how light or dark it is), then tuned so everything
stays easy to read: text has at least 9:1 contrast against the background,
accent colours at least 5:1, and comments (the dimmest colour) 3:1. The
picture's signature colour is `color4`, which is the accent in GTK apps,
buttons and the editor's keywords.

| Theme | Wallpaper | Look |
| --- | --- | --- |
| Autumn Camp | `wallhaven-8o6rmo.jpg` | Plum-brown panels, maple orange accent, cream text |
| Seaside | `wallhaven-l36zrl.jpg` | Deep navy panels, cobalt accent, aqua highlights |
| Ash | `wallhaven-ml3ek1.jpg` | Graphite panels, a single crimson accent, fog-grey text |
| Post Town | `wallhaven-o5zedl.jpg` | Warm near-black, lantern-amber accent, paper-cream text |
| Overcast | `wallhaven-w5ejkr.jpg` | Slate panels, steel-blue accent, quiet and cool |
| Back Alley | `wallhaven-x6vkoz.jpg` | Warm black, teal accent against amber and red |
| Dusk Indigo | `TN3.png` | Indigo-ink panels, dusty-rose accent from the sky glow |
| Violet Hour | `TN4.png` | Violet-ink panels, sunset-amber accent |
| City Lights | `TN8.png` | Deepest navy, periwinkle accent, coral and aqua like the bokeh |
| Snowfall | `Nord6.png` | Slate-lavender panels, warm window-glow accent, frost blue |
| Lantern Forest | `kanagawa2.png` | Blue-slate panels, teal accent, lantern gold and sakura pink |
| Cream Outline | `girl-outline-colorized.png` | Cool charcoal, cream accent, Gruvbox colours |
| Terracotta | `Kurumi-Ebisuzawa-colorized.png` | Neutral charcoal, terracotta-rose accent, Gruvbox colours |
| Vending Snow | `wallhaven-2e2xyx-colorized.png` | Warm brown-black, vending-machine orange, Gruvbox colours |
| Neon Haze | `wallhaven-6lo8w6-colorized.png` | Cool charcoal, neon-pink accent, coral and violet |
| Silhouette | `wallhaven-4loq2l.jpg` | Graphite, a cool steel-blue tint |
| Statue | `wallhaven-kw7j1d.jpg` | Warm graphite, a bronze tint |
| Mist | `wallhaven-968w68.jpg` | Olive-black, a fog-sage tint |
| Night Dune | `night-dune.jpg` | Black with a faint violet-blue cast, silver-white accent |
| Fog Lamps | `fog-lamps.jpg` | Neutral black and grey, lamp-white accent |
| Dot Matrix | `dot-matrix.jpg` | Pure black, white accent, the sharpest contrast |
| Dune River | `dune-river.jpg` | Neutral near-black, silver accent |
| Smoke Grain | `smoke-grain.jpg` | Black with a cool blue-grey cast from the picture |
| Dark Room | `wallhaven-j3gvxy.jpg` | Warm-tinged black, soft cream-white accent |
| Voxel Dusk | `wallhaven-zye5wv.png` | Warm black, muted clay-peach accent, olive green |
| Acanthus | `acanthus.png` | Pure black, dusty-rose accent and window border, olive and teal; comes with its own look (below) |

Notes on how some were made:

- **Gruvbox pictures.** Four wallpapers (`girl-outline`, `Kurumi`, `2e2xyx`,
  `6lo8w6`) were recoloured to the Gruvbox scheme; three of them match it almost
  exactly. Their themes use Gruvbox's own hues, tuned for readability, and are
  told apart by the background shade and the accent colour.
- **Black-and-white pictures.** `4loq2l` and `kw7j1d` have no colour at all, and
  `968w68` only a faint olive cast. Their themes keep the greys of the picture
  and add one restrained tint (steel, bronze, sage), which is a design choice,
  not something taken from the photo.

- **The dark monochrome set.** Six of the newest (`Night Dune`, `Fog Lamps`,
  `Dot Matrix`, `Dune River`, `Smoke Grain`, `Dark Room`) are almost greyscale
  pictures, so their themes are black with grey and white text and no real
  colour. They differ in how deep the black is, how bright the whites are and
  a faint cast (cool, neutral or warm) taken from the picture. The six accent
  slots (red, green, yellow, purple, cyan and the main accent) are told apart
  by brightness, with a barely visible tint, so they all still read clearly.
  `Voxel Dusk` is the one with colour: its clay-peach and olive come from the
  picture's sky blocks and trees, muted to match.
- **Small pictures.** `dune-river.jpg` is only 736x414 and the others 1200x675,
  so they are scaled up on a 1080p screen and look softer than the full-size
  wallpapers; these pictures are smooth enough that it hardly shows.

- **Acanthus and its look.** Acanthus was modelled on a reference desktop:
  black, a dusty rose (`#a97575`) for the window border and the bar's
  highlights, and olive, teal and mauve for code. A theme can carry a *look*
  besides its colours, as extra lines in `theme.conf`:

  | Key | Meaning |
  | --- | --- |
  | `border` | Colour of the focused window's border and of panel outlines |
  | `bar_style` | One of the `ALT + S → Style` names, for example `noir` |
  | `window_radius` | Window corner radius in px |
  | `ui_radius` | Bar, panel and menu corner radius in px |
  | `transparency` | Window opacity in % |
  | `app_font` | Application (monospace) font, one of the `ALT + S → Application font` names |

  Next to `theme.conf` a theme can also have `zed.json` (editor colours for
  Zed), `nvim.lua` (Neovim colours), `discord.css` (Discord colours added after
  the generated ones) and `telegram.tdesktop-theme` (Telegram colours that
  replace generated ones).

  Neovim is grey by default, built from shades of the theme's text colour.
  A theme's `nvim.lua` gives it real colours for code, the file tree, the tabs,
  the status line, popups and the file finder; Neovim reloads them within a
  couple of seconds when the theme changes, and goes back to grey on a theme
  without one. Acanthus uses it for the reference's scheme: mauve italic
  keywords, rose bold functions, olive types, teal members, rose-beige tree,
  olive mode chip.

  When a rebuild brings a changed version of the theme you are using (any of
  these files), it is applied again by itself; you do not have to pick the
  theme a second time.

  A theme folder can also hold a `zed.json` with its own editor colours for
  Zed (which colour keywords, functions, types and so on get). It is laid over
  the Zed theme that is generated from the palette, so anything it leaves out
  still follows the palette. Acanthus uses this to give Zed the reference's
  editor scheme: mauve italic keywords, rose functions, olive types and
  constants, dark-teal members, grey variables, rose operators.

  Acanthus sets the Noir bar and square corners; transparency and fonts are
  left as you have them.

  Acanthus is built on **pure black**, with the red kept for what is small:
  window and panel borders, focus rings, links, badges and the marker of the
  open page or server. Big areas are never filled with it. In Discord, Zen,
  OBS, GTK apps, Telegram, Neovim and Zed the surfaces, hovers and selections
  are black or neutral grey, and buttons are outlined in red instead of filled.
  A theme can do this per app with extra files next to `theme.conf`: `zen.css`,
  `obs.txt` (OBS variables), `gtk.css`, `discord.css`, `nvim.lua`, `zed.json`
  and `telegram.tdesktop-theme`. Its `discord.css` uses a darker red than the desktop's rose and
  re-tints Discord's own green, blue and teal to it, so buttons that are
  normally another colour blend in. Choosing it
  applies those; choosing any other theme afterwards puts back the bar style,
  corners and transparency you had before, so a theme never changes your
  settings for good. You can still change any of them with `ALT + S` while it
  is active. The wallpaper was cut out of the reference screenshot (the part
  under its bar, enlarged by 3 %), because the original picture was not
  available.

The same images are in the wallpaper library. Picking one of them in
`ALT + S → Pywal` applies its hand-made theme as well, so both menus give the
same result. (To get an automatic palette for one of them anyway, run
`PWNBOX_PYWAL_ONLY=1 pwnbox-theme apply <image>`.) The first time a menu is
opened it makes a small thumbnail of each wallpaper, which takes a couple of
seconds for this many large images; after that it is instant.

`theme.conf` is INI-style:

```ini
name = My theme
wallpaper = wallpaper.png

background = #101014
foreground = #e6e6e6
cursor = #e6e6e6

color0 = #17171c
color1 = #f7768e
```

Any missing colour falls back to the monochrome palette, so a minimal theme is
just `name`, `background` and `foreground`. See
`dotfiles/themes/README.md` for the full reference.

After adding a theme folder, rebuild (`upd`) so it is linked, then choose it
from `ALT + S → Custom`. The command-line equivalent is
`pwnbox-theme custom`.

## What is generated

The theme scripts read the active palette and write a small set of files that
apps include or read:

| Generated file | Used by |
| --- | --- |
| `~/.config/quickshell/Theme.js` | Quickshell bar/panels |
| `~/.cache/pwnbox/theme/kitty.conf` | kitty (included by the base config) |
| `~/.cache/pwnbox/theme/rofi.rasi` | rofi (imported by the themes) |
| `~/.cache/pwnbox/theme/fuzzel.ini` | fuzzel |
| `~/.cache/pwnbox/theme/gtk-colors.css` | GTK 3/4 |
| `~/.cache/pwnbox/theme/nvim-palette.lua` | Neovim |
| `~/.cache/pwnbox/theme/hyprland.conf` | Hyprland borders |
| `~/.cache/pwnbox/theme/colors.json` | helpers/scripts |
| `~/.config/zed/themes/pwnbox.json` | Zed |
| `~/.config/telegram/pwnbox.tdesktop-theme` | Telegram / AyuGram |
| `~/.config/spicetify/Themes/pwnbox/color.ini` | Spotify |
| `~/.config/equibop/settings/quickCss.css` | Discord (Equibop) |
| `~/.config/obs-studio/themes/Pwnbox.ovt` | OBS Studio |
| `<zen profile>/chrome/userChrome.css`, `userContent.css` | Zen |

## Where state lives

| File | Meaning |
| --- | --- |
| `~/.cache/pwnbox/theme/wallpaper` | Current wallpaper path |
| `~/.cache/pwnbox/theme/custom-theme` | Current custom theme name |
| `~/.cache/pwnbox/theme/barstyle` | Current bar style |
| `~/.cache/pwnbox/theme/radius-window` | Window radius |
| `~/.cache/pwnbox/theme/radius-ui` | UI radius |
| `~/.cache/pwnbox/theme/blur` | `on` / `off` |
| `~/.cache/pwnbox/theme/opacity` | Transparency % |
| `~/.cache/pwnbox/theme/animations` | `on` / `off` |
| `~/.cache/pwnbox/theme/font-ui` | System font |
| `~/.cache/pwnbox/theme/font-app` | Application font |
| `~/.cache/pwnbox/theme/font-size-ui` | System font size |
| `~/.cache/pwnbox/theme/font-size-app` | Application font size |

## Command line

`~/.scripts/pwnbox-theme` can be called directly:

```bash
pwnbox-theme menu
pwnbox-theme pick
pwnbox-theme custom
pwnbox-theme monochrome
pwnbox-theme apply <image>
pwnbox-theme barstyle
pwnbox-theme borders
pwnbox-theme restore
pwnbox-theme uifont
pwnbox-theme appfont
pwnbox-theme uifontsize
pwnbox-theme appfontsize
pwnbox-theme blur
pwnbox-theme transparency
pwnbox-theme animations
```
