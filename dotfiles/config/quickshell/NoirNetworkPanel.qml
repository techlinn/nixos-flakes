// Network: the wired connection, the Wi-Fi switch and the networks in range.
// Click a network to join it; a new protected one asks for its password.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "Theme.js" as Theme

Column {
    id: root
    width: parent ? parent.width : 300
    spacing: 10

    readonly property var devices: Networking.devices ? Networking.devices.values : []
    readonly property var wired: devices.filter(d => d.type === DeviceType.Wired)
    readonly property var wifi: devices.filter(d => d.type === DeviceType.Wifi)
    readonly property bool hasWifi: wifi.length > 0 || Networking.wifiHardwareEnabled

    // Networks of every Wi-Fi adapter, strongest first, the joined one on top.
    readonly property var networks: {
        let all = [];
        for (let i = 0; i < wifi.length; i++)
            if (wifi[i].networks)
                all = all.concat(wifi[i].networks.values);
        return all.sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength)).slice(0, 8);
    }

    // The network whose password is being typed.
    property var asking: null

    // IPv4 addresses, which the network service does not report: "eth0 192.168.1.20".
    property var addresses: ({})
    Process {
        running: true
        command: ["sh", "-c", "ip -4 -o addr show scope global 2>/dev/null | awk '{split($4, a, \"/\"); print $2, a[1]}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                const lines = this.text.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(" ");
                    if (parts.length === 2)
                        map[parts[0]] = parts[1];
                }
                root.addresses = map;
            }
        }
    }

    // Look for networks only while the panel is open.
    Component.onCompleted: {
        for (let i = 0; i < wifi.length; i++)
            wifi[i].scannerEnabled = true;
    }
    Component.onDestruction: {
        for (let i = 0; i < wifi.length; i++)
            wifi[i].scannerEnabled = false;
    }

    component Title: Text {
        color: Theme.fgFaint
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 1
        font.capitalization: Font.AllUppercase
    }

    function bars(strength) {
        return strength > 0.75 ? "󰤨" : strength > 0.5 ? "󰤥" : strength > 0.25 ? "󰤢" : "󰤟";
    }

    Title { text: "Wired"; visible: root.wired.length > 0 }
    Repeater {
        model: root.wired
        delegate: Item {
            id: cable
            required property var modelData
            width: root.width
            height: 34
            Text {
                x: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "󰌗"
                font.family: Theme.fontIcons
                font.pixelSize: 14
                color: cable.modelData.connected ? NoirState.accent : Theme.fgFaint
            }
            Column {
                x: 28
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: cable.modelData.name
                    color: cable.modelData.connected ? Theme.fg : Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
                Text {
                    text: !cable.modelData.connected ? (cable.modelData.hasLink ? "Not connected" : "Cable unplugged")
                        : ((root.addresses[cable.modelData.name] || "Connected")
                           + (cable.modelData.linkSpeed > 0 ? " · " + (cable.modelData.linkSpeed >= 1000 ? (cable.modelData.linkSpeed / 1000) + " Gbit/s" : cable.modelData.linkSpeed + " Mbit/s") : ""))
                    color: cable.modelData.connected ? NoirState.accent : Theme.fgFaint
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: NoirState.line; visible: root.wired.length > 0 }

    Item {
        width: parent.width
        height: 22
        Title {
            anchors.verticalCenter: parent.verticalCenter
            text: "Wi-Fi"
        }
        Text {
            anchors.right: wifiSwitch.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.hasWifi
            text: "no adapter"
            color: Theme.fgFaint
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
        NoirSwitch {
            id: wifiSwitch
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            on: Networking.wifiEnabled
            available: root.hasWifi
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    Text {
        visible: root.hasWifi && Networking.wifiEnabled && root.networks.length === 0
        text: "Looking for networks…"
        color: Theme.fgFaint
        font.family: Theme.fontFamily
        font.pixelSize: 11
    }

    Column {
        width: parent.width
        spacing: 1
        visible: Networking.wifiEnabled
        Repeater {
            model: root.networks
            delegate: Column {
                id: net
                required property var modelData
                readonly property bool open: modelData.security === WifiSecurityType.Open
                readonly property bool asking: root.asking === modelData
                width: parent.width

                Rectangle {
                    width: parent.width
                    height: 30
                    radius: Math.min(Theme.radius, 6)
                    color: netArea.containsMouse ? NoirState.hover : "transparent"

                    Text {
                        x: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.bars(net.modelData.signalStrength)
                        font.family: Theme.fontIcons
                        font.pixelSize: 14
                        color: net.modelData.connected ? NoirState.accent : Theme.fgFaint
                    }
                    Text {
                        x: 28
                        width: parent.width - 28 - state.implicitWidth - 12
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        text: net.modelData.name
                        color: net.modelData.connected ? Theme.fg : Theme.fgDim
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        id: state
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: net.modelData.stateChanging ? "…" : net.modelData.connected ? "Connected" : net.modelData.known ? "Saved" : (net.open ? "Open" : "")
                        font.family: (!net.modelData.stateChanging && !net.modelData.connected && !net.modelData.known && !net.open) ? Theme.fontIcons : Theme.fontFamily
                        color: net.modelData.connected ? NoirState.accent : Theme.fgFaint
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: netArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const n = net.modelData;
                            if (n.connected)
                                n.disconnect();
                            else if (n.known || net.open)
                                n.connect();
                            else
                                root.asking = net.asking ? null : n;
                        }
                    }
                }

                // Password field for a new protected network.
                Rectangle {
                    visible: net.asking
                    width: parent.width
                    height: visible ? 30 : 0
                    radius: Math.min(Theme.radius, 6)
                    color: "transparent"
                    border.width: 1
                    border.color: secret.activeFocus ? NoirState.accent : NoirState.line

                    TextInput {
                        id: secret
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        color: Theme.fg
                        selectionColor: NoirState.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        clip: true
                        onVisibleChanged: if (visible) forceActiveFocus()
                        onAccepted: {
                            if (text.length >= 8) {
                                net.modelData.connectWithPsk(text);
                                text = "";
                                root.asking = null;
                            }
                        }
                        Text {
                            visible: secret.text.length === 0
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Password, then Enter"
                            color: Theme.fgFaint
                            font: secret.font
                        }
                    }
                }
            }
        }
    }
}
