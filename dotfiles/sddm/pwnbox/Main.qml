// The login screen. Its wallpaper, colours, font and corner radius come from the
// palette pwnbox-theme drops in /var/lib/pwnbox-greeter; theme.conf holds the
// fallbacks used before the first theme sync.
import QtQuick
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: cBg

    // ---- palette -----------------------------------------------------------

    // The palette is a QML object pwnbox-theme writes into dropDir. QML cannot
    // read a plain file without QML_XHR_ALLOW_FILE_READ, which sddm has no way
    // to set, so the drop is loaded as a component instead. Missing or broken,
    // the fallbacks in theme.conf are used.
    function loadDrop() {
        try {
            var c = Qt.createComponent("file://" + root.dropDir + "/Palette.qml");
            if (c.status === Component.Ready)
                root.drop = c.createObject(root);
        } catch (e) {
        }
        fadeIn.start();
        riseIn.start();
    }

    function pick(key, fallback) {
        return (drop && drop[key] !== undefined && drop[key] !== "") ? drop[key] : fallback;
    }

    readonly property string dropDir: config.dropDir ? config.dropDir : "/var/lib/pwnbox-greeter"
    property var drop: null

    readonly property color cBg: pick("bg", config.bg)
    readonly property color cField: pick("field", config.field)
    readonly property color cFg: pick("fg", config.fg)
    readonly property color cDim: pick("dim", config.dim)
    readonly property color cOutline: pick("outline", config.outline)
    readonly property string uiFont: pick("font", config.font)
    readonly property string iconFont: pick("fontIcons", config.fontIcons)
    readonly property int uiRadius: parseInt(pick("rounding", config.rounding))
    readonly property string wallPath: pick("wallpaper", "")
    readonly property string facePath: dropDir + "/avatar.png"

    // SDDM opens one window per screen; only the primary one carries the stack.
    readonly property bool isPrimary: (typeof primaryScreen !== "undefined") ? primaryScreen : true

    // ---- state -------------------------------------------------------------

    property date now: new Date()
    property string msg: ""
    property bool msgIsError: false
    property var sessionNames: []
    property int sessionIndex: sessionModel.lastIndex
    readonly property string sessionName: (sessionIndex >= 0 && sessionIndex < sessionNames.length) ? sessionNames[sessionIndex] : ""
    // sddm fills userModel.lastUser only after its own first successful login, so
    // on a fresh install (and on the first boot after switching from ly) it is an
    // empty string and sddm.login("") can never succeed. There is no username
    // field to fall back on, so take the name from the model instead
    // (Qt.UserRole + 1 is sddm's NameRole).
    readonly property string userName: {
        if (userModel.lastUser !== "")
            return userModel.lastUser;
        if (userModel.count > 0)
            return userModel.data(userModel.index(Math.max(0, userModel.lastIndex), 0), Qt.UserRole + 1) || "";
        return "";
    }

    function doLogin() {
        msg = "";
        sddm.login(root.userName, pw.text, root.sessionIndex);
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Repeater {
        model: sessionModel
        delegate: Item {
            required property int index
            required property string name
            Component.onCompleted: {
                var a = root.sessionNames.slice();
                a[index] = name;
                root.sessionNames = a;
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.msg = "Wrong password";
            root.msgIsError = true;
            pw.text = "";
            pw.forceActiveFocus();
            shake.restart();
        }
        function onLoginSucceeded() {
            root.msg = "";
            root.msgIsError = false;
        }
        function onInformationMessage(message) {
            root.msg = message;
            root.msgIsError = true;
        }
    }

    // ---- background --------------------------------------------------------

    Image {
        id: wall
        anchors.fill: parent
        source: root.wallPath !== "" ? "file://" + root.wallPath : ""
        fillMode: Image.PreserveAspectCrop
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wall
        visible: wall.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 40
    }

    // Keeps the stack legible on a light wallpaper; the lock screen leans on
    // the blur alone, but a login screen has to work on whatever is set.
    Rectangle {
        anchors.fill: parent
        color: root.cBg
        opacity: wall.status === Image.Ready ? 0.22 : 0
    }

    // ---- centre stack ------------------------------------------------------

    Item {
        id: stack
        anchors.fill: parent
        visible: root.isPrimary
        opacity: 0
        transform: Translate {
            id: rise
            y: 14
        }

        NumberAnimation {
            id: fadeIn
            target: stack
            property: "opacity"
            to: 1
            duration: 420
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: riseIn
            target: rise
            property: "y"
            to: 0
            duration: 520
            easing.type: Easing.OutCubic
        }

        // avatar
        Item {
            id: avatarBox
            width: 112
            height: 112
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -224

            Image {
                id: face
                anchors.fill: parent
                source: "file://" + root.facePath
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 192
                sourceSize.height: 192
                cache: false
                visible: false
                onStatusChanged: if (status === Image.Error)
                    source = "avatar.png"
            }

            Rectangle {
                id: faceMask
                anchors.fill: parent
                radius: width / 2
                color: "black"
                visible: false
                layer.enabled: true
            }

            MultiEffect {
                anchors.fill: parent
                source: face
                visible: face.status === Image.Ready
                maskEnabled: true
                maskSource: faceMask
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: face.status === Image.Ready ? "transparent" : root.cField
                border.width: 2
                border.color: root.cOutline
            }

            Text {
                anchors.centerIn: parent
                visible: face.status !== Image.Ready
                text: root.userName.length > 0 ? root.userName.charAt(0).toUpperCase() : "?"
                color: root.cFg
                font.family: root.uiFont
                font.pixelSize: 38
            }
        }

        // time
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -120
            text: Qt.formatTime(root.now, "HH:mm")
            color: root.cFg
            font.family: root.uiFont
            font.pixelSize: 56
        }

        // date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -70
            text: Qt.formatDate(root.now, "dddd, dd MMMM yyyy")
            color: root.cDim
            font.family: root.uiFont
            font.pixelSize: 16
        }

        // password field
        Rectangle {
            id: field
            width: 320
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: root.cField
            radius: root.uiRadius
            border.width: 2
            border.color: root.cOutline

            transform: Translate {
                id: nudge
            }
            SequentialAnimation {
                id: shake
                NumberAnimation {
                    target: nudge
                    property: "x"
                    to: -9
                    duration: 55
                }
                NumberAnimation {
                    target: nudge
                    property: "x"
                    to: 9
                    duration: 90
                }
                NumberAnimation {
                    target: nudge
                    property: "x"
                    to: -5
                    duration: 80
                }
                NumberAnimation {
                    target: nudge
                    property: "x"
                    to: 0
                    duration: 70
                }
            }

            TextInput {
                id: pw
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                echoMode: TextInput.Password
                passwordCharacter: "•"
                passwordMaskDelay: 0
                cursorVisible: text.length > 0
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                color: root.cFg
                font.family: root.uiFont
                font.pixelSize: 16
                selectionColor: root.cOutline
                selectedTextColor: root.cFg
                focus: true
                onAccepted: root.doLogin()
                onTextChanged: if (root.msg !== "") {
                    root.msg = "";
                    root.msgIsError = false;
                }
            }

            Text {
                anchors.centerIn: parent
                visible: pw.text.length === 0
                text: "Password..."
                color: root.cDim
                font.family: root.uiFont
                font.pixelSize: 16
                font.italic: true
            }
        }

        // session picker
        Item {
            id: sessionRow
            width: sessionLabel.width + chevron.width + 8 + 20
            height: 24
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 60
            visible: sessionModel.count > 0

            readonly property color tint: (sessionArea.containsMouse || sessionMenu.visible) ? root.cFg : root.cDim

            Text {
                id: sessionLabel
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -(chevron.width + 8) / 2
                text: root.sessionName
                color: sessionRow.tint
                font.family: root.uiFont
                font.pixelSize: 13
                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }
            }

            Text {
                id: chevron
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: sessionLabel.right
                anchors.leftMargin: 8
                text: "\uf078"
                color: sessionRow.tint
                font.family: root.iconFont
                font.pixelSize: 9
                rotation: sessionMenu.visible ? 180 : 0
                Behavior on rotation {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }
            }

            MouseArea {
                id: sessionArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sessionMenu.visible = !sessionMenu.visible
            }
        }

        // message / caps lock
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 104
            text: root.msg !== "" ? root.msg : (keyboard.capsLock ? "Caps Lock is on" : "")
            color: root.msgIsError ? root.cFg : root.cDim
            font.family: root.uiFont
            font.pixelSize: 13
            opacity: text !== "" ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }
        }

        // session list, opened from the picker
        Rectangle {
            id: sessionMenu
            visible: false
            width: 240
            height: Math.min(sessionModel.count * 30 + 12, 220)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 84 + height / 2
            color: root.cField
            radius: root.uiRadius
            border.width: 2
            border.color: root.cOutline

            ListView {
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                model: sessionModel
                delegate: Item {
                    required property int index
                    required property string name
                    width: ListView.view.width
                    height: 30

                    Rectangle {
                        anchors.fill: parent
                        radius: Math.max(0, root.uiRadius - 2)
                        color: root.cOutline
                        opacity: (hover.containsMouse || index === root.sessionIndex) ? 0.22 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: name
                        color: (hover.containsMouse || index === root.sessionIndex) ? root.cFg : root.cDim
                        font.family: root.uiFont
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.sessionIndex = index;
                            sessionMenu.visible = false;
                            pw.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }

    // ---- power -------------------------------------------------------------

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 30
        anchors.bottomMargin: 26
        spacing: 20
        visible: root.isPrimary
        opacity: stack.opacity

        Repeater {
            model: [
                {
                    glyph: "",
                    act: "suspend",
                    on: sddm.canSuspend
                },
                {
                    glyph: "",
                    act: "reboot",
                    on: sddm.canReboot
                },
                {
                    glyph: "",
                    act: "poweroff",
                    on: sddm.canPowerOff
                }
            ]
            delegate: Item {
                required property var modelData
                width: 28
                height: 28
                visible: modelData.on

                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    color: pma.containsMouse ? root.cFg : root.cDim
                    font.family: root.iconFont
                    font.pixelSize: 15
                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }
                }
                MouseArea {
                    id: pma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.act === "suspend")
                            sddm.suspend();
                        else if (modelData.act === "reboot")
                            sddm.reboot();
                        else
                            sddm.powerOff();
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        pw.forceActiveFocus();
        loadDrop();
    }
}
