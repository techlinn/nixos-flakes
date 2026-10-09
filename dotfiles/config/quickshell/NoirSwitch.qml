// An on/off switch in the bar's style.
import QtQuick
import "Theme.js" as Theme

Item {
    id: root
    property bool on: false
    property bool available: true
    signal toggled()

    implicitWidth: 30
    implicitHeight: 16
    opacity: available ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.on ? NoirState.accent : "transparent"
        border.width: 1
        border.color: root.on ? NoirState.accent : Theme.fgFaint
        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }

        Rectangle {
            x: root.on ? parent.width - width - 3 : 3
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 10
            radius: 5
            color: root.on ? NoirState.onAccent : Theme.fgDim
            Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 140 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        enabled: root.available
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
