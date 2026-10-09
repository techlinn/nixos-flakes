// Workspaces for the "noir" bar: a row of small rings, and a Pac-Man that
// glides to the focused one. Six are always shown; more appear while a higher
// workspace is in use. Click a ring to go there, scroll to step through them.
import QtQuick
import Quickshell.Hyprland
import "Theme.js" as Theme

Item {
    id: root

    property color accent: Theme.fg
    readonly property int step: 26
    readonly property int slotWidth: 12
    readonly property int minimum: 6
    readonly property int maximum: 9

    readonly property int focusedId: {
        const ws = Hyprland.focusedWorkspace;
        return ws ? ws.id : 1;
    }
    readonly property int highestUsed: {
        let top = focusedId;
        const wins = Hyprland.toplevels.values;
        for (let i = 0; i < wins.length; i++) {
            const w = wins[i].workspace;
            if (w && w.id > top && w.id <= maximum)
                top = w.id;
        }
        return top;
    }
    readonly property int count: Math.max(minimum, Math.min(maximum, highestUsed))

    function occupied(id) {
        const wins = Hyprland.toplevels.values;
        for (let i = 0; i < wins.length; i++)
            if (wins[i].workspace && wins[i].workspace.id === id)
                return true;
        return false;
    }

    implicitWidth: (count - 1) * step + slotWidth
    implicitHeight: 26

    Behavior on implicitWidth {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    Repeater {
        model: root.count

        delegate: Item {
            id: slot
            required property int index
            readonly property int wsId: index + 1
            readonly property bool focused: wsId === root.focusedId
            readonly property bool used: root.occupied(wsId)

            x: index * root.step
            width: root.slotWidth
            height: root.height

            // A ring; filled in while the workspace has windows on it.
            Rectangle {
                id: ring
                readonly property color tone: area.containsMouse ? Theme.fg : (slot.used ? Theme.fgDim : Theme.fgFaint)

                anchors.centerIn: parent
                width: 5
                height: 5
                radius: 2.5
                color: slot.used ? Qt.alpha(tone, 0.55) : "transparent"
                border.width: 1
                border.color: tone
                opacity: slot.focused ? 0 : 1
                scale: area.containsMouse ? 1.35 : 1

                Behavior on opacity { NumberAnimation { duration: 140 } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                anchors.leftMargin: -6
                anchors.rightMargin: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + slot.wsId)
            }
        }
    }

    Pacman {
        id: pac
        y: (root.height - height) / 2
        x: (Math.min(root.focusedId, root.count) - 1) * root.step + (root.slotWidth - width) / 2 - 1
        color: root.accent
        visible: root.focusedId >= 1 && root.focusedId <= root.maximum

        // It looks the way it is going while it travels, and to the right at rest.
        property real lastX: x
        property bool goingLeft: false
        facingLeft: glide.running && goingLeft
        onXChanged: {
            if (Math.abs(x - lastX) > 1)
                goingLeft = x < lastX;
            lastX = x;
        }

        Behavior on x {
            NumberAnimation { id: glide; duration: 260; easing.type: Easing.InOutCubic }
        }

        // Chomp while it travels, then settle with the mouth open.
        SequentialAnimation on mouth {
            running: glide.running
            loops: Animation.Infinite
            NumberAnimation { to: 4; duration: 70 }
            NumberAnimation { to: 38; duration: 70 }
        }
        NumberAnimation on mouth {
            running: !glide.running
            to: 32
            duration: 90
        }

        // The pellet in front of its mouth, as long as it is standing still.
        Rectangle {
            x: pac.facingLeft ? -3.2 : pac.width + 1.6
            anchors.verticalCenter: parent.verticalCenter
            width: 1.6
            height: 1.6
            radius: 0.8
            color: root.accent
            opacity: glide.running ? 0 : 0.9
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    // Scroll anywhere on the row to step through the workspaces.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const next = root.focusedId + (event.angleDelta.y < 0 ? 1 : -1);
            if (next >= 1 && next <= root.maximum)
                Hyprland.dispatch("workspace " + next);
        }
    }
}
