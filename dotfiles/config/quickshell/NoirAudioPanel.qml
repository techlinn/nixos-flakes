// Sound: output and microphone volume, which device each uses, and one
// slider per app that is playing something.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "Theme.js" as Theme

Column {
    id: root
    width: parent ? parent.width : 300
    spacing: 12

    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var sinks: nodes.filter(n => n.audio && !n.isStream && n.isSink)
    readonly property var sources: nodes.filter(n => n.audio && !n.isStream && !n.isSink)
    readonly property var streams: nodes.filter(n => n.audio && n.isStream && !n.isSink)

    PwObjectTracker {
        objects: root.sinks.concat(root.sources, root.streams)
    }

    function label(node) {
        if (!node)
            return "None";
        return node.description || node.nickname || node.name || "Unknown";
    }
    function appName(node) {
        const p = node.properties || {};
        return p["application.name"] || node.description || node.name || "App";
    }

    component Title: Text {
        color: Theme.fgFaint
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 1
        font.capitalization: Font.AllUppercase
    }

    // glyph (click: mute)  slider  percent
    component Level: Item {
        id: level
        required property var node
        required property string glyph
        required property string mutedGlyph
        readonly property bool ok: node !== null && node !== undefined && node.audio !== null
        readonly property bool muted: ok && node.audio.muted
        readonly property real volume: ok ? node.audio.volume : 0

        width: parent.width
        height: 22

        Text {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            text: level.muted ? level.mutedGlyph : level.glyph
            font.family: Theme.fontIcons
            font.pixelSize: 14
            color: muteArea.containsMouse ? Theme.fg : (level.muted ? Theme.fgFaint : NoirState.accent)
            Behavior on color { ColorAnimation { duration: 120 } }
            MouseArea {
                id: muteArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (level.ok) level.node.audio.muted = !level.node.audio.muted
            }
        }
        NoirSlider {
            anchors.left: icon.right
            anchors.leftMargin: 8
            anchors.right: percent.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            value: level.volume
            dimmed: level.muted
            onMoved: v => { if (level.ok) level.node.audio.volume = v; }
        }
        Text {
            id: percent
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: level.muted ? "mute" : Math.round(level.volume * 100) + "%"
            color: Theme.fgDim
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    // One selectable device.
    component Device: Rectangle {
        id: device
        required property var node
        required property bool current
        signal chosen()

        width: parent.width
        height: 26
        radius: Math.min(Theme.radius, 6)
        color: pick.containsMouse ? NoirState.hover : "transparent"

        Rectangle {
            x: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: device.current ? NoirState.accent : "transparent"
            border.width: 1
            border.color: device.current ? NoirState.accent : Theme.fgFaint
        }
        Text {
            x: 22
            width: parent.width - 28
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: root.label(device.node)
            color: device.current ? Theme.fg : Theme.fgDim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
        MouseArea {
            id: pick
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: device.chosen()
        }
    }

    Title { text: "Output" }
    Level {
        node: Pipewire.defaultAudioSink
        glyph: ""
        mutedGlyph: ""
    }
    Column {
        width: parent.width
        spacing: 1
        Repeater {
            model: root.sinks
            delegate: Device {
                required property var modelData
                node: modelData
                current: Pipewire.defaultAudioSink !== null && modelData.id === Pipewire.defaultAudioSink.id
                onChosen: Pipewire.preferredDefaultAudioSink = modelData
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: NoirState.line }

    Title { text: "Microphone" }
    Level {
        node: Pipewire.defaultAudioSource
        glyph: ""
        mutedGlyph: ""
    }
    Column {
        width: parent.width
        spacing: 1
        Repeater {
            model: root.sources
            delegate: Device {
                required property var modelData
                node: modelData
                current: Pipewire.defaultAudioSource !== null && modelData.id === Pipewire.defaultAudioSource.id
                onChosen: Pipewire.preferredDefaultAudioSource = modelData
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: NoirState.line; visible: root.streams.length > 0 }

    Title { text: "Apps"; visible: root.streams.length > 0 }
    Column {
        width: parent.width
        spacing: 8
        visible: root.streams.length > 0
        Repeater {
            model: root.streams
            delegate: Column {
                id: app
                required property var modelData
                width: parent.width
                spacing: 2
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: root.appName(app.modelData)
                    color: Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
                Level {
                    node: app.modelData
                    glyph: ""
                    mutedGlyph: ""
                }
            }
        }
    }
}
