pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string code: ""
    property string title: ""
    property string statusText: ""
    property string statusTone: "signal" // "signal" | "neutral" | "alert" | "warning" | "muted"
    property bool alertState: false
    property bool availableState: true
    property bool showCornerTicks: true
    property int contentPadding: Tokens.spaceMd

    default property alias bodyContent: bodyHost.data

    readonly property bool hasHeader: code !== "" || title !== "" || statusText !== ""
    readonly property int topBannerHeight: hasHeader ? 24 : 0

    implicitWidth: 280
    implicitHeight: topBannerHeight + layoutCol.implicitHeight + contentPadding * 2
    color: alertState ? Tokens.alertSurface : Tokens.surface
    border.width: Tokens.borderWidth
    border.color: alertState ? Tokens.alert : (availableState ? Tokens.borderStrong : Tokens.borderSubtle)
    radius: Tokens.cornerRadius

    // Full-Bleed Solid Marathon Top Header Band (+  CODE // STATUS  + with 2x2 pixel matrix)
    Rectangle {
        id: fullBleedBanner
        visible: root.hasHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.topBannerHeight
        color: root.alertState ? Tokens.alert : (root.availableState ? Tokens.signal : Tokens.surfacePressed)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.spaceSm
            anchors.rightMargin: Tokens.spaceSm
            spacing: Tokens.spaceSm

            // Left registration crosshair (+) from Marathon EXFILTRATED / Contract headers
            Text {
                text: "+"
                color: root.availableState || root.alertState ? Tokens.textOnSignal : Tokens.muted
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontBody
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: root.code !== "" ? root.code : root.title
                color: root.availableState || root.alertState ? Tokens.textOnSignal : Tokens.muted
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: true
                elide: Text.ElideRight
            }

            // 2x2 Pixel-Matrix Dither Cluster (from Marathon Vault/Implant item headers)
            Grid {
                columns: 2
                spacing: 2
                Repeater {
                    model: 4
                    delegate: Rectangle {
                        width: 3
                        height: 3
                        color: root.availableState || root.alertState ? Tokens.textOnSignal : Tokens.muted
                    }
                }
            }

            Text {
                text: "+"
                color: root.availableState || root.alertState ? Tokens.textOnSignal : Tokens.muted
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontBody
                font.bold: true
            }
        }
    }

    // Bottom corner target brackets
    Rectangle {
        visible: root.showCornerTicks
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Tokens.spaceSm
        height: Tokens.borderWidth * 2
        color: root.alertState ? Tokens.alert : Tokens.signal
    }
    Rectangle {
        visible: root.showCornerTicks
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Tokens.borderWidth * 2
        height: Tokens.spaceSm
        color: root.alertState ? Tokens.alert : Tokens.signal
    }
    Rectangle {
        visible: root.showCornerTicks
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: Tokens.spaceSm
        height: Tokens.borderWidth * 2
        color: root.alertState ? Tokens.alert : Tokens.borderStrong
    }
    Rectangle {
        visible: root.showCornerTicks
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: Tokens.borderWidth * 2
        height: Tokens.spaceSm
        color: root.alertState ? Tokens.alert : Tokens.borderStrong
    }

    ColumnLayout {
        id: layoutCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: root.topBannerHeight + root.contentPadding
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.contentPadding
        anchors.bottomMargin: root.contentPadding
        spacing: Tokens.spaceSm

        RowLayout {
            visible: root.title !== "" || root.statusText !== ""
            Layout.fillWidth: true
            spacing: Tokens.spaceSm

            Text {
                visible: root.title !== ""
                Layout.fillWidth: true
                text: root.title
                color: root.availableState ? Tokens.text : Tokens.muted
                font.family: Tokens.fontUi
                font.pixelSize: Tokens.fontTitle
                font.bold: true
                elide: Text.ElideRight
            }

            // Stepped 2-row Pixel-Checkerboard Decal (from Marathon Grey Decal Sheet & Contracts UI)
            Canvas {
                id: checkerDecal
                visible: root.title !== ""
                Layout.preferredWidth: 44
                Layout.preferredHeight: 10
                Connections {
                    target: Tokens
                    function onFactionIdChanged() { checkerDecal.requestPaint() }
                }
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)
                    ctx.fillStyle = (root.alertState ? Tokens.alert : Tokens.borderStrong).toString()
                    for (var i = 0; i < 8; ++i) {
                        var y = (i % 2 === 0) ? 0 : 5
                        ctx.fillRect(i * 5, y, 5, 4)
                    }
                }
            }

            StatusPill {
                visible: root.statusText !== ""
                text: root.statusText
                tone: root.alertState ? "alert" : root.statusTone
            }
        }

        HudDivider {
            visible: root.title !== "" || root.statusText !== ""
            Layout.fillWidth: true
            withTicks: true
            lineColor: root.alertState ? Tokens.alert : Tokens.border
        }

        ColumnLayout {
            id: bodyHost
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Tokens.spaceSm
        }
    }
}
