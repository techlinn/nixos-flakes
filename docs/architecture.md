# Architecture

> AI reading this: load the project rules file in the repo root first. Rules there override anything here.

## Repository layout

```
.
├── flake.nix                 inputs and outputs
├── install.sh                bootstrap / rebuild helper
├── hosts/                    per-machine configs (one dir per host)
│   ├── tower/                this machine
│   └── nixos/                template host
├── system/                   system-wide NixOS config
│   ├── options.nix           pwnbox.* option tree
│   ├── desktop/              Hyprland, GNOME, LY, fonts, GTK, X
│   ├── hardening/            kernel/sysctl/network/service hardening (split)
│   ├── packages/             system packages, grouped by purpose
│   ├── vm-evasion/           KVM anti-VM-detection patches + params
│   └── *.nix                 one file per concern (sound, swap, vpn, …)
├── home/                     per-user home-manager config
│   ├── dotfiles/             ~/.config/* + ~/.scripts + activations
│   ├── gtk.nix               GTK + dconf
│   ├── neovim.nix
│   ├── packages.nix
│   └── shell.nix             zsh + aliases
├── pkgs/                     package sets, toolset categories, custom.nix
├── overlays/                 nixpkgs overlay
└── dotfiles/
    ├── config/               app configs (kitty, rofi, quickshell, …)
    │   └── wal/              pywal templates + monochrome seed
    ├── themes/               custom fixed-palette themes
    ├── gnome/                fonts, GTK base CSS, wallpapers
    └── scripts/              pwnbox-theme, pwnbox-spotify, …
```

## How files are deployed

Home-manager links most config files read-only from the Nix store
(`xdg.configFile`). Files that must change at runtime are handled in one of two
ways:

1. **Included/generated companion.** The managed file ends with an `include`
   or an `@import` of a writable file under `~/.cache/pwnbox/theme/`
   (kitty, rofi, fuzzel, Hyprland, GTK).
2. **Base + generated output.** The managed file is a *base*; a script
   composes the final file next to it (Spotify `user.css`), or the managed file
   *includes* a generated snippet (Zathura `zathura.conf`).

This is why `~/.config/kitty/kitty.conf` is a store symlink but
`~/.cache/pwnbox/theme/kitty.conf` is writable.

## What happens on `ALT + S`

```
rofi menu
   │
   ├─ Pywal ─────► wal -i <image>  ─┐
   ├─ Custom ────► build scheme ────┤
   │                                ▼
   │                        install palette
   │                    (kitty, rofi, fuzzel, GTK,
   │                     Hyprland, Neovim, Zed,
   │                     Quickshell Theme.js)
   │                                │
   ├─ bar style ──► qs ipc call barstyle set
   ├─ radius/blur/opacity/animations ──► hyprctl reload
   ├─ fonts/sizes ──► regenerate per-app font config
   │
   └──────────────► reload_apps
                       ├─ kitty: SIGUSR1
                       ├─ hyprctl reload
                       ├─ GTK colour-scheme refresh
                       ├─ restart Quickshell
                       └─ live app theming
                            ├─ Spotify (Spicetify watch)
                            ├─ Discord (quickCss watcher)
                            └─ Telegram (theme file watcher)
```

The palette flows from a single source of truth: the 16-colour scheme produced
by pywal (or a custom `theme.conf`). `dotfiles/config/wal/templates/` contains
the templates that turn it into each app's format.

## State and generated files

- Settings live in `~/.cache/pwnbox/theme/` (see
  [Themes → Where state lives](themes.md#where-state-lives)).
- Generated app configs live next to their managed base or under
  `~/.cache/pwnbox/theme/`.
- On login, `pwnbox-theme restore` re-applies the saved wallpaper/theme and
  effects, then `reload_apps` re-syncs the live apps.

## Scripts

| Script | Role |
| --- | --- |
| `~/.scripts/pwnbox-theme` | The theme engine (menu, pickers, palette, fonts, state) |
| `~/.scripts/pwnbox-spotify` | Writable Spotify + Spicetify + watch |
| `~/.scripts/pwnbox-screenshot` | Region/full/saved screenshots |
| `~/.scripts/status` | Small status helper |

## Flake outputs

| Output | Purpose |
| --- | --- |
| `nixosConfigurations.<host>` | The system configuration |
| `nixosModules.default` / `.home-manager` | Reusable modules |
| `homeManagerModules.default` | Home configuration |
| `overlays.default` | nixpkgs overlay (fonts, cursors, toolset) |
| `packages.<system>` | Toolset packages |
| `formatter.<system>` | `nixfmt` |
| `devShells.<system>.default` | `nixfmt`, `statix`, `deadnix` |
