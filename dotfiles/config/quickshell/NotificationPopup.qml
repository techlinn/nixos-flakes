import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "Theme.js" as Theme

Rectangle {
    id: root
    required property var modelData

    readonly property int urgency: modelData.urgency
    readonly property bool critical: urgency === NotificationUrgency.Critical
    readonly property color accentColor: critical ? Theme.red
        : urgency === NotificationUrgency.Low ? Theme.fgFaint
        : (Theme.focus || Theme.accent)

    readonly property string iconSource: {
        const img = modelData.image;
        if (img && img.length > 0) {
            if (img.indexOf("image://qsimage/") === 0 || img.indexOf("image://qspixmap/") === 0)
                return img;
            if (img.indexOf("file://") === 0 || img.charAt(0) === "/")
                return img;
            if (img.indexOf("image://icon/") === 0) {
                const target = img.slice("image://icon/".length).split("?")[0];
                if (target.charAt(0) === "/")
                    return img;
            }
        }
        return "";
    }

    readonly property string initial: {
        const name = (modelData.appName || "").trim();
        return name.length > 0 ? name.charAt(0).toUpperCase() : "•";
    }

    readonly property var visibleActions: {
        const list = modelData.actions;
        const out = [];
        for (let i = 0; i < list.length; i++)
            if (list[i].identifier !== "default")
                out.push(list[i]);
        return out;
    }

    readonly property bool hasIcon: iconSource.length > 0
    readonly property int duration: 4000
    property real remaining: duration
    readonly property bool hovered: hoverHandler.hovered

    width: 360
    implicitHeight: layout.implicitHeight + 22
    height: implicitHeight
    radius: Theme.radius
    color: Theme.bgA
    border.color: Theme.outline || Theme.brdr
    border.width: 2
    clip: true
    opacity: 0
    Component.onCompleted: opacity = 1
    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    Row {
        id: layout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 11
        }
        spacing: 11

        Rectangle {
            id: iconBox
            width: 42
            height: 42
            radius: Theme.radius - 2
            color: Theme.bgAltA

            Image {
                anchors.fill: parent
                anchors.margins: 5
                visible: root.hasIcon
                source: root.iconSource
                sourceSize.width: 96
                sourceSize.height: 96
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !root.hasIcon
                text: root.initial
                color: Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.weight: Font.Medium
            }
        }

        Column {
            id: textColumn
            width: layout.width - iconBox.width - layout.spacing
            spacing: 3

            Text {
                width: parent.width
                text: root.modelData.appName
                color: root.accentColor
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.letterSpacing: 0.5
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Text {
                width: parent.width
                text: root.modelData.summary
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                wrapMode: Text.WordWrap
                visible: text.length > 0
            }

            Text {
                width: parent.width
                text: root.modelData.body
                color: Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: 11
                lineHeight: 1.15
                wrapMode: Text.WordWrap
                maximumLineCount: 6
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Row {
                id: actionsRow
                width: parent.width
                spacing: 6
                visible: root.visibleActions.length > 0

                Repeater {
                    id: actions
                    model: root.visibleActions

                    delegate: Rectangle {
                        required property var modelData

                        implicitWidth: actionLabel.implicitWidth + 18
                        height: 24
                        radius: Theme.radius - 2
                        color: actionMouse.containsMouse ? Theme.brdr : Theme.bgAltA
                        border.color: Theme.brdr
                        border.width: actionMouse.containsMouse ? 1 : 0

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.invoke();
                                root.modelData.dismiss();
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: root.hovered
        width: 20
        height: 20
        radius: Theme.radius - 3
        color: Theme.bgAltA
        anchors {
            top: parent.top
            right: parent.right
            margins: 6
        }

        Text {
            anchors.centerIn: parent
            text: "✕"
            color: Theme.fgDim
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.modelData.dismiss()
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        height: 2
        width: parent.width * Math.max(0, Math.min(1, root.remaining / root.duration))
        color: root.accentColor
        visible: !root.critical
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: root.modelData.dismiss()
    }

    Timer {
        interval: 50
        repeat: true
        // a critical notification stays until dismissed, and hovering pauses it
        running: !root.critical && !root.hovered
        onTriggered: {
            root.remaining -= interval;
            if (root.remaining <= 0) {
                running = false;
                root.modelData.expire();
            }
        }
    }
}
