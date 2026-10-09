// A small label under a bar icon, shown after the pointer has rested on it.
//
//   NoirTip { target: someItem; text: "Bluetooth"; show: area.containsMouse }
import QtQuick
import Quickshell
import "Theme.js" as Theme

PopupWindow {
    id: tip
    required property Item target
    property string text: ""
    property bool show: false

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 9
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: label.implicitWidth + 18
    implicitHeight: label.implicitHeight + 10
    color: "transparent"
    visible: false

    Timer {
        id: delay
        interval: 450
        onTriggered: tip.visible = tip.show && tip.text.length > 0
    }
    onShowChanged: {
        if (show) {
            delay.restart();
        } else {
            delay.stop();
            visible = false;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        border.width: 1
        border.color: NoirState.outline
        radius: Math.min(Theme.radius, 6)

        Text {
            id: label
            anchors.centerIn: parent
            text: tip.text
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }
}
