// The window that the "noir" bar's panels open in (Bluetooth, sound, network).
// It appears under the icon that was clicked, on that screen, and closes when
// you click anywhere else or press Escape. Which panel is shown is kept in
// NoirState.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "Theme.js" as Theme

PanelWindow {
    id: win

    readonly property bool open: NoirState.panel !== ""
    // The panel stays loaded while it fades out.
    property string shown: ""
    readonly property int barHeight: 36
    readonly property int gap: 6

    readonly property var titles: ({ bluetooth: "Bluetooth", audio: "Sound", network: "Network" })
    readonly property var sources: ({
        bluetooth: "NoirBluetoothPanel.qml",
        audio: "NoirAudioPanel.qml",
        network: "NoirNetworkPanel.qml"
    })

    Connections {
        target: NoirState
        function onPanelChanged() {
            if (NoirState.panel !== "")
                win.shown = NoirState.panel;
        }
    }

    screen: NoirState.screen
    visible: open || card.opacity > 0.01
    color: "transparent"
    surfaceFormat.opaque: false
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
    }
    implicitWidth: 320
    implicitHeight: card.implicitHeight + 8
    margins.top: barHeight + gap - 8
    margins.left: {
        const width = screen ? screen.width : 1920;
        const wanted = Math.round(NoirState.anchorX - implicitWidth / 2);
        return Math.max(6, Math.min(width - implicitWidth - 6, wanted));
    }

    HyprlandFocusGrab {
        windows: [win]
        active: win.open
        onCleared: NoirState.close()
    }

    Shortcut {
        sequence: "Escape"
        onActivated: NoirState.close()
    }

    Rectangle {
        id: card
        y: win.open ? 8 : 0
        width: parent.width
        implicitHeight: body.implicitHeight + 28
        color: Theme.bgA
        border.width: 2
        border.color: NoirState.outline
        radius: Theme.radius
        opacity: win.open ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on implicitHeight { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Column {
            id: body
            x: 14
            y: 14
            width: parent.width - 28
            spacing: 12

            Text {
                text: win.titles[win.shown] || ""
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
            }
            Rectangle {
                width: parent.width
                height: 1
                color: NoirState.line
            }
            Loader {
                width: parent.width
                active: win.shown !== "" && win.visible
                source: win.sources[win.shown] || ""
            }
        }
    }
}
