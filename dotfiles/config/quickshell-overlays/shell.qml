// The Alt+Tab switcher.
//
// This is a second Quickshell instance, separate from the bar in
// ~/.config/quickshell, started at login from hyprland.conf. Keeping it
// separate means a crash here cannot take the bar or notifications with it.
// Colours and fonts come from the bar's Theme.js (see Commons/).
import QtQuick
import Quickshell
import "switcher"

ShellRoot {
    // Alt+Tab: hold ALT, tap TAB, release ALT. Bound in hyprland.conf to the
    // global shortcuts pwnbox:switcher-next / -previous / -release.
    Switcher {}
}
