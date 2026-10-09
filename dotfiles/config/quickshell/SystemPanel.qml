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
    property var stats: ({})

    function parse(text) {
        const out = {};
        const parts = text.trim().split(/\s+/);
        for (let i = 0; i < parts.length; i++) {
            const eq = parts[i].indexOf("=");
            if (eq > 0)
                out[parts[i].slice(0, eq)] = parts[i].slice(eq + 1);
        }
        return out;
    }

    function anchoredLeft(center, fallbackRight) {
        if (!homeScreen)
            return 8;
        const max = Math.max(8, homeScreen.width - implicitWidth - 8);
        if (center < 0)
            return fallbackRight ? max : Math.max(8, Math.round((homeScreen.width - implicitWidth) / 2));
        return Math.max(8, Math.min(max, Math.round(center - implicitWidth / 2)));
    }

    IpcHandler {
        target: "systempanel"
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
        id: proc
        command: ["sh", "-c", "$HOME/.scripts/status"]
        stdout: StdioCollector {
            onStreamFinished: panel.stats = panel.parse(this.text)
        }
    }

    Timer {
        interval: 2000
        running: panel.open
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
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
    implicitWidth: 330
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
        implicitHeight: content.implicitHeight + 28

        component Bar: Rectangle {
            id: bar
            required property real value
            height: 5
            radius: 3
            color: Theme.brdr

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, bar.value))
                height: parent.height
                radius: parent.radius
                color: Theme.focus || Theme.fg
            }
        }

        component Stat: Column {
            id: stat
            required property string label
            required property string value
            required property string glyph
            required property real fraction

            width: parent.width
            spacing: 3

            Item {
                width: parent.width
                height: 14

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text: stat.glyph
                    color: Theme.fgFaint
                    font.family: Theme.fontIcons
                    font.pixelSize: 11
                }
                Text {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    text: stat.label
                    color: Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    text: stat.value
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            Bar {
                width: parent.width
                value: stat.fraction
            }
        }

        component Info: Item {
            id: info
            required property string label
            required property string value
            required property string glyph

            width: parent.width
            height: 14

            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                text: info.glyph
                color: Theme.fgFaint
                font.family: Theme.fontIcons
                font.pixelSize: 11
            }
            Text {
                anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                text: info.label
                color: Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
            Text {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: info.value
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }
            spacing: 11

            Text {
                text: "System"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.brdr
            }

            Stat {
                label: "CPU"
                glyph: Theme.iconCpu
                value: (panel.stats.cpu || "0") + "%"
                fraction: (panel.stats.cpu || 0) / 100
            }
            Stat {
                label: "Memory"
                glyph: Theme.iconMemory
                value: (panel.stats.mem_used || "0") + " / " + (panel.stats.mem_total || "0")
                fraction: (panel.stats.mem || 0) / 100
            }
            Stat {
                label: "Swap"
                glyph: Theme.iconSwap
                value: (panel.stats.swap_used || "0") + " / " + (panel.stats.swap_total || "0")
                fraction: (panel.stats.swap || 0) / 100
                visible: (panel.stats.swap_total || "0B") !== "0B"
            }
            Stat {
                label: "Disk"
                glyph: Theme.iconDisk
                value: (panel.stats.disk_used || "0") + " / " + (panel.stats.disk_total || "0")
                fraction: (panel.stats.disk || 0) / 100
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.brdr
            }

            Info {
                label: "Download"
                glyph: Theme.iconDownload
                value: panel.stats.down || "0B/s"
            }
            Info {
                label: "Upload"
                glyph: Theme.iconUpload
                value: panel.stats.up || "0B/s"
            }
            Info {
                label: "Load"
                glyph: Theme.iconCpu
                value: panel.stats.load || "0.00"
            }
            Info {
                label: "Uptime"
                glyph: Theme.iconClock
                value: panel.stats.uptime || "N/A"
            }

            Media {
                width: parent.width
            }
        }
    }
}
