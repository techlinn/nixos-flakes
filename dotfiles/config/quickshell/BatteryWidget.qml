import QtQuick
import Quickshell.Services.UPower
import "Theme.js" as Theme

Row {
    id: root
    spacing: 5

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.isLaptopBattery
    readonly property real pct: present ? (dev.percentage || 0) : 0
    readonly property bool charging: present && dev.state === UPowerDeviceState.Charging

    visible: present

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.charging ? Theme.iconCharging
                            : (root.pct > 0.5 ? Theme.iconBattery : Theme.iconBatteryHalf)
        color: Theme.fgDim
        font.family: Theme.fontIcons
        font.pixelSize: Theme.fontSize
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.pct * 100) + "%"
        color: Theme.fgDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
