// Sizes and fonts for the Alt+Tab switcher, taken from pwnbox's Theme.js.
// See Color.qml.
pragma Singleton

import QtQuick
import Quickshell
import "../Theme.js" as Theme

Singleton {
    readonly property int cornerRadius: Theme.radius
    readonly property int normalBorderWidth: 2
    readonly property var font: ({
        family: Theme.fontFamily,
        menuFamily: Theme.fontFamily,
        mono: Theme.fontMono,
        icons: Theme.fontIcons
    })
}
