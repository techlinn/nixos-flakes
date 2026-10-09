// Alt+Tab: a strip of live window previews in the middle of the screen.
//
// Hold ALT and tap TAB to step through the windows, most recently used first
// (SHIFT goes back). Let go of ALT to switch to the highlighted one. While it
// is open: ESC cancels, Q closes the highlighted window, the mouse works too.
//
// The keys arrive as Hyprland global shortcuts, bound in hyprland.conf:
//   pwnbox:switcher-next, pwnbox:switcher-previous, pwnbox:switcher-release.
//
// Two things make it feel immediate. The panel never waits for the previews:
// it pops in at once with app icons, and each preview fades in when its first
// frame arrives. And the switch itself is sent the moment ALT is released,
// while the panel is still fading out.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Commons

Scope {
    id: root

    // --- state --------------------------------------------------------------
    // `open` is the user's intent; `shown` is the surface being up, which
    // outlives `open` by the length of the closing animation.
    property bool open: false
    property bool shown: false
    // The windows offered, frozen when the switcher opens:
    // { toplevel, address, title, appId, appName, icon, workspace }
    property var entries: []
    property int index: 0
    property var targetScreen: null
    // 0 = hidden, 1 = fully open: drives the fade of the panel and of the dim.
    property real progress: 0
    // The pop: the panel grows into place with a slight overshoot as it opens,
    // and eases back a little as it closes.
    property real pop: 0
    // The highlight only glides once you have stepped; on opening it is
    // simply already in place.
    property bool glide: false

    // The mouse only selects once it has really moved. The panel often opens
    // right under a resting pointer, and that must not change the selection.
    property bool pointerPrimed: false
    property real pointerX0: -1
    property real pointerY0: -1

    readonly property int openDuration: 170
    readonly property int popDuration: 260
    readonly property int closeDuration: 120

    // Hyprland crashes if a window capture is requested while no monitor is
    // up (seen when the only output disappears). Nothing here opens, and every
    // preview lets go, unless there is a real monitor.
    readonly property bool outputsOk: {
        const monitors = Hyprland.monitors ? (Hyprland.monitors.values || []) : [];
        return monitors.length > 0 && Hyprland.focusedMonitor !== null;
    }
    onOutputsOkChanged: if (!root.outputsOk && root.shown) {
        root.open = false;
        openAnim.stop();
        closeAnim.stop();
        root.progress = 0;
        root.pop = 0;
        root.shown = false;
        root.entries = [];
    }

    function fgA(alpha) {
        return Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, alpha);
    }

    // --- which window was used most recently -------------------------------
    // Hyprland reports every focus change. A window only counts as "used" once
    // it has held focus for a moment: when you switch to a window on another
    // workspace, Hyprland focuses that workspace's last window for an instant
    // on the way, and that must not reorder the list.
    property var mru: []
    property string activeAddress: ""
    property string settlingAddress: ""
    // After a switch, Hyprland can hand focus back to the old window when the
    // panel lets go of the keyboard. For a short while, ask again if it does.
    property string wantedAddress: ""
    property real wantedUntil: 0

    function norm(value) {
        const text = String(value === undefined || value === null ? "" : value).trim().toLowerCase().replace(/^0x/, "");
        return /^[0-9a-f]+$/.test(text) && !/^0+$/.test(text) ? text : "";
    }

    function promote(address) {
        const key = root.norm(address);
        if (key.length === 0)
            return;
        const next = root.mru.filter(a => a !== key);
        next.unshift(key);
        root.mru = next;
    }

    Timer {
        id: settle
        interval: 100
        onTriggered: root.promote(root.settlingAddress)
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const name = event.name;
            if (name === "activewindowv2") {
                const key = root.norm(event.data);
                if (key.length === 0)
                    return;
                root.activeAddress = key;
                root.settlingAddress = key;
                settle.restart();
                if (root.wantedAddress.length > 0) {
                    if (Date.now() > root.wantedUntil)
                        root.wantedAddress = "";
                    else if (key !== root.wantedAddress)
                        Hyprland.dispatch("focuswindow address:0x" + root.wantedAddress);
                }
            } else if (name === "closewindow") {
                const key = root.norm(String(event.data).split(",")[0]);
                if (key.length > 0)
                    root.mru = root.mru.filter(a => a !== key);
            } else if (name === "openwindow") {
                // So the new window's class and focus order are known next time.
                Hyprland.refreshToplevels();
            }
        }
    }

    Component.onCompleted: Hyprland.refreshToplevels()

    // --- the list ------------------------------------------------------------
    readonly property int maxLabel: 96

    function label(value) {
        const text = String(value || "");
        return text.length > root.maxLabel ? text.slice(0, root.maxLabel) + "…" : text;
    }

    function iconFor(appId) {
        const fallback = Quickshell.iconPath("application-x-executable", true);
        const id = String(appId || "").slice(0, 128);
        if (id.length === 0)
            return fallback;
        const entry = DesktopEntries.heuristicLookup(id);
        const named = String((entry && entry.icon) || "");
        if (named.length > 0 && named.length <= 512) {
            if (named.startsWith("/") && named.indexOf("..") === -1)
                return "file://" + named;
            if (/^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(named)) {
                const themed = Quickshell.iconPath(named, true);
                if (themed.length > 0)
                    return themed;
            }
        }
        if (!/^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(id))
            return fallback;
        const guess = Quickshell.iconPath(id, true);
        return guess.length > 0 ? guess : fallback;
    }

    function build() {
        const toplevels = Hyprland.toplevels ? (Hyprland.toplevels.values || []) : [];
        const active = root.activeAddress.length > 0 ? root.activeAddress
            : (Hyprland.activeToplevel ? root.norm(Hyprland.activeToplevel.address) : "");
        const list = [];
        for (let i = 0; i < toplevels.length; i++) {
            const t = toplevels[i];
            if (!t || !t.wayland || !t.monitor)
                continue;
            const ipc = t.lastIpcObject || {};
            if (ipc.mapped === false || ipc.hidden === true)
                continue;
            const ws = t.workspace;
            // Scratchpads (special workspaces) stay out of the way.
            if (ws && (ws.id < 0 || String(ws.name || "").startsWith("special")))
                continue;
            const address = root.norm(t.address);
            if (address.length === 0)
                continue;
            const appId = String(t.wayland.appId || ipc["class"] || "");
            const desktop = appId.length > 0 ? DesktopEntries.heuristicLookup(appId.slice(0, 128)) : null;
            const used = root.mru.indexOf(address);
            const history = (ipc.focusHistoryID === undefined || ipc.focusHistoryID < 0) ? 500 : ipc.focusHistoryID;
            const size = ipc.size || [];
            const aspect = (size.length === 2 && size[0] > 0 && size[1] > 0) ? size[0] / size[1] : 16 / 9;
            list.push({
                toplevel: t,
                aspect: aspect,
                address: address,
                title: root.label(t.title || t.wayland.title || appId),
                appId: appId,
                appName: root.label((desktop && desktop.name) || appId || "Window"),
                icon: root.iconFor(appId),
                workspace: ws ? String(ws.id) : "",
                // The focused window first, then by when each was last used,
                // then (never seen focused here) by Hyprland's own order.
                rank: address === active ? -1 : (used >= 0 ? used : 1000 + history)
            });
        }
        list.sort((a, b) => (a.rank - b.rank) || (a.address < b.address ? -1 : 1));
        return list;
    }

    function screenForFocusedMonitor() {
        const name = Hyprland.focusedMonitor ? String(Hyprland.focusedMonitor.name || "") : "";
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++)
            if (screens[i] && String(screens[i].name || "") === name)
                return screens[i];
        return screens.length > 0 ? screens[0] : null;
    }

    // --- actions -------------------------------------------------------------
    // ALT+TAB (dir = 1) or ALT+SHIFT+TAB (dir = -1): open, or step if open.
    function chord(dir) {
        if (root.open) {
            root.step(dir);
            return true;
        }
        if (!root.outputsOk)
            return false;
        const list = root.build();
        if (list.length === 0)
            return false;
        root.entries = list;
        root.glide = false;
        root.pointerPrimed = false;
        root.pointerX0 = -1;
        root.pointerY0 = -1;
        // The focused window is first, so one TAB lands on the one before it.
        root.index = list.length === 1 ? 0 : (dir > 0 ? 1 : list.length - 1);
        root.targetScreen = root.screenForFocusedMonitor();
        if (!root.targetScreen || String(root.targetScreen.name || "") === "")
            return false;
        closeAnim.stop();
        root.open = true;
        if (root.shown) {
            openAnim.restart();
        } else {
            root.pop = 0;
            root.shown = true;
        }
        return true;
    }

    function step(dir) {
        const n = root.entries.length;
        if (!root.open || n === 0)
            return;
        root.glide = true;
        root.index = (root.index + (dir > 0 ? 1 : -1) + n) % n;
    }

    function commit() {
        if (!root.open)
            return;
        const entry = root.index >= 0 && root.index < root.entries.length ? root.entries[root.index] : null;
        root.finish();
        if (!entry || entry.address === root.activeAddress)
            return;
        root.promote(entry.address);
        root.wantedAddress = entry.address;
        root.wantedUntil = Date.now() + 400;
        Hyprland.dispatch("focuswindow address:0x" + entry.address);
    }

    function cancel() {
        root.finish();
    }

    function finish() {
        if (!root.open)
            return;
        root.open = false;
        openAnim.stop();
        closeAnim.restart();
    }

    function closeSelected() {
        if (!root.open || root.index < 0 || root.index >= root.entries.length)
            return;
        const entry = root.entries[root.index];
        if (entry.toplevel && entry.toplevel.wayland)
            entry.toplevel.wayland.close();
        const rest = root.entries.filter(e => e.address !== entry.address);
        if (rest.length === 0) {
            root.cancel();
            return;
        }
        root.glide = false;
        root.entries = rest;
        root.index = Math.min(root.index, rest.length - 1);
    }

    ParallelAnimation {
        id: openAnim

        NumberAnimation {
            target: root
            property: "progress"
            to: 1
            duration: root.openDuration
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "pop"
            to: 1
            duration: root.popDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.25
        }
    }

    ParallelAnimation {
        id: closeAnim

        NumberAnimation {
            target: root
            property: "progress"
            to: 0
            duration: root.closeDuration
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root
            property: "pop"
            to: 0.55
            duration: root.closeDuration
            easing.type: Easing.InCubic
        }
        onFinished: {
            if (root.open)
                return;
            // Taking the surface down also lets go of every preview.
            root.shown = false;
            root.entries = [];
        }
    }

    // If the release is ever missed, do not sit there holding the keyboard.
    Timer {
        interval: 20000
        running: root.open
        onTriggered: root.cancel()
    }

    // --- keys from Hyprland --------------------------------------------------
    GlobalShortcut {
        appid: "pwnbox"
        name: "switcher-next"
        description: "Alt+Tab: open the window switcher, or step to the next window"
        onPressed: root.chord(1)
    }

    GlobalShortcut {
        appid: "pwnbox"
        name: "switcher-previous"
        description: "Alt+Tab: open the window switcher at the far end, or step back"
        onPressed: root.chord(-1)
    }

    // Bound to the release of ALT. A release bind reaches us as `released`.
    GlobalShortcut {
        appid: "pwnbox"
        name: "switcher-release"
        description: "Alt+Tab: ALT was released, switch to the highlighted window"
        onPressed: root.commit()
        onReleased: root.commit()
    }

    IpcHandler {
        target: "switcher"

        function next(): void { root.chord(1) }
        function previous(): void { root.chord(-1) }
        function commit(): void { root.commit() }
        function cancel(): void { root.cancel() }
    }

    // --- the surface ----------------------------------------------------------
    PanelWindow {
        id: surface

        visible: root.shown
        screen: root.targetScreen
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "pwnbox-switcher"
        WlrLayershell.layer: WlrLayer.Overlay
        // Held only while switching. It is given back the instant ALT is
        // released, so the window you picked has the keyboard straight away.
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        // The pop-in starts when the surface is really on screen, not when it
        // was asked for, so no part of the animation plays unseen.
        onBackingWindowVisibleChanged: {
            if (backingWindowVisible && root.open) {
                openAnim.restart();
                keys.forceActiveFocus();
            }
        }

        // Sizes come from the screen, not from this window: at the instant a
        // layer surface maps it does not have its final size yet, and a panel
        // centred in it is drawn in the wrong place for a frame or two.
        readonly property real screenW: root.targetScreen ? root.targetScreen.width : surface.width
        readonly property real screenH: root.targetScreen ? root.targetScreen.height : surface.height
        readonly property real ui: Math.max(0.75, Math.min(1.6, surface.screenW / 1920))
        readonly property int count: root.entries.length
        readonly property real pad: Math.round(16 * ui)
        readonly property real gap: Math.round(10 * ui)
        readonly property real inner: Math.round(8 * ui)
        readonly property real maxStrip: Math.max(200, surface.screenW - Math.round(96 * ui) - pad * 2)
        // Every preview has the same height and the width its window's shape
        // asks for, so a preview fills its card instead of sitting between two
        // bars. Very wide and very narrow windows are held to sensible limits.
        readonly property real previewMaxH: Math.round(170 * ui)
        readonly property real previewMinH: Math.round(104 * ui)
        readonly property real thumbMinW: Math.round(150 * ui)

        function thumbW(aspect, h) {
            return Math.round(Math.max(thumbMinW, Math.min(h * 2.0, h * aspect)));
        }

        function stripWidthAt(h) {
            let w = 0;
            for (let i = 0; i < root.entries.length; i++)
                w += thumbW(root.entries[i].aspect, h) + inner * 2 + (i > 0 ? gap : 0);
            return w;
        }

        // As tall as fits on the screen, down to a readable minimum; past that
        // the strip scrolls.
        readonly property real previewH: {
            let h = previewMaxH;
            for (let pass = 0; pass < 6 && h > previewMinH; pass++) {
                const w = stripWidthAt(h);
                if (w <= maxStrip)
                    break;
                h = Math.max(previewMinH, Math.min(h - 1, Math.floor(h * maxStrip / w)));
            }
            return h;
        }
        // Where each card sits in the strip.
        readonly property var layout: {
            const out = [];
            let x = 0;
            for (let i = 0; i < root.entries.length; i++) {
                const w = thumbW(root.entries[i].aspect, previewH) + inner * 2;
                out.push({ x: x, w: w });
                x += w + gap;
            }
            return out;
        }
        function slot(i) {
            return (i >= 0 && i < layout.length) ? layout[i] : { x: 0, w: thumbMinW + inner * 2 };
        }
        readonly property real labelH: Math.round(46 * ui)
        readonly property real cardH: inner + previewH + Math.round(8 * ui) + labelH + inner
        readonly property real stripW: layout.length > 0 ? layout[layout.length - 1].x + layout[layout.length - 1].w : 0
        readonly property real viewW: Math.min(stripW, maxStrip)

        // The rest of the screen, slightly dimmed. A click on it cancels.
        Rectangle {
            anchors.fill: parent
            color: Color.background
            opacity: 0.30 * root.progress
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.open
            onClicked: root.cancel()
        }

        Item {
            id: keys
            anchors.fill: parent
            focus: true

            // TAB is deliberately not handled here. Hyprland's ALT+TAB bind sees
            // every press and steps through the global shortcut; a second
            // handler would count the press twice, because the panel is given
            // the keyboard while TAB is still down from opening it.
            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Right:
                case Qt.Key_Down:
                    root.step(1);
                    break;
                case Qt.Key_Left:
                case Qt.Key_Up:
                    root.step(-1);
                    break;
                case Qt.Key_Escape:
                    root.cancel();
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                case Qt.Key_Space:
                    root.commit();
                    break;
                case Qt.Key_Q:
                case Qt.Key_Delete:
                    root.closeSelected();
                    break;
                default:
                    return;
                }
                event.accepted = true;
            }

            // Letting go of ALT is what switches.
            Keys.onReleased: event => {
                if (event.key === Qt.Key_Alt || event.key === Qt.Key_AltGr) {
                    root.commit();
                    event.accepted = true;
                }
            }
        }

        Rectangle {
            id: panel

            width: surface.viewW + surface.pad * 2
            height: surface.cardH + surface.pad * 2
            x: Math.round((surface.screenW - width) / 2)
            y: Math.round((surface.screenH - height) / 2 + (1 - root.pop) * 22 * surface.ui)
            radius: Style.cornerRadius + 4
            color: Color.surface
            border.width: Style.normalBorderWidth
            border.color: Color.border
            opacity: root.progress
            scale: 0.88 + 0.12 * root.pop

            // Swallow clicks on the panel itself, so only the dimmed area cancels.
            MouseArea { anchors.fill: parent }

            Flickable {
                id: strip

                x: surface.pad
                y: surface.pad
                width: surface.viewW
                height: surface.cardH
                contentWidth: surface.stripW
                contentHeight: surface.cardH
                interactive: false
                clip: surface.stripW > surface.viewW + 1
                // Keep the highlighted card in view when there are more than fit.
                contentX: {
                    const overflow = Math.max(0, surface.stripW - surface.viewW);
                    const at = surface.slot(root.index);
                    const centre = at.x + at.w / 2 - surface.viewW / 2;
                    return Math.max(0, Math.min(overflow, centre));
                }
                Behavior on contentX {
                    enabled: root.glide
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                // The highlight, which glides from card to card.
                Rectangle {
                    x: surface.slot(root.index).x
                    width: surface.slot(root.index).w
                    height: surface.cardH
                    radius: Style.cornerRadius
                    color: root.fgA(0.08)
                    border.width: Style.normalBorderWidth
                    border.color: Color.accent
                    Behavior on x {
                        enabled: root.glide
                        NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
                    }
                    Behavior on width {
                        enabled: root.glide
                        NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
                    }
                }

                Item {
                    width: surface.stripW
                    height: surface.cardH

                    Repeater {
                        model: root.entries

                        delegate: Item {
                            id: card

                            required property var modelData
                            required property int index
                            readonly property bool selected: root.index === card.index

                            x: surface.slot(card.index).x
                            width: surface.slot(card.index).w
                            height: surface.cardH

                            ClippingRectangle {
                                id: thumb

                                x: surface.inner
                                y: surface.inner
                                width: card.width - surface.inner * 2
                                height: surface.previewH
                                radius: Math.max(0, Style.cornerRadius - 2)
                                // A window too wide or too narrow for its card
                                // leaves a margin; keep that margin dark.
                                color: preview.hasContent ? Qt.rgba(0, 0, 0, 0.32) : Color.surfaceAlt
                                Behavior on color { ColorAnimation { duration: 130 } }
                                scale: card.selected ? 1.0 : 0.97
                                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

                                // Shown at once; the live preview fades in over it.
                                Image {
                                    anchors.centerIn: parent
                                    width: Math.round(Math.min(thumb.height * 0.46, 64 * surface.ui))
                                    height: width
                                    source: card.modelData.icon
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    smooth: true
                                    opacity: preview.hasContent ? 0 : 0.9
                                    Behavior on opacity { NumberAnimation { duration: 120 } }
                                }

                                ScreencopyView {
                                    id: preview

                                    anchors.centerIn: parent
                                    constraintSize: Qt.size(thumb.width, thumb.height)
                                    // Bound only while the switcher is up.
                                    captureSource: root.shown && root.outputsOk && card.modelData.toplevel
                                        ? card.modelData.toplevel.wayland : null
                                    live: root.shown && root.outputsOk
                                    paintCursor: false
                                    opacity: hasContent ? (card.selected ? 1.0 : 0.82) : 0
                                    Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                                }

                                // Workspace number, top right.
                                Rectangle {
                                    visible: card.modelData.workspace.length > 0
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: Math.round(6 * surface.ui)
                                    width: Math.max(height, wsText.implicitWidth + Math.round(10 * surface.ui))
                                    height: Math.round(18 * surface.ui)
                                    radius: height / 2
                                    color: Color.surface
                                    border.width: 1
                                    border.color: Color.border

                                    Text {
                                        id: wsText
                                        anchors.centerIn: parent
                                        textFormat: Text.PlainText
                                        text: card.modelData.workspace
                                        font.family: Style.font.family
                                        font.pixelSize: Math.max(9, Math.round(11 * surface.ui))
                                        color: root.fgA(0.8)
                                    }
                                }
                            }

                            Image {
                                id: appIcon

                                x: surface.inner + Math.round(2 * surface.ui)
                                y: thumb.y + thumb.height + Math.round(8 * surface.ui) + Math.round((surface.labelH - height) / 2)
                                width: Math.round(26 * surface.ui)
                                height: width
                                source: card.modelData.icon
                                sourceSize.width: width
                                sourceSize.height: height
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                smooth: true
                            }

                            Column {
                                anchors.left: appIcon.right
                                anchors.leftMargin: Math.round(9 * surface.ui)
                                anchors.right: parent.right
                                anchors.rightMargin: surface.inner
                                anchors.verticalCenter: appIcon.verticalCenter
                                spacing: Math.round(1 * surface.ui)

                                Text {
                                    width: parent.width
                                    textFormat: Text.PlainText
                                    text: card.modelData.appName
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    font.family: Style.font.family
                                    font.pixelSize: Math.max(11, Math.round(14 * surface.ui))
                                    font.weight: Font.DemiBold
                                    color: card.selected ? Color.foreground : root.fgA(0.78)
                                }

                                Text {
                                    width: parent.width
                                    textFormat: Text.PlainText
                                    text: card.modelData.title
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    font.family: Style.font.family
                                    font.pixelSize: Math.max(10, Math.round(12 * surface.ui))
                                    color: root.fgA(card.selected ? 0.72 : 0.5)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: root.open
                                // Only real movement selects, so opening under
                                // a resting pointer changes nothing.
                                onPositionChanged: mouse => {
                                    if (!root.pointerPrimed) {
                                        const p = mapToItem(null, mouse.x, mouse.y);
                                        if (root.pointerX0 < 0) {
                                            root.pointerX0 = p.x;
                                            root.pointerY0 = p.y;
                                            return;
                                        }
                                        if (Math.abs(p.x - root.pointerX0) + Math.abs(p.y - root.pointerY0) < 10)
                                            return;
                                        root.pointerPrimed = true;
                                    }
                                    if (root.index !== card.index) {
                                        root.glide = true;
                                        root.index = card.index;
                                    }
                                }
                                onClicked: {
                                    root.index = card.index;
                                    root.commit();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
