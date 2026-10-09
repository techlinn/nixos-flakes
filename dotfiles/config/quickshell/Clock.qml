import QtQuick
import Quickshell
import Quickshell.Io
import "Theme.js" as Theme

Row {
    id: root
    spacing: 5

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Item {
        id: clockItem
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: label.implicitWidth + 10
        implicitHeight: label.implicitHeight + 4

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius - 2
            color: hover.containsMouse ? Theme.bgAltA : "transparent"
            z: -1
        }

        Text {
            id: label
            anchors.centerIn: parent
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
        }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                const centre = clockItem.mapToItem(null, clockItem.width / 2, 0).x;
                toggle.command = [ "sh", "-c", "qs ipc call calendar toggleAt " + Math.round(centre) ];
                toggle.startDetached();
            }
        }
    }

    Process {
        id: toggle
    }
}
