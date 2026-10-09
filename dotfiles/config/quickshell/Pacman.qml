// The active-workspace marker of the "noir" bar: a small Pac-Man, drawn as a
// shape so it stays sharp at any size. `mouth` is the half-opening in degrees;
// animate it for a chomp. `facingLeft` mirrors it.
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property color color: "white"
    property real mouth: 32
    property bool facingLeft: false

    implicitWidth: 11
    implicitHeight: 11

    Shape {
        anchors.fill: parent
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer
        transform: Scale {
            origin.x: root.width / 2
            xScale: root.facingLeft ? -1 : 1
        }

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: root.color
            startX: root.width / 2
            startY: root.height / 2

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2
                radiusY: root.height / 2
                startAngle: root.mouth
                sweepAngle: 360 - 2 * root.mouth
                moveToStart: false
            }
            PathLine {
                x: root.width / 2
                y: root.height / 2
            }
        }
    }
}
