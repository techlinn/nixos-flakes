import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "Theme.js" as Theme

Rectangle {
    id: media

    readonly property var player: {
        const list = Mpris.players;
        if (!list)
            return null;
        for (let i = 0; i < 16; i++) {
            const p = list[i];
            if (!p)
                break;
            if (p.isPlaying)
                return p;
        }
        return list[0] || null;
    }
    readonly property bool active: player !== null && player !== undefined
        && (player.trackTitle || "").length > 0
    readonly property bool playing: active && player.isPlaying
    readonly property real progress: (active && player.length > 0)
        ? Math.max(0, Math.min(1, player.position / player.length))
        : 0

    visible: active
    implicitHeight: visible ? 62 : 0
    height: implicitHeight
    radius: Theme.radius
    color: Theme.bgAltA
    border.color: Theme.brdr
    border.width: 1

    Image {
        id: art
        anchors {
            left: parent.left
            leftMargin: 7
            verticalCenter: parent.verticalCenter
        }
        width: 48
        height: 48
        source: (media.player && media.player.trackArtUrl) ? media.player.trackArtUrl : ""
        sourceSize.width: 128
        sourceSize.height: 128
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
        layer.enabled: true
    }

    Rectangle {
        anchors.fill: art
        visible: !art.visible
        radius: Theme.radius - 3
        color: Theme.bgA

        Text {
            anchors.centerIn: parent
            text: Theme.iconMusic
            color: Theme.fgFaint
            font.family: Theme.fontIcons
            font.pixelSize: 18
        }
    }

    Column {
        anchors {
            left: art.right
            leftMargin: 10
            right: controls.left
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 5

        Text {
            width: parent.width
            text: media.active ? media.player.trackTitle : ""
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: {
                if (!media.active)
                    return "";
                if (media.player.trackArtist && media.player.trackArtist.length > 0)
                    return media.player.trackArtist;
                return media.player.identity || "";
            }
            color: Theme.fgDim
            font.family: Theme.fontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        Rectangle {
            width: parent.width
            height: 3
            radius: 2
            color: Theme.brdr

            Rectangle {
                width: parent.width * media.progress
                height: parent.height
                radius: parent.radius
                color: Theme.fg
            }
        }
    }

    Row {
        id: controls
        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        spacing: 2

        component Control: Item {
            id: ctrl
            required property string glyph
            signal tapped()

            width: 28
            height: 28

            Rectangle {
                anchors.fill: parent
                radius: Theme.radius - 3
                color: ctrlMouse.containsMouse ? Theme.bgA : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: ctrl.glyph
                color: ctrlMouse.containsMouse ? Theme.fg : Theme.fgDim
                font.family: Theme.fontIcons
                font.pixelSize: 12
            }

            MouseArea {
                id: ctrlMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ctrl.tapped()
            }
        }

        Control {
            glyph: Theme.iconPrev
            onTapped: if (media.player) media.player.previous()
        }
        Control {
            glyph: media.playing ? Theme.iconPause : Theme.iconPlay
            onTapped: if (media.player) media.player.togglePlaying()
        }
        Control {
            glyph: Theme.iconNext
            onTapped: if (media.player) media.player.next()
        }
    }
}
