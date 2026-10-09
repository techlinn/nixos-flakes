import QtQuick
import Quickshell.Hyprland
import "Theme.js" as Theme

Row {
    id: root
    property var monitor
    spacing: 7

    function workspaceFor(id) {
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++)
            if (list[i].id === id)
                return list[i];
        return null;
    }

    function occupied(id) {
        const wins = Hyprland.toplevels.values;
        for (let i = 0; i < wins.length; i++)
            if (wins[i].workspace && wins[i].workspace.id === id)
                return true;
        return false;
    }

    Repeater {
        model: 9

        delegate: Rectangle {
            id: ball
            required property int index

            readonly property int wsId: index + 1
            readonly property var ws: root.workspaceFor(wsId)
            readonly property bool focused: ws !== null && ws.focused
            readonly property bool hasWindows: root.occupied(wsId)

            width: 8
            height: 8
            radius: 4
            color: ball.focused ? Theme.fg
                                : (ball.hasWindows ? Theme.fgDim : Theme.fgFaint)
            scale: ball.focused ? 1.35 : 1.0

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -3
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + ball.wsId)
            }
        }
    }
}
