pragma ComponentBehavior: Bound
import QtQuick
import "../tokens"

Canvas {
    id: root

    property string iconName: "grid"
    property color color: Tokens.text
    property int iconSize: 16

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: iconSize
    height: iconSize

    onIconNameChanged: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)

        var s = Math.min(width, height) / 16.0
        ctx.save()
        ctx.scale(s, s)
        ctx.strokeStyle = root.color.toString()
        ctx.fillStyle = root.color.toString()
        ctx.lineWidth = 1.4
        ctx.lineCap = "square"
        ctx.lineJoin = "miter"

        var n = root.iconName

        if (n === "audio" || n === "audio-muted") {
            ctx.beginPath()
            ctx.moveTo(2.5, 6)
            ctx.lineTo(5.5, 6)
            ctx.lineTo(9, 3)
            ctx.lineTo(9, 13)
            ctx.lineTo(5.5, 10)
            ctx.lineTo(2.5, 10)
            ctx.closePath()
            ctx.stroke()
            if (n === "audio") {
                ctx.beginPath()
                ctx.moveTo(11.5, 5.5)
                ctx.lineTo(13, 8)
                ctx.lineTo(11.5, 10.5)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(13.5, 3.5)
                ctx.lineTo(15, 8)
                ctx.lineTo(13.5, 12.5)
                ctx.stroke()
            } else {
                ctx.beginPath()
                ctx.moveTo(11, 5.5)
                ctx.lineTo(14.5, 10.5)
                ctx.moveTo(14.5, 5.5)
                ctx.lineTo(11, 10.5)
                ctx.stroke()
            }
        } else if (n === "mic" || n === "mic-muted") {
            ctx.strokeRect(6, 2, 4, 7)
            ctx.beginPath()
            ctx.moveTo(4, 7.5)
            ctx.lineTo(4, 10.5)
            ctx.lineTo(12, 10.5)
            ctx.lineTo(12, 7.5)
            ctx.moveTo(8, 10.5)
            ctx.lineTo(8, 14)
            ctx.moveTo(5.5, 14)
            ctx.lineTo(10.5, 14)
            ctx.stroke()
            if (n === "mic-muted") {
                ctx.beginPath()
                ctx.moveTo(2.5, 2.5)
                ctx.lineTo(13.5, 13.5)
                ctx.stroke()
            }
        } else if (n === "wifi" || n === "wifi-off") {
            ctx.beginPath()
            ctx.moveTo(2, 5.5)
            ctx.lineTo(8, 3)
            ctx.lineTo(14, 5.5)
            ctx.moveTo(4, 8.5)
            ctx.lineTo(8, 6.8)
            ctx.lineTo(12, 8.5)
            ctx.stroke()
            ctx.fillRect(7, 11, 2, 2)
            if (n === "wifi-off") {
                ctx.beginPath()
                ctx.moveTo(2.5, 2.5)
                ctx.lineTo(13.5, 13.5)
                ctx.stroke()
            }
        } else if (n === "ethernet") {
            ctx.strokeRect(2.5, 3, 11, 8)
            ctx.fillRect(5, 5, 1.5, 3)
            ctx.fillRect(7.5, 5, 1.5, 3)
            ctx.fillRect(10, 5, 1.5, 3)
            ctx.beginPath()
            ctx.moveTo(8, 11)
            ctx.lineTo(8, 14)
            ctx.moveTo(4, 14)
            ctx.lineTo(12, 14)
            ctx.stroke()
        } else if (n === "bluetooth" || n === "bluetooth-off") {
            ctx.beginPath()
            ctx.moveTo(8, 2)
            ctx.lineTo(8, 14)
            ctx.lineTo(12, 10.5)
            ctx.lineTo(4.5, 5)
            ctx.moveTo(8, 2)
            ctx.lineTo(12, 5.5)
            ctx.lineTo(4.5, 11)
            ctx.stroke()
            if (n === "bluetooth-off") {
                ctx.beginPath()
                ctx.moveTo(2.5, 2.5)
                ctx.lineTo(13.5, 13.5)
                ctx.stroke()
            }
        } else if (n === "battery" || n === "battery-charging") {
            ctx.strokeRect(2, 4.5, 11, 7)
            ctx.fillRect(13, 6.5, 1.5, 3)
            if (n === "battery-charging") {
                ctx.beginPath()
                ctx.moveTo(8.5, 5.5)
                ctx.lineTo(6, 8)
                ctx.lineTo(8.5, 8)
                ctx.lineTo(6.5, 10.5)
                ctx.stroke()
            } else {
                ctx.fillRect(4, 6.5, 7, 3)
            }
        } else if (n === "brightness") {
            ctx.strokeRect(5.5, 5.5, 5, 5)
            ctx.beginPath()
            ctx.moveTo(8, 1.5); ctx.lineTo(8, 3.5)
            ctx.moveTo(8, 12.5); ctx.lineTo(8, 14.5)
            ctx.moveTo(1.5, 8); ctx.lineTo(3.5, 8)
            ctx.moveTo(12.5, 8); ctx.lineTo(14.5, 8)
            ctx.moveTo(3.3, 3.3); ctx.lineTo(4.6, 4.6)
            ctx.moveTo(11.4, 11.4); ctx.lineTo(12.7, 12.7)
            ctx.moveTo(12.7, 3.3); ctx.lineTo(11.4, 4.6)
            ctx.moveTo(4.6, 11.4); ctx.lineTo(3.3, 12.7)
            ctx.stroke()
        } else if (n === "bell" || n === "bell-off") {
            ctx.beginPath()
            ctx.moveTo(4, 11)
            ctx.lineTo(4.5, 5.5)
            ctx.lineTo(8, 3)
            ctx.lineTo(11.5, 5.5)
            ctx.lineTo(12, 11)
            ctx.closePath()
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(2.5, 11)
            ctx.lineTo(13.5, 11)
            ctx.stroke()
            ctx.fillRect(7, 12.5, 2, 1.5)
            if (n === "bell-off") {
                ctx.beginPath()
                ctx.moveTo(2.5, 2.5)
                ctx.lineTo(13.5, 13.5)
                ctx.stroke()
            }
        } else if (n === "lock") {
            ctx.strokeRect(3.5, 7, 9, 6.5)
            ctx.beginPath()
            ctx.moveTo(5.5, 7)
            ctx.lineTo(5.5, 4)
            ctx.lineTo(8, 2.5)
            ctx.lineTo(10.5, 4)
            ctx.lineTo(10.5, 7)
            ctx.stroke()
            ctx.fillRect(7.2, 9.5, 1.6, 2)
        } else if (n === "power") {
            ctx.beginPath()
            ctx.moveTo(8, 2)
            ctx.lineTo(8, 8)
            ctx.moveTo(4.5, 4.5)
            ctx.lineTo(3, 7.5)
            ctx.lineTo(4.5, 11.5)
            ctx.lineTo(8, 13.5)
            ctx.lineTo(11.5, 11.5)
            ctx.lineTo(13, 7.5)
            ctx.lineTo(11.5, 4.5)
            ctx.stroke()
        } else if (n === "reboot") {
            ctx.beginPath()
            ctx.moveTo(12.5, 5.5)
            ctx.lineTo(10.5, 3)
            ctx.lineTo(5, 3)
            ctx.lineTo(3, 8)
            ctx.lineTo(5, 13)
            ctx.lineTo(11, 13)
            ctx.lineTo(13, 9.5)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(10, 6)
            ctx.lineTo(13.5, 6)
            ctx.lineTo(13.5, 2.5)
            ctx.stroke()
        } else if (n === "logout") {
            ctx.beginPath()
            ctx.moveTo(9, 2.5)
            ctx.lineTo(3, 2.5)
            ctx.lineTo(3, 13.5)
            ctx.lineTo(9, 13.5)
            ctx.moveTo(6.5, 8)
            ctx.lineTo(13.5, 8)
            ctx.moveTo(11, 5.5)
            ctx.lineTo(13.5, 8)
            ctx.lineTo(11, 10.5)
            ctx.stroke()
        } else if (n === "sleep") {
            ctx.beginPath()
            ctx.moveTo(10.5, 2.5)
            ctx.lineTo(6, 4.5)
            ctx.lineTo(4.5, 9)
            ctx.lineTo(7, 13)
            ctx.lineTo(12, 13)
            ctx.lineTo(8.5, 10)
            ctx.lineTo(8.5, 6)
            ctx.closePath()
            ctx.stroke()
        } else if (n === "search") {
            ctx.beginPath()
            ctx.moveTo(4, 3)
            ctx.lineTo(9, 3)
            ctx.lineTo(10.5, 4.5)
            ctx.lineTo(10.5, 9.5)
            ctx.lineTo(9, 11)
            ctx.lineTo(4, 11)
            ctx.lineTo(2.5, 9.5)
            ctx.lineTo(2.5, 4.5)
            ctx.closePath()
            ctx.moveTo(10.2, 10.2)
            ctx.lineTo(14, 14)
            ctx.stroke()
        } else if (n === "settings") {
            ctx.strokeRect(5.5, 5.5, 5, 5)
            ctx.fillRect(7, 2, 2, 2)
            ctx.fillRect(7, 12, 2, 2)
            ctx.fillRect(2, 7, 2, 2)
            ctx.fillRect(12, 7, 2, 2)
        } else if (n === "close") {
            ctx.beginPath()
            ctx.moveTo(3.5, 3.5)
            ctx.lineTo(12.5, 12.5)
            ctx.moveTo(12.5, 3.5)
            ctx.lineTo(3.5, 12.5)
            ctx.stroke()
        } else if (n === "check") {
            ctx.beginPath()
            ctx.moveTo(3, 8.5)
            ctx.lineTo(6.5, 12)
            ctx.lineTo(13, 4.5)
            ctx.stroke()
        } else if (n === "warning") {
            ctx.beginPath()
            ctx.moveTo(8, 2.5)
            ctx.lineTo(14, 13.5)
            ctx.lineTo(2, 13.5)
            ctx.closePath()
            ctx.stroke()
            ctx.fillRect(7.3, 6.5, 1.4, 3.5)
            ctx.fillRect(7.3, 11, 1.4, 1.4)
        } else if (n === "terminal") {
            ctx.strokeRect(2, 3, 12, 10)
            ctx.beginPath()
            ctx.moveTo(4.5, 6)
            ctx.lineTo(7, 8)
            ctx.lineTo(4.5, 10)
            ctx.moveTo(8.5, 10)
            ctx.lineTo(11.5, 10)
            ctx.stroke()
        } else if (n === "chevron-right") {
            ctx.beginPath()
            ctx.moveTo(5.5, 3.5)
            ctx.lineTo(10.5, 8)
            ctx.lineTo(5.5, 12.5)
            ctx.stroke()
        } else if (n === "chevron-left") {
            ctx.beginPath()
            ctx.moveTo(10.5, 3.5)
            ctx.lineTo(5.5, 8)
            ctx.lineTo(10.5, 12.5)
            ctx.stroke()
        } else if (n === "clipboard") {
            ctx.strokeRect(3.5, 3.5, 9, 10.5)
            ctx.fillRect(6, 2, 4, 2)
            ctx.beginPath()
            ctx.moveTo(5.5, 7); ctx.lineTo(10.5, 7)
            ctx.moveTo(5.5, 10); ctx.lineTo(9, 10)
            ctx.stroke()
        } else if (n === "capture") {
            ctx.beginPath()
            ctx.moveTo(2.5, 5.5); ctx.lineTo(2.5, 2.5); ctx.lineTo(5.5, 2.5)
            ctx.moveTo(10.5, 2.5); ctx.lineTo(13.5, 2.5); ctx.lineTo(13.5, 5.5)
            ctx.moveTo(13.5, 10.5); ctx.lineTo(13.5, 13.5); ctx.lineTo(10.5, 13.5)
            ctx.moveTo(5.5, 13.5); ctx.lineTo(2.5, 13.5); ctx.lineTo(2.5, 10.5)
            ctx.stroke()
            ctx.strokeRect(6, 6, 4, 4)
        } else if (n === "play") {
            ctx.beginPath()
            ctx.moveTo(4.5, 3)
            ctx.lineTo(13, 8)
            ctx.lineTo(4.5, 13)
            ctx.closePath()
            ctx.stroke()
        } else if (n === "pause") {
            ctx.fillRect(4, 3, 2.5, 10)
            ctx.fillRect(9.5, 3, 2.5, 10)
        } else if (n === "calendar") {
            ctx.strokeRect(2.5, 3.5, 11, 10)
            ctx.beginPath()
            ctx.moveTo(5.5, 2); ctx.lineTo(5.5, 4.5)
            ctx.moveTo(10.5, 2); ctx.lineTo(10.5, 4.5)
            ctx.moveTo(2.5, 6.5); ctx.lineTo(13.5, 6.5)
            ctx.stroke()
            ctx.fillRect(5, 8.5, 2, 2)
            ctx.fillRect(9, 8.5, 2, 2)
        } else if (n === "cpu") {
            ctx.strokeRect(4.5, 4.5, 7, 7)
            ctx.fillRect(6.8, 6.8, 2.4, 2.4)
            ctx.beginPath()
            ctx.moveTo(6.5, 2); ctx.lineTo(6.5, 4.5)
            ctx.moveTo(9.5, 2); ctx.lineTo(9.5, 4.5)
            ctx.moveTo(6.5, 11.5); ctx.lineTo(6.5, 14)
            ctx.moveTo(9.5, 11.5); ctx.lineTo(9.5, 14)
            ctx.moveTo(2, 6.5); ctx.lineTo(4.5, 6.5)
            ctx.moveTo(2, 9.5); ctx.lineTo(4.5, 9.5)
            ctx.moveTo(11.5, 6.5); ctx.lineTo(14, 6.5)
            ctx.moveTo(11.5, 9.5); ctx.lineTo(14, 9.5)
            ctx.stroke()
        } else if (n === "palette") {
            ctx.beginPath()
            ctx.moveTo(3, 4); ctx.lineTo(13, 4); ctx.lineTo(13, 10)
            ctx.lineTo(9, 10); ctx.lineTo(9, 13); ctx.lineTo(3, 13)
            ctx.closePath()
            ctx.stroke()
            ctx.fillRect(5, 6, 2, 2)
            ctx.fillRect(9, 6, 2, 2)
        } else if (n === "help") {
            ctx.strokeRect(2.5, 2.5, 11, 11)
            ctx.beginPath()
            ctx.moveTo(6, 6.2); ctx.lineTo(6, 5); ctx.lineTo(10, 5)
            ctx.lineTo(10, 7.5); ctx.lineTo(8, 8.5); ctx.lineTo(8, 9.8)
            ctx.stroke()
            ctx.fillRect(7.3, 11, 1.4, 1.4)
        } else {
            ctx.strokeRect(2.5, 2.5, 4.5, 4.5)
            ctx.strokeRect(9, 2.5, 4.5, 4.5)
            ctx.strokeRect(2.5, 9, 4.5, 4.5)
            ctx.strokeRect(9, 9, 4.5, 4.5)
        }

        ctx.restore()
    }
}
