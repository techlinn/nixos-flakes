// Theme colours for the Alt+Tab switcher, filled from pwnbox's Theme.js (which
// pwnbox-theme rewrites on every theme change), so it follows whatever theme or
// wallpaper is active.
pragma Singleton

import QtQuick
import "../Theme.js" as Theme

QtObject {
    readonly property color foreground: Theme.fg
    readonly property color background: Theme.bg
    // The highlight colour is the same one Hyprland uses for the focused
    // window's border (written to Theme.js as `focus` by pwnbox-theme). Theme.js
    // `accent` is a dark surface colour, far too dim for a selection ring.
    readonly property color accent: (typeof Theme.focus === "string" && Theme.focus.length > 0)
        ? Theme.focus : Theme.accentSoft

    // Panel colours (same look as the bar's).
    readonly property color surface: Theme.bgA
    readonly property color surfaceAlt: Theme.bgAltA
    // The panel's outline: the theme's border colour if it names one (written
    // to Theme.js as `outline`), otherwise the quiet border shade.
    readonly property color border: (typeof Theme.outline === "string" && Theme.outline.length > 0)
        ? Theme.outline
        : ((typeof Theme.brdr === "string" && Theme.brdr.length > 0) ? Theme.brdr : Theme.accent)
}
