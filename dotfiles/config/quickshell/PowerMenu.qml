import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
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

    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property bool wifiAvailable: Networking.wifiHardwareEnabled
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter !== null && btAdapter.enabled

    function anchoredLeft(center, fallbackRight) {
        if (!homeScreen)
            return 8;
        const max = Math.max(8, homeScreen.width - implicitWidth - 8);
        if (center < 0)
            return fallbackRight ? max : Math.max(8, Math.round((homeScreen.width - implicitWidth) / 2));
        return Math.max(8, Math.min(max, Math.round(center - implicitWidth / 2)));
    }

    IpcHandler {
        target: "powermenu"
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

    Process {
        id: runner
        command: ["true"]
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
    implicitWidth: 264
    implicitHeight: card.implicitHeight
    margins.top: barAtBottom ? 0 : sd.height + barGap
    margins.bottom: barAtBottom ? sd.height + barGap : 0
    margins.left: anchoredLeft(anchorCenter, true)

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
        implicitHeight: content.implicitHeight + 24

        component ToggleRow: Rectangle {
            id: tw
            required property string label
            required property string glyph
            required property bool active
            property bool available: true
            signal toggled()

            width: parent.width
            height: 34
            radius: Theme.radius - 2
            color: twMouse.containsMouse ? Theme.bgAltA : "transparent"
            opacity: available ? 1.0 : 0.5

            Text {
                id: twIcon
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                text: tw.glyph
                color: tw.active ? Theme.fg : Theme.fgDim
                font.family: Theme.fontIcons
                font.pixelSize: 13
            }
            Text {
                anchors { left: twIcon.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
                text: tw.label
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
            Text {
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                text: !tw.available ? "unavailable" : tw.active ? "on" : "off"
                color: tw.active ? Theme.fg : Theme.fgFaint
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.letterSpacing: 0.5
            }

            MouseArea {
                id: twMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: tw.available
                cursorShape: Qt.PointingHandCursor
                onClicked: tw.toggled()
            }
        }

        component ActionRow: Rectangle {
            id: ar
            required property string label
            required property string glyph
            property bool danger: false
            signal activated()

            width: parent.width
            height: 34
            radius: Theme.radius - 2
            color: arMouse.containsMouse ? Theme.bgAltA : "transparent"

            Text {
                id: arIcon
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                text: ar.glyph
                color: ar.danger ? Theme.red : Theme.fgDim
                font.family: Theme.fontIcons
                font.pixelSize: 13
            }
            Text {
                anchors { left: arIcon.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
                text: ar.label
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }

            MouseArea {
                id: arMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ar.activated()
            }
        }

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 2

            Text {
                leftPadding: 10
                topPadding: 2
                bottomPadding: 6
                text: "Session"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            ToggleRow {
                label: "Wi-Fi"
                glyph: Theme.iconWifi
                active: panel.wifiOn
                available: panel.wifiAvailable
                onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
            }
            ToggleRow {
                label: "Bluetooth"
                glyph: Theme.iconBluetooth
                active: panel.btOn
                available: panel.btAdapter !== null
                onToggled: if (panel.btAdapter)
                    panel.btAdapter.enabled = !panel.btAdapter.enabled
            }

            Item {
                width: parent.width
                height: 13

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 1
                    color: Theme.brdr
                }
            }

            ActionRow {
                label: "Lock"
                glyph: Theme.iconLock
                onActivated: {
                    runner.command = ["hyprlock"];
                    runner.startDetached();
                    panel.open = false;
                }
            }
            ActionRow {
                label: "Log out"
                glyph: Theme.iconLogout
                onActivated: {
                    runner.command = ["hyprctl", "dispatch", "exit"];
                    runner.startDetached();
                    panel.open = false;
                }
            }
            ActionRow {
                label: "Suspend"
                glyph: Theme.iconSuspend
                onActivated: {
                    runner.command = ["systemctl", "suspend"];
                    runner.startDetached();
                    panel.open = false;
                }
            }
            ActionRow {
                label: "Reboot"
                glyph: Theme.iconReboot
                onActivated: {
                    runner.command = ["systemctl", "reboot"];
                    runner.startDetached();
                    panel.open = false;
                }
            }
            ActionRow {
                label: "Shut down"
                glyph: Theme.iconShutdown
                danger: true
                onActivated: {
                    runner.command = ["systemctl", "poweroff"];
                    runner.startDetached();
                    panel.open = false;
                }
            }
        }
    }
}
