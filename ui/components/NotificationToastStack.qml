pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Column {
    id: root

    required property var notifications
    property var settings: null
    property bool suppressed: false
    property bool reducedMotion: false

    spacing: Tokens.spaceXs
    width: Tokens.notificationCenterWidth
    visible: !suppressed && notifications && notifications.available && !notifications.dnd && notifications.popupItems.length > 0

    readonly property var visiblePopups: {
        var src = (notifications && notifications.popupItems) ? notifications.popupItems : []
        var maxCount = settings ? Math.max(1, Math.min(5, settings.toastMaxVisible)) : 3
        return src.slice(0, maxCount)
    }

    Repeater {
        model: root.visiblePopups
        delegate: Rectangle {
            id: toastDel
            required property var modelData
            readonly property bool isCritical: toastDel.modelData.urgency === "critical"

            width: root.width
            implicitHeight: tCol.implicitHeight + Tokens.spaceSm * 2
            height: implicitHeight
            color: toastDel.isCritical ? Tokens.alertSurface : Tokens.surface
            border.width: Tokens.borderWidth
            border.color: toastDel.isCritical ? Tokens.alert : Tokens.signal

            ColumnLayout {
                id: tCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.space2xs

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    Text {
                        text: toastDel.modelData.appName
                        color: toastDel.isCritical ? Tokens.alert : Tokens.signal
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    TacticalButton {
                        text: ""
                        iconName: "close"
                        variant: "ghost"
                        implicitWidth: 20
                        implicitHeight: 20
                        reducedMotion: root.reducedMotion
                        onClicked: root.notifications.dismissPopup(toastDel.modelData.id)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: toastDel.modelData.summary
                    color: Tokens.text
                    font.family: Tokens.fontUi
                    font.pixelSize: Tokens.fontBody
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    visible: toastDel.modelData.body !== ""
                    Layout.fillWidth: true
                    text: toastDel.modelData.body
                    color: Tokens.muted
                    font.family: Tokens.fontUi
                    font.pixelSize: Tokens.fontMicro
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }
}

