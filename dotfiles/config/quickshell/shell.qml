import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

ShellRoot {
    id: root

    property string barStyle: "islands"

    Process {
        id: styleReader
        command: ["sh", "-c", "cat \"$HOME/.cache/pwnbox/theme/barstyle\" 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const s = this.text.trim();
                if (s.length > 0)
                    root.barStyle = s;
            }
        }
    }

    IpcHandler {
        target: "barstyle"

        function set(name: string) {
            root.barStyle = name;
        }

        function get(): string {
            return root.barStyle;
        }
    }

    Variants {
        model: Quickshell.screens
        Bar { barStyle: root.barStyle }
    }

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        bodyMarkupSupported: false
        onNotification: notification => {
            notification.tracked = true;
        }
    }

    NotificationOverlay {
        server: notifServer
    }

    VolumeOsd {}
    PowerMenu { barStyle: root.barStyle }
    CalendarPanel { barStyle: root.barStyle }
    SystemPanel { barStyle: root.barStyle }
    // The panels of the "noir" bar: Bluetooth, sound, network.
    NoirPanels {}
}
