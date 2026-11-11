pragma ComponentBehavior: Bound
import QtQuick
import "../tokens"

Item {
    id: root

    property int orientation: Qt.Horizontal
    property color lineColor: Tokens.border
    property bool withTicks: false

    implicitWidth: orientation === Qt.Horizontal ? 120 : (withTicks ? Tokens.spaceSm : Tokens.borderWidth)
    implicitHeight: orientation === Qt.Horizontal ? (withTicks ? Tokens.spaceSm : Tokens.borderWidth) : 20

    Rectangle {
        visible: root.orientation === Qt.Horizontal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: Tokens.borderWidth
        color: root.lineColor
    }

    Rectangle {
        visible: root.orientation === Qt.Horizontal && root.withTicks
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Tokens.spaceXs
        height: Tokens.spaceXs
        color: root.lineColor
    }

    Rectangle {
        visible: root.orientation === Qt.Horizontal && root.withTicks
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Tokens.spaceXs
        height: Tokens.spaceXs
        color: root.lineColor
    }

    Rectangle {
        visible: root.orientation === Qt.Vertical
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Tokens.borderWidth
        color: root.lineColor
    }
}

