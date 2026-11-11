import QtQuick
import "../tokens"

Item {
    id: root

    property bool shown: true
    property bool reducedMotion: false
    property int slideOffsetY: -Tokens.spaceSm
    default property alias content: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    visible: shown || opacity > 0.01

    opacity: shown ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion)
            easing.type: Tokens.easingType
        }
    }

    Item {
        id: container
        anchors.fill: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        transform: Translate {
            y: root.shown || root.reducedMotion ? 0 : root.slideOffsetY
            Behavior on y {
                NumberAnimation {
                    duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion)
                    easing.type: Tokens.easingType
                }
            }
        }
    }
}

