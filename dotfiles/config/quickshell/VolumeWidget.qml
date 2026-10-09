import QtQuick
import Quickshell.Services.Pipewire
import "Theme.js" as Theme

Row {
    id: root
    spacing: 5

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real vol: (sink && sink.audio) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.muted ? Theme.iconMute : Theme.iconVolume
        color: root.muted ? Theme.fg : Theme.fgDim
        font.family: Theme.fontIcons
        font.pixelSize: Theme.fontSize
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.muted ? "mute" : Math.round(root.vol * 100) + "%"
        color: root.muted ? Theme.fg : Theme.fgDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
