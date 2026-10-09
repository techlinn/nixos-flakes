// The app bar of the "noir" bar: one icon for every app that has a window
// open, followed by apps that only live in the system tray (running in the
// background with no window, like Steam or a closed Discord).
//
//   left click     go to the app; click again to step through its windows
//   middle click   close the app's window
//   right click    the app's tray menu, if it has one
//
// The app you are in has a small mark under its icon.
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "Theme.js" as Theme

Row {
    id: root
    spacing: 9

    property color accent: Theme.fg

    function norm(text) {
        return String(text || "").toLowerCase().replace(/[^a-z0-9]/g, "");
    }

    // The tray item that belongs to an app, matched by name.
    function trayFor(appId) {
        const want = norm(appId);
        if (want.length < 3 || !SystemTray.items)
            return null;
        const items = SystemTray.items.values;
        for (let i = 0; i < items.length; i++) {
            const id = norm(items[i].id), title = norm(items[i].title);
            if (id.length >= 3 && (id.indexOf(want) >= 0 || want.indexOf(id) >= 0))
                return items[i];
            if (title.length >= 3 && (title.indexOf(want) >= 0 || want.indexOf(title) >= 0))
                return items[i];
        }
        return null;
    }

    // The terminal, Discord, the file manager, Spotify and Obsidian have icons of
    // their own (icons/*.png, grey tiles with a light symbol) that are drawn in the
    // bar's accent colour.
    // An app is matched by the end of its name, so org.gnome.Nautilus, kitty and
    // equibop are found, and a name that merely contains one is not.
    readonly property string iconDir: Qt.resolvedUrl("icons/")
    readonly property var customIcons: [
        ["terminal", ["kitty", "alacritty", "foot", "footclient", "wezterm", "konsole", "xterm", "ptyxis", "gnometerminalserver"]],
        ["discord", ["equibop", "vesktop", "vencord", "equicord", "discord"]],
        ["files", ["nautilus", "thunar", "dolphin", "nemo", "pcmanfm"]],
        ["spotify", ["spotify"]],
        ["obsidian", ["obsidian"]]
    ]

    function customIcon(appId) {
        const n = norm(appId);
        if (n.length < 3)
            return "";
        for (let i = 0; i < customIcons.length; i++) {
            const names = customIcons[i][1];
            for (let j = 0; j < names.length; j++)
                if (n === names[j] || n.endsWith(names[j]))
                    return iconDir + customIcons[i][0] + ".png";
        }
        return "";
    }

    function iconFor(appId) {
        const id = String(appId || "").slice(0, 128);
        const custom = customIcon(id);
        if (custom.length > 0)
            return custom;
        const entry = id.length > 0 ? DesktopEntries.heuristicLookup(id) : null;
        const named = String((entry && entry.icon) || "");
        if (named.startsWith("/") && named.indexOf("..") === -1)
            return "file://" + named;
        if (/^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(named)) {
            const themed = Quickshell.iconPath(named, true);
            if (themed.length > 0)
                return themed;
        }
        if (/^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(id)) {
            const guess = Quickshell.iconPath(id, true);
            if (guess.length > 0)
                return guess;
        }
        return "";
    }

    function nameFor(appId) {
        const entry = DesktopEntries.heuristicLookup(String(appId || "").slice(0, 128));
        return (entry && entry.name) ? entry.name : String(appId || "App");
    }

    // One entry per app: { appId, name, icon, windows, active, tray }
    readonly property var apps: {
        const list = ToplevelManager.toplevels ? ToplevelManager.toplevels.values : [];
        const byApp = {};
        const order = [];
        for (let i = 0; i < list.length; i++) {
            const w = list[i];
            const id = String(w.appId || "");
            if (id.length === 0)
                continue;
            if (!byApp[id]) {
                byApp[id] = { appId: id, name: nameFor(id), icon: iconFor(id), custom: customIcon(id).length > 0, windows: [], active: false, tray: trayFor(id) };
                order.push(id);
            }
            byApp[id].windows.push(w);
            if (w.activated)
                byApp[id].active = true;
        }
        return order.map(id => byApp[id]);
    }

    // Tray items of apps that have no window open.
    readonly property var background: {
        if (!SystemTray.items)
            return [];
        const taken = apps.map(a => a.tray).filter(t => t !== null);
        return SystemTray.items.values.filter(item => taken.indexOf(item) < 0);
    }

    readonly property int count: apps.length + background.length

    component Slot: Item {
        id: slot
        property string source: ""
        // Drawn in the accent colour (the icons in icons/).
        property bool tinted: false
        // Any other app's own icon: a pink symbol on a dark tile, the same look.
        property bool toned: false
        property string label: ""
        property bool active: false
        property bool marked: false
        property var trayItem: null
        signal activated()
        signal closed()

        implicitWidth: 16
        implicitHeight: 26

        Item {
            id: glyph
            anchors.centerIn: parent
            width: 16
            height: 16
            visible: slot.tinted && slot.source.length > 0
            opacity: slot.active || slotArea.containsMouse ? 1 : 0.88
            scale: slotArea.pressed ? 0.9 : (slotArea.containsMouse ? 1.1 : 1)
            Behavior on opacity { NumberAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

            Image {
                id: glyphShape
                anchors.fill: parent
                source: slot.tinted ? slot.source : ""
                sourceSize: Qt.size(64, 64)
                smooth: true
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: glyphShape
                colorization: 1.0
                brightness: 0.18
                contrast: 0.45
                colorizationColor: slot.active || slotArea.containsMouse ? Qt.lighter(root.accent, 1.2) : root.accent
            }
        }

        Item {
            id: tone
            anchors.centerIn: parent
            width: 16
            height: 16
            visible: slot.toned && slot.source.length > 0
            opacity: slot.active || slotArea.containsMouse ? 1 : 0.88
            scale: slotArea.pressed ? 0.9 : (slotArea.containsMouse ? 1.1 : 1)
            Behavior on opacity { NumberAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Qt.rgba(1, 1, 1, slot.active || slotArea.containsMouse ? 0.10 : 0.07)
            }
            IconImage {
                anchors.centerIn: parent
                implicitSize: 11
                source: slot.toned ? slot.source : ""
                asynchronous: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    brightness: 0.25
                    contrast: 0.35
                    colorizationColor: slot.active || slotArea.containsMouse ? Qt.lighter(root.accent, 1.2) : root.accent
                }
            }
        }

        IconImage {
            anchors.centerIn: parent
            visible: !slot.tinted && !slot.toned && slot.source.length > 0
            implicitSize: 16
            source: slot.source
            asynchronous: true
            opacity: slot.active || slotArea.containsMouse ? 1 : 0.72
            scale: slotArea.pressed ? 0.9 : (slotArea.containsMouse ? 1.1 : 1)
            Behavior on opacity { NumberAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        }

        // No icon in the icon theme: the app's initial in a ring.
        Rectangle {
            anchors.centerIn: parent
            visible: slot.source.length === 0
            width: 14
            height: 14
            radius: 7
            color: "transparent"
            border.width: 1
            border.color: slot.active || slotArea.containsMouse ? Qt.lighter(root.accent, 1.2) : root.accent
            Text {
                anchors.centerIn: parent
                text: slot.label.charAt(0).toUpperCase()
                font.family: Theme.fontFamily
                font.pixelSize: 8
                font.weight: Font.DemiBold
                color: parent.border.color
            }
        }

        // The mark under the app you are in.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height - 4
            width: slot.marked ? 8 : 0
            height: 2
            radius: 1
            color: root.accent
            opacity: slot.marked ? 1 : 0
            Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 140 } }
        }

        QsMenuAnchor {
            id: menu
            menu: slot.trayItem ? slot.trayItem.menu : null
            anchor.item: slot
            anchor.edges: Edges.Bottom
            anchor.gravity: Edges.Bottom
            anchor.margins.top: 6
        }

        MouseArea {
            id: slotArea
            anchors.fill: parent
            anchors.leftMargin: -4
            anchors.rightMargin: -4
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    if (slot.trayItem && slot.trayItem.hasMenu)
                        menu.open();
                } else if (mouse.button === Qt.MiddleButton) {
                    slot.closed();
                } else {
                    slot.activated();
                }
            }
        }

        NoirTip {
            target: slot
            text: slot.label
            show: slotArea.containsMouse
        }
    }

    Repeater {
        model: root.apps
        delegate: Slot {
            id: appSlot
            required property var modelData
            source: modelData.icon
            tinted: modelData.custom
            toned: !modelData.custom && modelData.icon.length > 0
            label: modelData.windows.length > 1 ? modelData.name + "  (" + modelData.windows.length + " windows)" : modelData.name
            active: modelData.active
            marked: modelData.active
            trayItem: modelData.tray

            // Go to the app. If it is already in front, step to its next window.
            onActivated: {
                const wins = modelData.windows;
                let next = 0;
                for (let i = 0; i < wins.length; i++)
                    if (wins[i].activated)
                        next = (i + 1) % wins.length;
                wins[next].activate();
            }
            onClosed: {
                const wins = modelData.windows;
                for (let i = 0; i < wins.length; i++) {
                    if (wins[i].activated) {
                        wins[i].close();
                        return;
                    }
                }
                wins[0].close();
            }
        }
    }

    Repeater {
        model: root.background
        delegate: Slot {
            required property var modelData
            // Tray items name their icon; if the icon theme lacks it, fall back to the initial.
            readonly property string iconName: {
                const src = String(modelData.icon || "");
                const prefix = "image://icon/";
                return src.startsWith(prefix) ? src.slice(prefix.length).split("?")[0] : "";
            }
            readonly property string custom: root.customIcon(modelData.id).length > 0 ? root.customIcon(modelData.id) : root.customIcon(modelData.title)
            tinted: custom.length > 0
            source: custom.length > 0 ? custom : ((iconName.length > 0 && Quickshell.iconPath(iconName, true).length === 0) ? "" : String(modelData.icon || ""))
            label: String(modelData.title || modelData.id || "App")
            trayItem: modelData
            onActivated: {
                if (modelData.onlyMenu && modelData.hasMenu)
                    return;
                modelData.activate();
            }
            onClosed: modelData.secondaryActivate()
        }
    }
}
