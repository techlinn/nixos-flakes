// Shared state of the "noir" bar: which of its panels is open and where, and
// the colours they all use. One panel at a time.
pragma Singleton

import QtQuick
import Quickshell
import "Theme.js" as Theme

Singleton {
    id: root

    // "", "bluetooth", "audio" or "network"
    property string panel: ""
    // Horizontal centre of the icon that opened it, in screen pixels.
    property real anchorX: 0
    property var screen: null

    // The highlight: the focused-window border colour, so bar, panels and
    // windows match in every theme.
    readonly property color accent: (typeof Theme.focus === "string" && Theme.focus.length > 0)
        ? Theme.focus : Theme.red
    readonly property color outline: (typeof Theme.outline === "string" && Theme.outline.length > 0)
        ? Theme.outline : Theme.brdr
    // Text on something filled with the accent.
    readonly property color onAccent: Theme.bg
    readonly property color line: Qt.alpha(Theme.fg, 0.10)
    readonly property color hover: Qt.alpha(Theme.fg, 0.07)

    // Clicking the icon of the open panel closes it. That click first lands
    // outside the panel, which closes it too; without this, the same click
    // would then open it again.
    property string justClosed: ""
    Timer {
        id: forget
        interval: 250
        onTriggered: root.justClosed = ""
    }

    function toggle(name, x, onScreen) {
        if (panel === name || justClosed === name) {
            close();
            justClosed = "";
            return;
        }
        anchorX = x;
        screen = onScreen;
        panel = name;
    }

    function close() {
        if (panel !== "") {
            justClosed = panel;
            forget.restart();
        }
        panel = "";
    }
}
