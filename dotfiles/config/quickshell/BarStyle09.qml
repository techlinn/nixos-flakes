import QtQuick
import QtQuick.Layouts
import "Theme.js" as Theme

Item {
    id: root
    anchors.fill: parent

    function overlayColor(alpha) {
        const h = Theme.bgAlt;
        return Qt.rgba(
            parseInt(h.substr(1, 2), 16) / 255,
            parseInt(h.substr(3, 2), 16) / 255,
            parseInt(h.substr(5, 2), 16) / 255,
            alpha);
    }

    component Ghost: Rectangle {
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: 30
        radius: Theme.radius
        color: root.overlayColor(0.4)
        border.color: Theme.brdr
        border.width: 2
    }

    RowLayout {
        anchors { left: parent.left; leftMargin: 10; top: parent.top; topMargin: 8 }
        spacing: 10
        Ghost {
            implicitWidth: workspaces.implicitWidth + 26
            Row { id: workspaces; anchors.centerIn: parent; spacing: 7
                Workspaces {} }
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        Ghost {
            implicitWidth: clock.implicitWidth + 26
            Row { id: clock; anchors.centerIn: parent; Clock {} }
        }
    }

    RowLayout {
        anchors { right: parent.right; rightMargin: 10; top: parent.top; topMargin: 8 }
        spacing: 10
        Ghost {
            implicitWidth: systemRow.implicitWidth + 26
            Row { id: systemRow; anchors.centerIn: parent; spacing: 12
                Stats {}
                VolumeWidget {}
                BatteryWidget {} }
        }
        Ghost {
            implicitWidth: powerRow.implicitWidth + 26
            Row { id: powerRow; anchors.centerIn: parent; PowerButton {} }
        }
    }
}
