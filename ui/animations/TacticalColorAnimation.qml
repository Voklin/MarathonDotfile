import QtQuick
import "../tokens"

ColorAnimation {
    property bool reducedMotion: false
    property int baseDuration: Tokens.durationFast
    duration: Tokens.motionMs(baseDuration, reducedMotion)
    easing.type: Tokens.easingType
}

