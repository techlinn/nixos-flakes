// "noir": six pills on a clear bar.
//
//   [ launcher › ]  [ workspaces  ♪ ]      [ clock ]      [ apps ]  [ status ]  [ ‹ power ]
//
// The two end pills are drawers. Their arrow slides them open along the bar:
//
//   left    the icon is the app launcher; the drawer holds quick actions:
//           terminal, files, browser, screenshot, themes (ALT + S), system
//   right   the drawer holds the session actions: lock, log out, suspend,
//           reboot, shut down. Log out, reboot and shut down have to be
//           clicked twice: the first click arms the button for three seconds.
//
// In between: a Pac-Man sits on the focused workspace; a note appears while a
// player is running (click: play/pause, scroll: next/previous); the clock
// shows the date while the pointer is on it and opens the calendar; the app
// bar has an icon for every open app (and for apps that only sit in the system
// tray); Bluetooth, sound and network share a pill and each opens its own panel.
//
// Sizes are the ones measured from the design this was modelled on: a 36 px
// bar, pills 26 px tall and fully round, 26 px between workspaces.
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "Theme.js" as Theme

Item {
    id: root
    anchors.fill: parent

    // The highlight: the focused-window border colour, so bar and windows match.
    readonly property color accent: (typeof Theme.focus === "string" && Theme.focus.length > 0)
        ? Theme.focus : Theme.red
    // The clock is set in the application (monospace) font. If that font is not
    // installed, the icon font is used, which is monospace and always present;
    // otherwise the digits would fall back to the proportional interface font.
    readonly property string monoFont: Qt.fontFamilies().indexOf(Theme.fontMono) >= 0
        ? Theme.fontMono : Theme.fontIcons
    readonly property int pillHeight: 26
    readonly property int pillTop: 5
    readonly property int edge: 6
    readonly property int gap: 9

    Process {
        id: runner
    }
    function run(command) {
        runner.command = [ "sh", "-c", command ];
        runner.startDetached();
    }
    function centreOf(item) {
        return Math.round(item.mapToItem(null, item.width / 2, 0).x);
    }

    component Pill: Rectangle {
        y: root.pillTop
        height: root.pillHeight
        radius: height / 2
        // The theme's background at the transparency chosen in ALT + S, so the
        // pills are as see-through as the windows (and get the same blur).
        color: Theme.bgA
        // Pills whose content animates by itself switch this off.
        property bool smooth: true
        Behavior on width {
            enabled: smooth
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // A thin arrow, drawn so it stays crisp. `pointsLeft` flips it.
    component Chevron: Item {
        id: chevron
        property bool pointsLeft: false
        property color color: Theme.fgFaint
        implicitWidth: 5
        implicitHeight: 8

        Shape {
            anchors.fill: parent
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 1.2
                strokeColor: chevron.color
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                startX: chevron.pointsLeft ? 4 : 1
                startY: 1
                PathLine { x: chevron.pointsLeft ? 1 : 4; y: 4 }
                PathLine { x: chevron.pointsLeft ? 4 : 1; y: 7 }
            }
        }
    }

    // One clickable half of an end pill.
    component Half: MouseArea {
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        height: parent.height
    }

    // An icon inside a drawer. `confirm` makes it need a second click: the
    // first one arms it (filled with the accent) for three seconds.
    component Action: Item {
        id: action
        required property string glyph
        required property string tip
        property bool confirm: false
        property bool armed: false
        property int size: 12
        signal triggered()

        width: 24
        height: parent.height

        Timer {
            id: disarm
            interval: 3000
            onTriggered: action.armed = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: 20
            height: 20
            radius: 10
            color: action.armed ? root.accent : (actionArea.containsMouse ? NoirState.hover : "transparent")
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            anchors.centerIn: parent
            text: action.glyph
            font.family: Theme.fontIcons
            font.pixelSize: action.size
            color: action.armed ? NoirState.onAccent : (actionArea.containsMouse ? Theme.fg : Theme.fgDim)
            scale: actionArea.pressed ? 0.88 : 1
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 80 } }
        }
        MouseArea {
            id: actionArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (action.confirm && !action.armed) {
                    action.armed = true;
                    disarm.restart();
                    return;
                }
                action.armed = false;
                action.triggered();
            }
        }
        NoirTip {
            target: action
            text: action.armed ? "Click again to " + action.tip.toLowerCase() : action.tip
            show: actionArea.containsMouse
        }
    }

    // A drawer closes by itself a while after the pointer has left its pill.
    component AutoClose: Timer {
        interval: 6000
    }

    // ---- far left: launcher and quick actions --------------------------------
    Pill {
        id: launcherPill
        x: root.edge
        width: 46 + quick.width
        smooth: false
        property bool open: false

        HoverHandler { id: launcherHover }
        AutoClose {
            running: launcherPill.open && !launcherHover.hovered
            onTriggered: launcherPill.open = false
        }

        Half {
            id: launcherHalf
            x: 0
            width: 28
            onClicked: root.run("rofi -show drun")
            Text {
                x: 9
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf313"
                font.family: Theme.fontIcons
                font.pixelSize: 15
                color: launcherHalf.containsMouse ? Qt.lighter(root.accent, 1.25) : root.accent
                scale: launcherHalf.pressed ? 0.9 : 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
            }
            NoirTip {
                target: launcherHalf
                text: "Apps"
                show: launcherHalf.containsMouse
            }
        }

        Item {
            id: quick
            x: 28
            height: parent.height
            width: launcherPill.open ? quickRow.implicitWidth + 4 : 0
            clip: true
            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Row {
                id: quickRow
                height: parent.height
                opacity: launcherPill.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 160 } }

                Action { glyph: "\uf120"; tip: "Terminal"; onTriggered: root.run("kitty") }
                Action { glyph: "\uf07b"; tip: "Files"; onTriggered: root.run("nautilus") }
                Action { glyph: "\uf0ac"; tip: "Browser"; onTriggered: root.run("zen") }
                Action { glyph: "\uf030"; tip: "Screenshot of an area"; onTriggered: root.run("sleep 0.2; $HOME/.scripts/pwnbox-screenshot clipboard") }
                Action { glyph: "\uf1fc"; tip: "Themes and settings"; onTriggered: root.run("$HOME/.scripts/pwnbox-theme menu") }
                Action {
                    id: systemAction
                    glyph: "\uf080"
                    tip: "System"
                    onTriggered: root.run("qs ipc call systempanel toggleAt " + root.centreOf(systemAction))
                }
            }
        }

        Half {
            id: quickHalf
            x: 28 + quick.width
            width: 18
            onClicked: launcherPill.open = !launcherPill.open
            Chevron {
                x: 2
                anchors.verticalCenter: parent.verticalCenter
                pointsLeft: launcherPill.open
                color: quickHalf.containsMouse ? Theme.fg : Theme.fgFaint
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            NoirTip {
                target: quickHalf
                text: launcherPill.open ? "Close" : "Quick actions"
                show: quickHalf.containsMouse
            }
        }
    }

    // ---- workspaces and the music note -------------------------------------
    Pill {
        x: launcherPill.x + launcherPill.width + root.gap
        width: 21 + workspaces.implicitWidth + (note.shown ? 30 + 16 : 21)

        NoirWorkspaces {
            id: workspaces
            x: 21
            accent: root.accent
        }

        Item {
            id: note

            readonly property var player: {
                const list = Mpris.players ? Mpris.players.values : [];
                for (let i = 0; i < list.length; i++)
                    if (list[i].isPlaying)
                        return list[i];
                return list.length > 0 ? list[0] : null;
            }
            readonly property bool shown: player !== null
            readonly property bool playing: shown && player.isPlaying

            x: workspaces.x + workspaces.implicitWidth + 16
            width: 16
            height: parent.height
            opacity: shown ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 160 } }

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: Theme.fontIcons
                font.pixelSize: 13
                color: noteArea.containsMouse ? Theme.fg : (note.playing ? root.accent : Theme.fgDim)
                scale: noteArea.pressed ? 0.9 : 1
                Behavior on color { ColorAnimation { duration: 160 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
            }

            MouseArea {
                id: noteArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (note.player && note.player.canTogglePlaying)
                        note.player.togglePlaying();
                }
                onWheel: wheel => {
                    if (!note.player)
                        return;
                    if (wheel.angleDelta.y < 0 && note.player.canGoNext)
                        note.player.next();
                    else if (wheel.angleDelta.y > 0 && note.player.canGoPrevious)
                        note.player.previous();
                }
            }
        }
    }

    // ---- clock ---------------------------------------------------------------
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Pill {
        id: clockPill
        anchors.horizontalCenter: parent.horizontalCenter
        width: clockRow.implicitWidth + 28

        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 0

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.family: root.monoFont
                font.pixelSize: 13
                font.weight: Font.Medium
                font.letterSpacing: 0.4
                color: clockArea.containsMouse ? Theme.fg : Theme.fgDim
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            // The date slides out while the pointer is on the clock.
            Item {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: clockArea.containsMouse ? date.implicitWidth + 9 : 0
                implicitHeight: date.implicitHeight
                clip: true
                Behavior on implicitWidth {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Text {
                    id: date
                    x: 9
                    text: Qt.formatDateTime(clock.date, "d MMMM yyyy")
                    font.family: root.monoFont
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.letterSpacing: 0.4
                    color: Theme.fgDim
                }
            }
        }

        MouseArea {
            id: clockArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.run("qs ipc call calendar toggleAt " + root.centreOf(clockPill))
        }
    }

    // ---- far right: session drawer and power ----------------------------------
    Pill {
        id: powerPill
        x: root.width - root.edge - width
        width: 46 + session.width
        smooth: false
        property bool open: false

        HoverHandler { id: powerHover }
        AutoClose {
            running: powerPill.open && !powerHover.hovered
            onTriggered: powerPill.open = false
        }

        Item {
            id: session
            x: 8
            height: parent.height
            width: powerPill.open ? sessionRow.implicitWidth : 0
            clip: true
            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Row {
                id: sessionRow
                height: parent.height
                opacity: powerPill.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 160 } }

                Action { glyph: "\uf023"; tip: "Lock"; onTriggered: { powerPill.open = false; root.run("hyprlock"); } }
                Action { glyph: "\uf08b"; tip: "Log out"; confirm: true; onTriggered: root.run("hyprctl dispatch exit") }
                Action { glyph: "\uf186"; tip: "Suspend"; onTriggered: { powerPill.open = false; root.run("systemctl suspend"); } }
                Action { glyph: "\uf021"; tip: "Reboot"; confirm: true; onTriggered: root.run("systemctl reboot") }
                Action { glyph: "\uf011"; tip: "Shut down"; confirm: true; onTriggered: root.run("systemctl poweroff") }
            }
        }

        Half {
            id: sessionHalf
            x: session.x + session.width - 8
            width: 20
            onClicked: powerPill.open = !powerPill.open
            Chevron {
                x: 11
                pointsLeft: !powerPill.open
                anchors.verticalCenter: parent.verticalCenter
                color: sessionHalf.containsMouse ? Theme.fg : Theme.fgFaint
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }
        Half {
            id: powerHalf
            x: sessionHalf.x + 20
            width: 26
            onClicked: powerPill.open = !powerPill.open
            Text {
                x: 4
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf011"
                font.family: Theme.fontIcons
                font.pixelSize: 14
                color: (powerHalf.containsMouse || powerPill.open) ? Qt.lighter(root.accent, 1.25) : root.accent
                scale: powerHalf.pressed ? 0.9 : 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
            }
            NoirTip {
                target: powerHalf
                text: powerPill.open ? "Close" : "Lock, log out, restart, shut down"
                show: powerHalf.containsMouse
            }
        }
    }

    // ---- status: Bluetooth, sound, network -----------------------------------
    Pill {
        id: statusPill
        x: powerPill.x - root.gap - width
        width: 16 + status.implicitWidth + 16

        NoirStatus {
            id: status
            x: 16
            height: parent.height
            accent: root.accent
            screen: root.QsWindow.window ? root.QsWindow.window.screen : null
        }
    }

    // ---- the app bar: every open app, then background apps from the tray ------
    Pill {
        x: statusPill.x - root.gap - width
        width: 14 + apps.implicitWidth + 14
        visible: apps.count > 0

        NoirApps {
            id: apps
            x: 14
            height: parent.height
            accent: root.accent
        }
    }
}
