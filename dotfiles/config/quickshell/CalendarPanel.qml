import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "Theme.js" as Theme
import "BarStyles.js" as BarStyles

PanelWindow {
    id: panel
    property bool open: false
    property string barStyle: "islands"
    property real anchorCenter: -1

    readonly property var sd: BarStyles.geometry(barStyle, Theme.barHeight, Theme.bgA)
    readonly property bool barAtBottom: sd.bottom === true
    readonly property int barGap: 8

    readonly property var homeScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    function anchoredLeft(center, fallbackRight) {
        if (!homeScreen)
            return 8;
        const max = Math.max(8, homeScreen.width - implicitWidth - 8);
        if (center < 0)
            return fallbackRight ? max : Math.max(8, Math.round((homeScreen.width - implicitWidth) / 2));
        return Math.max(8, Math.min(max, Math.round(center - implicitWidth / 2)));
    }

    IpcHandler {
        target: "calendar"
        function toggle() {
            panel.open = !panel.open;
        }
        function toggleAt(x: int) {
            panel.anchorCenter = x;
            panel.open = !panel.open;
        }
        function close() {
            panel.open = false;
        }
    }

    visible: open
    screen: homeScreen
    color: "transparent"
    surfaceFormat.opaque: false
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors {
        top: !barAtBottom
        bottom: barAtBottom
        left: true
    }
    implicitWidth: 336
    implicitHeight: card.implicitHeight
    margins.top: barAtBottom ? 0 : sd.height + barGap
    margins.bottom: barAtBottom ? sd.height + barGap : 0
    margins.left: anchoredLeft(anchorCenter, sd.clock === "right")

    HyprlandFocusGrab {
        windows: [panel]
        active: panel.open
        onCleared: if (panel.open) panel.open = false
    }

    Shortcut {
        sequence: "Escape"
        enabled: panel.open
        onActivated: panel.open = false
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radius + 2
        color: Theme.bgA
        border.color: Theme.outline || Theme.brdr
        border.width: 2
        implicitHeight: content.implicitHeight + 28

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }
            spacing: 12

            Item {
                width: parent.width
                implicitHeight: 22

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    color: Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.brdr
            }

            Media {
                width: parent.width
            }

            Calendar {
                width: parent.width
                implicitWidth: parent.width
                today: new Date()
            }
        }
    }
}
