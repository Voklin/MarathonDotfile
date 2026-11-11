pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../ui/tokens"

Variants {
    id: root

    required property var backend

    readonly property var settingsObj: (root.backend && root.backend.settings) ? root.backend.settings : null
    readonly property string wallId: settingsObj ? settingsObj.wallpaperId : "matrix"
    readonly property bool matrixEnabled: settingsObj ? settingsObj.backdropMatrixEnabled : true
    readonly property real matrixOpacity: settingsObj ? settingsObj.backdropMatrixOpacity : 0.42
    readonly property real dimOpacity: settingsObj ? settingsObj.backdropDim : 0.0
    readonly property bool hasWallpaperImage: wallId === "grid-4k" || wallId === "grid-1080" || wallId === "lock-4k"
    readonly property bool hasContent: hasWallpaperImage || (matrixEnabled && wallId !== "solid") || dimOpacity > 0.001

    model: hasContent ? Quickshell.screens : []

    PanelWindow {
        id: bgWin
        required property var modelData

        screen: modelData
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "marathon-backdrop"
        color: Tokens.background

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: {
                if (root.wallId === "grid-4k") return "../../design/wallpapers/marathon-grid-3840x2160.png"
                if (root.wallId === "grid-1080") return "../../design/wallpapers/marathon-grid-1920x1080.png"
                if (root.wallId === "lock-4k") return "../../design/wallpapers/marathon-lock-3840x2160.png"
                return ""
            }
            visible: root.hasWallpaperImage && source !== ""
        }

        Canvas {
            id: matrixCanvas
            anchors.fill: parent
            visible: root.matrixEnabled && root.wallId !== "solid"
            opacity: root.matrixOpacity
            Connections {
                target: Tokens
                function onFactionIdChanged() { matrixCanvas.requestPaint() }
                function onSurfaceThemeChanged() { matrixCanvas.requestPaint() }
                function onCustomAccentHexChanged() { matrixCanvas.requestPaint() }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)

                var step = 72
                ctx.strokeStyle = Tokens.borderSubtle.toString()
                ctx.lineWidth = 1
                ctx.beginPath()
                for (var cx = step; cx < width - 32; cx += step) {
                    for (var cy = step; cy < height - 32; cy += step) {
                        var arm = ((cx / step) % 2 === 0 && (cy / step) % 2 === 0) ? 6 : 3
                        ctx.moveTo(cx - arm, cy + 0.5)
                        ctx.lineTo(cx + arm + 1, cy + 0.5)
                        ctx.moveTo(cx + 0.5, cy - arm)
                        ctx.lineTo(cx + 0.5, cy + arm + 1)
                    }
                }
                ctx.stroke()

                ctx.strokeStyle = Tokens.borderStrong.toString()
                ctx.beginPath()
                var major = step * 3
                for (var mx = major; mx < width - 64; mx += major) {
                    for (var my = major; my < height - 64; my += major) {
                        ctx.moveTo(mx - 8, my + 0.5)
                        ctx.lineTo(mx + 9, my + 0.5)
                        ctx.moveTo(mx + 0.5, my - 8)
                        ctx.lineTo(mx + 0.5, my + 9)
                    }
                }
                ctx.stroke()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Tokens.voidBg
            opacity: root.dimOpacity
            visible: opacity > 0.001
        }
    }
}
