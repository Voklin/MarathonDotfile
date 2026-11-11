pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var utilities
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()
    signal openClipboardRequested()

    property bool annotateAfterCapture: false

    onOpenChanged: {
        if (open) captureCard.forceActiveFocus()
    }

    Keys.onEscapePressed: function(event) {
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    visible: open || capReveal.opacity > 0.01

    Rectangle {
        anchors.fill: parent
        color: Tokens.surfaceOverlay
        opacity: root.open ? 0.68 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion) }
        }
        MouseArea {
            anchors.fill: parent
            enabled: root.open
            onClicked: root.closeRequested()
        }
    }

    PanelReveal {
        id: capReveal
        anchors.centerIn: parent
        width: Math.min(Tokens.captureWidth, parent.width - Tokens.spaceXl)
        height: Math.min(Tokens.captureHeight, parent.height - Tokens.spaceXl)
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea { anchors.fill: captureCard }

        TacticalPanel {
            id: captureCard
            anchors.fill: parent
            focus: true
            code: "OPTICS // CAPTURE SUITE"
            title: "SCREENSHOT, SATTY & COLOR PICKER"
            statusText: (root.utilities && root.utilities.captureBusy)
                ? "CAPTURING..."
                : ((root.utilities && root.utilities.captureAvailable) ? "GRIM READY" : "NO GRIM")
            statusTone: (root.utilities && root.utilities.captureAvailable) ? "signal" : "warning"

            TacticalToggle {
                Layout.fillWidth: true
                label: "Annotate After Capture (Satty Editor)"
                sublabel: root.annotateAfterCapture
                    ? "OPENS CAPTURE IN SATTY FOR ARROWS, BLUR & TEXT"
                    : "SAVES DIRECTLY TO ~/Pictures/Screenshots & CLIPBOARD"
                iconName: "capture"
                checked: root.annotateAfterCapture
                reducedMotion: root.reducedMotion
                onToggled: function(next) { root.annotateAfterCapture = next }
            }

            // 4 primary action tiles
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Tokens.spaceSm
                rowSpacing: Tokens.spaceSm

                TacticalButton {
                    Layout.fillWidth: true
                    text: "SELECT REGION (SLURP)"
                    iconName: "capture"
                    variant: "primary"
                    enabledState: root.utilities && root.utilities.captureAvailable && !root.utilities.captureBusy
                    implicitHeight: 44
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        if (root.utilities) root.utilities.captureRegion(root.annotateAfterCapture)
                        root.closeRequested()
                    }
                }

                TacticalButton {
                    Layout.fillWidth: true
                    text: "ACTIVE WINDOW"
                    iconName: "grid"
                    enabledState: root.utilities && root.utilities.captureAvailable && !root.utilities.captureBusy
                    implicitHeight: 44
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        if (root.utilities) root.utilities.captureWindow(root.annotateAfterCapture)
                        root.closeRequested()
                    }
                }

                TacticalButton {
                    Layout.fillWidth: true
                    text: "FULLSCREEN OUTPUT"
                    iconName: "capture"
                    enabledState: root.utilities && root.utilities.captureAvailable && !root.utilities.captureBusy
                    implicitHeight: 44
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        if (root.utilities) root.utilities.captureFullscreen(root.annotateAfterCapture)
                        root.closeRequested()
                    }
                }

                TacticalButton {
                    Layout.fillWidth: true
                    text: "COLOR PICKER (HEX)"
                    iconName: "palette"
                    enabledState: root.utilities && root.utilities.pickerAvailable
                    implicitHeight: 44
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        if (root.utilities) root.utilities.pickColor()
                    }
                }
            }

            // Last picked color banner
            Rectangle {
                visible: root.utilities && root.utilities.lastPickedColor !== ""
                Layout.fillWidth: true
                height: 40
                color: Tokens.surfacePressed
                border.width: Tokens.borderWidth
                border.color: Tokens.borderStrong

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Tokens.spaceSm
                    anchors.rightMargin: Tokens.spaceSm
                    spacing: Tokens.spaceSm

                    Rectangle {
                        width: 24
                        height: 24
                        color: (root.utilities && Tokens.isValidHexColor(root.utilities.lastPickedColor))
                            ? root.utilities.lastPickedColor
                            : Tokens.signal
                        border.width: Tokens.borderWidth
                        border.color: Tokens.text
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "LAST SAMPLED HEX // " + (root.utilities ? root.utilities.lastPickedColor : "")
                        color: Tokens.text
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontLabel
                        font.bold: true
                    }

                    TacticalButton {
                        text: "COPY HEX"
                        variant: "primary"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.reducedMotion
                        onClicked: if (root.utilities) root.utilities.copyText(root.utilities.lastPickedColor)
                    }
                }
            }

            // Recent captures archive
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Tokens.background
                border.width: Tokens.borderWidth
                border.color: Tokens.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.spaceSm
                    spacing: Tokens.spaceXs

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: "RECENT CAPTURE LOG"
                            color: Tokens.signal
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                            font.bold: true
                        }
                        Text {
                            text: (root.utilities && root.utilities.recentCaptures ? root.utilities.recentCaptures.length : 0) + " FILES"
                            color: Tokens.muted
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                        }
                    }

                    EmptyState {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !(root.utilities && root.utilities.recentCaptures && root.utilities.recentCaptures.length > 0)
                        code: "NO CAPTURES"
                        title: "SCREENSHOT LOG EMPTY"
                        detail: "USE REGION, WINDOW, OR FULLSCREEN TO SAVE SCREENSHOTS"
                        iconName: "capture"
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.utilities && root.utilities.recentCaptures && root.utilities.recentCaptures.length > 0
                        model: root.utilities ? root.utilities.recentCaptures : []
                        clip: true
                        spacing: 4

                        delegate: Rectangle {
                            id: capDel
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            height: 36
                            color: (capDel.index % 2 === 0) ? Tokens.surfaceZebra : Tokens.surfacePressed
                            border.width: Tokens.borderWidth
                            border.color: Tokens.borderSubtle

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Tokens.spaceSm
                                anchors.rightMargin: Tokens.spaceXs
                                spacing: Tokens.spaceSm

                                StatusPill {
                                    text: capDel.modelData.mode || "PNG"
                                    tone: "signal"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: capDel.modelData.name || capDel.modelData.path
                                    color: Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    elide: Text.ElideMiddle
                                }

                                Text {
                                    text: capDel.modelData.timestamp || ""
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                }

                                TacticalButton {
                                    text: "COPY PATH"
                                    implicitHeight: 22
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.copyText(capDel.modelData.path)
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                Text {
                    Layout.fillWidth: true
                    text: root.utilities ? root.utilities.statusNote : ""
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideRight
                }

                TacticalButton {
                    text: "CLIPBOARD"
                    iconName: "clipboard"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.openClipboardRequested()
                }

                TacticalButton {
                    text: "CLOSE"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.closeRequested()
                }
            }
        }
    }
}
