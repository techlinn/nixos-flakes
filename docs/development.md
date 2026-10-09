# Development

## Prerequisites

Enter the dev shell for the formatters and linters:

```bash
nix develop
```

It provides `nixfmt`, `statix` and `deadnix`.

## Formatting

```bash
nixfmt flake.nix modules/**/*.nix pkgs/**/*.nix
```

## Add a custom theme

1. Create `dotfiles/themes/<Name>/theme.conf` (copy `Tokyo-Night` as a base).
2. Drop a wallpaper next to it.
3. Rebuild (`upd`), then pick it from `ALT + S → Custom`.

Only `name`, `background` and `foreground` are required; everything else falls
back to the monochrome palette. See
[Themes](themes.md#custom-themes) and `dotfiles/themes/README.md`.

## Add a package

- One-off packages: `pkgs/custom.nix`.
- Permanent tooling: the matching file in `pkgs/categories/`.
- A whole new category: add a `pkgs/categories/<name>.nix` and reference it in
  `pkgs/categories.nix`; the `pwnbox.packages.toolset.<name>` option is created
  automatically.

## Add a bar style

1. Create `dotfiles/config/quickshell/BarStyle<NN>.qml` (copy an existing one).
2. Add its geometry to `dotfiles/config/quickshell/BarStyles.js`. **This is the
   single source of truth.** The bar and the calendar both read it.
3. Add an entry to `bar_styles` in `dotfiles/scripts/pwnbox-theme`:
   `"<id>|<Label>"`.
4. Add a preview `dotfiles/config/quickshell/previews/<id>.png`.
5. Rebuild, then choose it from `ALT + S → Style`.

Keep the `height`, `exclusive`, `top`/`bottom` and `clock` fields accurate so
the calendar and exclusive zone stay correct.

## Add a font

1. Add the package to `system/desktop/fonts.nix`.
2. Add its family name to `font_choices` in
   `dotfiles/scripts/pwnbox-theme`.
3. If it should be the default, also update the `named` defaults in
   `fontconfig.defaultFonts` and `home/gtk.nix`.

## Add live theming for an app

Live updates work best when the app watches a file we can rewrite. The pattern
used by Spotify, Equibop and Telegram is:

1. Keep a managed **base** config in the flake.
2. Generate the app's real config from the palette (and fonts) at runtime.
3. Detect the current theme change from `pwnbox-theme`'s `apply_borders`
   (which is called on every switch).
4. If the app supports file watching, rewrite the file in place; otherwise push
   the change however the app supports it.

Add the app to `docs/apps.md` when you do.

## Testing

- Syntax-check the shell helpers:
  `bash -n dotfiles/scripts/pwnbox-theme`
- Parse the Nix modules: `nix-instantiate --parse home/dotfiles.nix`
- Build without activating: `./install.sh build`
- Try it for one boot: `./install.sh test`

## Style guidelines

- Keep generated files out of the flake; only bases live there.
- Prefer `run` and `entryAfter` in activation scripts so changes are
  idempotent.
- When hiding UI (scrollbars, upsells), match by stable attribute/substring and
  keep the rule defensive so a client update cannot break layout.
