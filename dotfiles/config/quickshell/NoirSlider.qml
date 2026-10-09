// A thin slider: accent fill, a handle that appears on hover. Drag, click or
// scroll. `value` is 0..1; `moved(v)` fires while the user changes it.
import QtQuick
import "Theme.js" as Theme

Item {
    id: root
    property real value: 0
    property bool dimmed: false
    signal moved(real v)

    implicitHeight: 18
    implicitWidth: 160

    readonly property real shown: Math.max(0, Math.min(1, value))

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Qt.alpha(Theme.fg, 0.12)

        Rectangle {
            width: parent.width * root.shown
            height: parent.height
            radius: parent.radius
            color: root.dimmed ? Theme.fgFaint : NoirState.accent
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    Rectangle {
        x: Math.round((root.width - width) * root.shown)
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        height: 10
        radius: 5
        color: root.dimmed ? Theme.fgDim : NoirState.accent
        border.width: 2
        border.color: Theme.bg
        scale: area.containsMouse || area.pressed ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        function at(x) {
            return Math.max(0, Math.min(1, (x - 5) / Math.max(1, width - 10)));
        }
        onPressed: mouse => root.moved(at(mouse.x))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(at(mouse.x));
        }
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
