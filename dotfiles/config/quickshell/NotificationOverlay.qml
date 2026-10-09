import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var server

    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 8
    }

    color: "transparent"
    surfaceFormat.opaque: false
    exclusiveZone: 0
    implicitWidth: 372
    implicitHeight: Math.min(column.implicitHeight, 640)
    mask: Region { item: column }

    Column {
        id: column
        anchors {
            top: parent.top
            right: parent.right
        }
        width: 360
        spacing: 8

        Repeater {
            model: root.server.trackedNotifications
            delegate: NotificationPopup {}
        }
    }
}
