pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Item {
    id: root

    property string runnerName: Tokens.runnerName
    property string runnerTitle: Tokens.runnerTitle
    property bool compact: false
    property bool showSelector: false
    property bool reducedMotion: false

    signal emblemSelected(string emblemId)
    signal nameEdited(string nextName)
    signal titleEdited(string nextTitle)

    readonly property var emblemData: Tokens.activeEmblem

    implicitWidth: compact ? compactRow.implicitWidth : 340
    implicitHeight: compact ? Tokens.controlHeightSm : fullCol.implicitHeight

    // COMPACT MODE: Top-left HUD badge ([● NAME] + [TITLE])
    Row {
        id: compactRow
        visible: root.compact
        height: Tokens.controlHeightSm
        spacing: 2

        // Solid signal emblem + name block (left)
        Rectangle {
            width: nameRow.implicitWidth + Tokens.spaceSm * 2
            height: Tokens.controlHeightSm
            radius: Tokens.cornerRadius
            color: Tokens.signal
            border.width: Tokens.borderWidth
            border.color: Tokens.signal

            Row {
                id: nameRow
                anchors.centerIn: parent
                spacing: Tokens.spaceXs

                Canvas {
                    id: miniGlyph
                    width: 12
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Connections {
                        target: Tokens
                        function onEmblemIdChanged() { miniGlyph.requestPaint() }
                        function onFactionIdChanged() { miniGlyph.requestPaint() }
                    }
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = Tokens.textOnSignal.toString()
                        ctx.fillStyle = Tokens.textOnSignal.toString()
                        ctx.lineWidth = 1.6
                        var m = root.emblemData.motif
                        if (m === "bowtie" || m === "checker") {
                            ctx.beginPath()
                            ctx.moveTo(1, 2)
                            ctx.lineTo(6, 6)
                            ctx.lineTo(1, 10)
                            ctx.closePath()
                            ctx.fill()
                            ctx.beginPath()
                            ctx.moveTo(11, 2)
                            ctx.lineTo(6, 6)
                            ctx.lineTo(11, 10)
                            ctx.closePath()
                            ctx.fill()
                        } else {
                            ctx.beginPath()
                            ctx.arc(6, 6, 4.5, 0, Math.PI * 2)
                            ctx.stroke()
                            ctx.fillRect(4.5, 4.5, 3, 3)
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (Tokens.runnerName || "RUNNER").toUpperCase()
                    color: Tokens.textOnSignal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Tokens.cycleEmblem()
                    root.emblemSelected(Tokens.emblemId)
                }
            }
        }

        // Custom Title block (right)
        Rectangle {
            width: compactTitleTxt.implicitWidth + Tokens.spaceSm * 2
            height: Tokens.controlHeightSm
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong

            Text {
                id: compactTitleTxt
                anchors.centerIn: parent
                text: (Tokens.runnerTitle || "OPERATOR").toUpperCase()
                color: Tokens.text
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Tokens.cycleEmblem()
                    root.emblemSelected(Tokens.emblemId)
                }
            }
        }
    }

    // FULL CALLING CARD & EMBLEM BANNER MODE (Emblem + Name + Custom Title)
    ColumnLayout {
        id: fullCol
        visible: !root.compact
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceXs

        Rectangle {
            id: bannerBox
            Layout.fillWidth: true
            height: 62
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong
            clip: true

            // Procedural Bungie Decal Artwork Backdrop (from Blue & Grey Decal Sheets)
            Canvas {
                id: decalCanvas
                anchors.fill: parent
                Connections {
                    target: Tokens
                    function onEmblemIdChanged() { decalCanvas.requestPaint() }
                    function onFactionIdChanged() { decalCanvas.requestPaint() }
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    var motif = root.emblemData.motif
                    ctx.strokeStyle = Tokens.borderStrong.toString()
                    ctx.fillStyle = Tokens.borderStrong.toString()
                    ctx.lineWidth = 1.5

                    // 4-corner registration crosshairs (+)
                    var corners = [[8, 8], [width - 8, 8], [8, height - 8], [width - 8, height - 8]]
                    for (var c = 0; c < corners.length; ++c) {
                        var px = corners[c][0]
                        var py = corners[c][1]
                        ctx.beginPath()
                        ctx.moveTo(px - 3, py)
                        ctx.lineTo(px + 3, py)
                        ctx.moveTo(px, py - 3)
                        ctx.lineTo(px, py + 3)
                        ctx.stroke()
                    }

                    // 2-row pixel checkerboard ribbon (signature Marathon decal)
                    var chkX = Math.max(160, width - 170)
                    for (var i = 0; i < 10; ++i) {
                        ctx.fillStyle = (i % 2 === 0) ? Tokens.signalMuted.toString() : Tokens.border.toString()
                        ctx.fillRect(chkX + i * 6, 8, 5, 5)
                        ctx.fillRect(chkX + ((i + 1) % 2) * 6 + i * 6, 14, 5, 5)
                    }

                    var rx = width - 52
                    var ry = height * 0.5 + 4
                    ctx.strokeStyle = Tokens.signal.toString()
                    ctx.fillStyle = Tokens.signal.toString()

                    if (motif === "cruciform") {
                        ctx.beginPath()
                        ctx.moveTo(rx, 8)
                        ctx.lineTo(rx, height - 8)
                        ctx.moveTo(rx - 18, ry - 10)
                        ctx.lineTo(rx + 18, ry - 10)
                        ctx.moveTo(rx - 12, ry - 2)
                        ctx.lineTo(rx + 12, ry - 2)
                        ctx.moveTo(rx - 22, ry + 6)
                        ctx.lineTo(rx + 22, ry + 6)
                        ctx.stroke()
                        ctx.fillRect(rx - 5, height - 16, 10, 8)
                    } else if (motif === "bowtie") {
                        ctx.beginPath()
                        ctx.moveTo(rx - 18, ry - 10)
                        ctx.lineTo(rx, ry)
                        ctx.lineTo(rx - 18, ry + 10)
                        ctx.closePath()
                        ctx.fill()
                        ctx.beginPath()
                        ctx.moveTo(rx + 18, ry - 10)
                        ctx.lineTo(rx, ry)
                        ctx.lineTo(rx + 18, ry + 10)
                        ctx.closePath()
                        ctx.fill()
                    } else if (motif === "hexcore") {
                        ctx.strokeRect(rx - 16, ry - 12, 32, 24)
                        ctx.fillRect(rx - 6, ry - 4, 12, 8)
                        ctx.beginPath()
                        ctx.moveTo(rx - 26, ry)
                        ctx.lineTo(rx + 26, ry)
                        ctx.stroke()
                    } else if (motif === "checker") {
                        for (var gx = 0; gx < 5; ++gx) {
                            for (var gy = 0; gy < 3; ++gy) {
                                if ((gx + gy) % 2 === 0) {
                                    ctx.fillRect(rx - 20 + gx * 8, ry - 12 + gy * 8, 6, 6)
                                }
                            }
                        }
                    } else if (motif === "orbit") {
                        ctx.beginPath()
                        ctx.arc(rx, ry, 13, 0, Math.PI * 1.5)
                        ctx.lineTo(rx, ry)
                        ctx.closePath()
                        ctx.fill()
                    } else {
                        ctx.strokeRect(rx - 26, ry - 9, 52, 18)
                        for (var p = -16; p <= 16; p += 10) {
                            ctx.beginPath()
                            ctx.moveTo(rx + p - 3, ry)
                            ctx.lineTo(rx + p + 3, ry)
                            ctx.moveTo(rx + p, ry - 3)
                            ctx.lineTo(rx + p, ry + 3)
                            ctx.stroke()
                        }
                    }
                }
            }

            // Left vertical signal bar
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 4
                color: Tokens.signal
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Tokens.spaceMd
                anchors.rightMargin: Tokens.spaceSm
                spacing: Tokens.spaceSm

                // Circular Emblem Medallion
                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 21
                    color: Tokens.background
                    border.width: 2
                    border.color: Tokens.signal

                    Canvas {
                        id: medallionGlyph
                        anchors.fill: parent
                        anchors.margins: 6
                        Connections {
                            target: Tokens
                            function onEmblemIdChanged() { medallionGlyph.requestPaint() }
                            function onFactionIdChanged() { medallionGlyph.requestPaint() }
                        }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.strokeStyle = Tokens.signal.toString()
                            ctx.fillStyle = Tokens.signal.toString()
                            ctx.lineWidth = 1.8
                            var cx = width * 0.5
                            var cy = height * 0.5
                            var m = root.emblemData.motif

                            if (m === "bowtie" || m === "checker") {
                                ctx.beginPath()
                                ctx.moveTo(3, 5)
                                ctx.lineTo(cx, cy)
                                ctx.lineTo(3, height - 5)
                                ctx.closePath()
                                ctx.fill()
                                ctx.beginPath()
                                ctx.moveTo(width - 3, 5)
                                ctx.lineTo(cx, cy)
                                ctx.lineTo(width - 3, height - 5)
                                ctx.closePath()
                                ctx.fill()
                            } else if (m === "orbit") {
                                ctx.beginPath()
                                ctx.arc(cx, cy, 9, 0, Math.PI * 1.55)
                                ctx.lineTo(cx, cy)
                                ctx.closePath()
                                ctx.fill()
                            } else {
                                ctx.beginPath()
                                ctx.moveTo(cx, 2)
                                ctx.lineTo(cx, height - 2)
                                ctx.moveTo(3, cy - 3)
                                ctx.lineTo(width - 3, cy - 3)
                                ctx.moveTo(5, cy + 3)
                                ctx.lineTo(width - 5, cy + 3)
                                ctx.stroke()
                                ctx.fillRect(cx - 2.5, cy - 2.5, 5, 5)
                            }
                        }
                    }
                }

                // Clean Runner Name + Custom Title (no fake game stats)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        Layout.fillWidth: true
                        text: (Tokens.runnerName || "RUNNER").toUpperCase()
                        color: Tokens.text
                        font.family: Tokens.fontUi
                        font.pixelSize: Tokens.fontTitle
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: Tokens.spaceXs

                        // Solid accent Custom Title Pill
                        Rectangle {
                            width: titleTxt.implicitWidth + 10
                            height: 18
                            color: Tokens.signal

                            Text {
                                id: titleTxt
                                anchors.centerIn: parent
                                text: (Tokens.runnerTitle || "OPERATOR").toUpperCase()
                                color: Tokens.textOnSignal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }
                        }

                        // Emblem decal code pill
                        Rectangle {
                            width: codeTxt.implicitWidth + 10
                            height: 18
                            color: Tokens.surface
                            border.width: 1
                            border.color: Tokens.borderStrong

                            Text {
                                id: codeTxt
                                anchors.centerIn: parent
                                text: root.emblemData.code
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Tokens.cycleEmblem()
                    root.emblemSelected(Tokens.emblemId)
                }
            }
        }

        // User-Editable Name & Custom Title Fields + 6-Emblem Selector (in Control Center)
        RowLayout {
            visible: root.showSelector
            Layout.fillWidth: true
            spacing: Tokens.spaceXs

            TacticalTextField {
                id: nameInput
                Layout.fillWidth: true
                text: Tokens.runnerName
                placeholderText: "NAME..."
                onTextChanged: {
                    if (nameInput.text.trim() !== "") {
                        Tokens.setRunnerName(nameInput.text)
                        root.nameEdited(Tokens.runnerName)
                    }
                }
            }

            TacticalTextField {
                id: titleInput
                Layout.fillWidth: true
                text: Tokens.runnerTitle
                placeholderText: "CUSTOM TITLE..."
                onTextChanged: {
                    if (titleInput.text.trim() !== "") {
                        Tokens.setRunnerTitle(titleInput.text)
                        root.titleEdited(Tokens.runnerTitle)
                    }
                }
            }
        }

        GridLayout {
            visible: root.showSelector
            Layout.fillWidth: true
            columns: 3
            columnSpacing: Tokens.spaceXs
            rowSpacing: Tokens.spaceXs

            Repeater {
                model: Tokens.emblems
                delegate: TacticalButton {
                    id: embBtn
                    required property var modelData
                    Layout.fillWidth: true
                    text: embBtn.modelData.code
                    active: Tokens.emblemId === embBtn.modelData.id
                    variant: Tokens.emblemId === embBtn.modelData.id ? "primary" : "default"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        Tokens.setEmblem(embBtn.modelData.id)
                        root.emblemSelected(embBtn.modelData.id)
                    }
                }
            }
        }
    }
}
