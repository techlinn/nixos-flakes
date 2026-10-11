# Browser

Zen is themed from the same palette as everything else. Three separate layers do
it, because no single one can reach the whole browser.

## The window (chrome)

`<zen profile>/chrome/userChrome.css`, written by `pwnbox-theme` from the
palette. This is the tab strip, the toolbar, the address bar, panels and menus.

Zen paints its window with a gradient written straight onto
`#zen-browser-background` and `#zen-toolbar-background`, so setting variables on
`:root` alone does nothing — those two elements are set explicitly.

Zen only reads `userChrome.css` when the pref
`toolkit.legacyUserProfileCustomizations.stylesheets` is on. It is set in the
package's policies and in the profile's `user.js`. The file is read at startup,
so **chrome colours appear the next time Zen starts**.

## `about:` pages

`<zen profile>/chrome/userContent.css`. The pages inside the browser (settings,
new tab, downloads) are styled with Firefox's own design tokens
(`--background-color-canvas`, `--text-color`, `--in-content-*`), which is why
they need their own block rather than the chrome variables.

## Websites

`dotfiles/config/zen/userstyles/` holds one stylesheet per site (130 of them).
They are not written per theme: every colour in them is a sentinel whose last
byte is a palette slot, and `pwnbox-theme` swaps all of them for the current
palette into `~/.cache/pwnbox/theme/userstyles/`.

Two things consume the result:

- the bundle is appended into `userContent.css`, which works with no extra
  moving parts but needs a Zen restart;
- the **pwnbox styles extension** (`dotfiles/config/zen/extension`, built into
  the package) reads it over `http://127.0.0.1:8311` and restyles open tabs
  within a few seconds of a theme change — no restart.

The server is the `pwnbox-styles` user service (`home/zen-styles.nix`). If site
colours stop following the theme, that service is the thing to check:

```bash
systemctl --user status pwnbox-styles
```

A site style can carry a colour that is not a sentinel — a hardcoded brand
colour the upstream style never parameterised. Those keep their original colour;
`github.css` and `seventv.css` have the most of them.

## Why colours still move after a theme change

| Layer | When it updates |
| --- | --- |
| Websites | a few seconds, live |
| `about:` pages | next Zen start |
| Chrome (tabs, toolbar) | next Zen start |

## Extensions

The package side-loads only the pwnbox styles extension, and it is unsigned
(built here), which is why `xpinstall.signatures.required` is off. No other
extension is installed for you.
