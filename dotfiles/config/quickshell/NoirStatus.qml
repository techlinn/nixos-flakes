// Bluetooth, volume and network at a glance, for the "noir" bar. Each one
// opens its own panel under it (NoirPanels.qml):
//
//   Bluetooth   the switch, scanning, and the devices to connect
//   Volume      output and microphone levels, devices, per-app volume
//               (scroll on the icon: 5 % steps, middle click: mute)
//   Network     the wired link, the Wi-Fi switch and networks
import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import "Theme.js" as Theme

Row {
    id: root
    spacing: 8

    property color accent: Theme.fg

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter !== null && adapter.enabled
    readonly property bool btLinked: {
        if (!btOn || !adapter.devices)
            return false;
        const list = adapter.devices.values;
        for (let i = 0; i < list.length; i++)
            if (list[i].connected)
                return true;
        return false;
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    // "wifi", "wired" or "" when nothing is connected.
    readonly property string link: {
        const list = Networking.devices ? Networking.devices.values : [];
        let wired = false;
        for (let i = 0; i < list.length; i++) {
            if (!list[i].connected)
                continue;
            if (list[i].type === DeviceType.Wifi)
                return "wifi";
            wired = true;
        }
        return wired ? "wired" : "";
    }

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    // The screen this bar is on, so the panel opens on the same one.
    property var screen: null

    function open(name, item) {
        NoirState.toggle(name, item.mapToItem(null, item.width / 2, 0).x, root.screen);
    }

    component Glyph: Item {
        id: glyph
        required property string icon
        property bool dim: false
        property int size: 13
        property string tip: ""
        property bool active: false
        signal clicked()
        signal middleClicked()
        signal scrolled(int direction)

        implicitWidth: 14
        implicitHeight: 26

        Text {
            anchors.centerIn: parent
            text: glyph.icon
            font.family: Theme.fontIcons
            font.pixelSize: glyph.size
            color: glyph.active ? root.accent : (area.containsMouse ? Theme.fg : (glyph.dim ? Theme.fgFaint : Theme.fgDim))
            scale: area.pressed ? 0.9 : 1
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 80 } }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            anchors.leftMargin: -4
            anchors.rightMargin: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: mouse => mouse.button === Qt.MiddleButton ? glyph.middleClicked() : glyph.clicked()
            onWheel: wheel => glyph.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
        }

        NoirTip {
            target: glyph
            text: glyph.tip
            show: area.containsMouse && !glyph.active
        }
    }

    Glyph {
        id: bt
        icon: root.btLinked ? "\udb80\udcb1" : (root.btOn ? "\udb80\udcaf" : "\udb80\udcb2")
        dim: !root.btOn
        active: NoirState.panel === "bluetooth"
        tip: !root.adapter ? "Bluetooth: no adapter" : (root.btLinked ? "Bluetooth: connected" : (root.btOn ? "Bluetooth: on" : "Bluetooth: off"))
        onClicked: root.open("bluetooth", bt)
    }

    Glyph {
        id: vol
        icon: root.muted ? "\uf026" : (root.volume < 0.34 ? "\uf027" : "\uf028")
        dim: root.muted
        active: NoirState.panel === "audio"
        tip: root.muted ? "Sound: muted" : "Sound: " + Math.round(root.volume * 100) + "%"
        onClicked: root.open("audio", vol)
        onMiddleClicked: {
            if (root.sink && root.sink.audio)
                root.sink.audio.muted = !root.sink.audio.muted;
        }
        onScrolled: direction => {
            if (root.sink && root.sink.audio)
                root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + direction * 0.05));
        }
    }

    Glyph {
        id: net
        icon: root.link === "wired" ? "\udb80\udf17" : "\uf1eb"
        dim: root.link === ""
        active: NoirState.panel === "network"
        tip: root.link === "wired" ? "Network: wired" : (root.link === "wifi" ? "Network: Wi-Fi" : "Network: offline")
        onClicked: root.open("network", net)
    }
}
