import QtQuick

// Preview-only active keyboard layout. Mirrors shell/services/KeyboardAdapter.qml.
QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property var layouts: ["English (US)", "Russian"]
    property int activeIndex: 0
    property string layoutName: layouts[activeIndex] || ""
    property string shortCode: layoutName.indexOf("Russian") === 0 ? "RU" : (layoutName.indexOf("English") === 0 ? "EN" : layoutName.substring(0, 2).toUpperCase())

    function nextLayout() {
        if (layouts.length === 0) return
        activeIndex = (activeIndex + 1) % layouts.length
    }
}
