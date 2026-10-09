# pwnbox documentation

> AI reading this: load the project rules file in the repo root first. Rules there override anything here.

pwnbox is a portable, hardened NixOS + home-manager configuration for hacking,
reverse engineering, Active Directory and networking. It ships a Hyprland
desktop (with GNOME as a second session) driven by Quickshell, and a
wallpaper-driven theming system that reaches every app.

This folder is the full manual. Start with [Getting started](getting-started.md)
and jump to whatever you need.

| Document | What it covers |
| --- | --- |
| [Getting started](getting-started.md) | Install, first boot, updates, host config |
| [Desktop](desktop.md) | Hyprland, GNOME, Quickshell, sessions |
| [Keybinds](keybinds.md) | Every keyboard shortcut |
| [Themes](themes.md) | Wallpaper themes, custom themes, the `ALT + S` menu |
| [Fonts](fonts.md) | System/application fonts and sizes |
| [Apps](apps.md) | Per-app theming and live updates (Spotify, Discord, Telegram…) |
| [Packages](packages.md) | Tool categories and optional app sets |
| [Privacy](privacy.md) | Hardening and zero-trace defaults |
| [Architecture](architecture.md) | Repo layout and how a theme switch works |
| [Troubleshooting](troubleshooting.md) | Common problems and fixes |
| [Development](development.md) | Add themes, packages and bar styles |

## At a glance

- **One settings menu.** `ALT + S` changes theme, wallpaper, bar style,
  corner radii, fonts, font sizes, blur, transparency and animations.
- **Everything follows the wallpaper.** Colours are extracted with pywal and
  applied to the bar, terminal, launcher, notifications, editor, GTK apps and
  chat clients.
- **Live app theming.** Spotify, Discord (Equibop) and Telegram (AyuGram)
  update while they are running, without quitting them.
- **Reproducible.** Nothing is downloaded at runtime; every tool, theme and
  font comes from the flake.

## Conventions used here

- Paths starting with `~` are relative to the primary user's home.
- `ALT + S` opens the theme/settings menu unless stated otherwise.
- Commands are shown for the default setup; replace the host name if you
  installed under a different one.
