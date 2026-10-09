// Bluetooth: the switch, a scan button and the devices. Click a device to
// connect or disconnect it (an unknown one is paired first).
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "Theme.js" as Theme

Column {
    id: root
    width: parent ? parent.width : 300
    spacing: 10

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter !== null && adapter.enabled
    // Connected first, then the ones this computer knows, then the rest.
    readonly property var devices: {
        if (!adapter || !adapter.devices)
            return [];
        const rank = d => d.connected ? 0 : (d.paired || d.trusted ? 1 : 2);
        return adapter.devices.values.slice().sort((a, b) => {
            const r = rank(a) - rank(b);
            return r !== 0 ? r : String(a.name || a.deviceName).localeCompare(String(b.name || b.deviceName));
        });
    }

    // Stop scanning when the panel goes away.
    Component.onDestruction: {
        if (adapter && adapter.discovering)
            adapter.discovering = false;
    }

    Item {
        width: parent.width
        height: 22
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: !root.adapter ? "No Bluetooth adapter" : (root.on ? "On" : "Off")
            color: Theme.fgDim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
        NoirSwitch {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            on: root.on
            available: root.adapter !== null
            onToggled: root.adapter.enabled = !root.adapter.enabled
        }
    }

    Rectangle { width: parent.width; height: 1; color: NoirState.line; visible: root.on }

    Item {
        width: parent.width
        height: 18
        visible: root.on
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Devices"
            color: Theme.fgFaint
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: Font.DemiBold
            font.letterSpacing: 1
            font.capitalization: Font.AllUppercase
        }
        Text {
            id: scan
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.adapter && root.adapter.discovering ? "Scanning…  stop" : "Scan"
            color: scanArea.containsMouse ? Theme.fg : NoirState.accent
            font.family: Theme.fontFamily
            font.pixelSize: 11
            MouseArea {
                id: scanArea
                anchors.fill: parent
                anchors.margins: -5
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.adapter.discovering = !root.adapter.discovering
            }
        }
    }

    Text {
        visible: root.on && root.devices.length === 0
        text: "No devices yet. Press Scan and put the device in pairing mode."
        width: parent.width
        wrapMode: Text.WordWrap
        color: Theme.fgFaint
        font.family: Theme.fontFamily
        font.pixelSize: 11
    }

    Column {
        width: parent.width
        spacing: 1
        visible: root.on
        Repeater {
            model: root.devices
            delegate: Rectangle {
                id: row
                required property var modelData
                readonly property bool busy: modelData.pairing
                    || modelData.state === BluetoothDeviceState.Connecting
                    || modelData.state === BluetoothDeviceState.Disconnecting
                readonly property string status: modelData.pairing ? "Pairing…"
                    : modelData.state === BluetoothDeviceState.Connecting ? "Connecting…"
                    : modelData.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                    : modelData.connected ? (modelData.batteryAvailable ? "Connected · " + Math.round(modelData.battery * 100) + "%" : "Connected")
                    : (modelData.paired ? "Paired" : "New")

                width: parent.width
                height: 34
                radius: Math.min(Theme.radius, 6)
                color: rowArea.containsMouse ? NoirState.hover : "transparent"

                Text {
                    x: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.connected ? "󰂱" : "󰂯"
                    font.family: Theme.fontIcons
                    font.pixelSize: 14
                    color: row.modelData.connected ? NoirState.accent : Theme.fgFaint
                }
                Column {
                    x: 28
                    width: parent.width - 34
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: row.modelData.name || row.modelData.deviceName || row.modelData.address
                        color: row.modelData.connected ? Theme.fg : Theme.fgDim
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        text: row.status
                        color: row.modelData.connected ? NoirState.accent : Theme.fgFaint
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !row.busy
                    onClicked: {
                        const d = row.modelData;
                        if (d.connected)
                            d.disconnect();
                        else if (d.paired || d.trusted)
                            d.connect();
                        else
                            d.pair();
                    }
                }
            }
        }
    }
}
