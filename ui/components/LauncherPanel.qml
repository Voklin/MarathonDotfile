pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var launcher
    property var settings: null
    property var utilities: null
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()
    signal safeCommandTriggered(string commandId)
    signal entryLaunched(string entryId)
    signal inlineResultCopied(string resultText)

    property string activeTab: "apps" // "apps" | "commands"
    readonly property bool commandModeActive: activeTab === "commands" || (launcher !== null && (launcher.query || "").trim().indexOf(">") === 0)
    property string layoutMode: "list" // "list" | "grid"
    property int selectedIndex: 0
    property var filteredItems: []
    property var inlineComputation: null
    property point lastPointerPos: Qt.point(-1, -1)

    function _safeEvalMath(exprRaw) {
        var s = String(exprRaw || "").trim()
        if (s === "" || s.length > 96) return null
        if (/[^0-9a-zA-Z_+\-*/%^().\s]/.test(s)) return null
        var i = 0
        function skipWs() {
            while (i < s.length && /\s/.test(s.charAt(i))) i++
        }
        function parseExpr() {
            var left = parseTerm()
            if (left === null) return null
            while (true) {
                skipWs()
                var ch = s.charAt(i)
                if (ch === "+" || ch === "-") {
                    i++
                    var right = parseTerm()
                    if (right === null) return null
                    left = (ch === "+") ? (left + right) : (left - right)
                } else break
            }
            return left
        }
        function parseTerm() {
            var left = parsePower()
            if (left === null) return null
            while (true) {
                skipWs()
                var ch = s.charAt(i)
                if (ch === "*" || ch === "/" || ch === "%") {
                    i++
                    var right = parsePower()
                    if (right === null) return null
                    if ((ch === "/" || ch === "%") && right === 0) return null
                    left = (ch === "*") ? (left * right) : ((ch === "/") ? (left / right) : (left % right))
                } else break
            }
            return left
        }
        function parsePower() {
            var base = parseUnary()
            if (base === null) return null
            skipWs()
            if (s.charAt(i) === "^") {
                i++
                var exp = parsePower()
                if (exp === null) return null
                return Math.pow(base, exp)
            }
            return base
        }
        function parseUnary() {
            skipWs()
            var ch = s.charAt(i)
            if (ch === "+") { i++; return parseUnary() }
            if (ch === "-") { i++; var v = parseUnary(); return v === null ? null : -v }
            return parsePrimary()
        }
        function parsePrimary() {
            skipWs()
            if (s.charAt(i) === "(") {
                i++
                var inner = parseExpr()
                skipWs()
                if (s.charAt(i) !== ")") return null
                i++
                return inner
            }
            var numMatch = /^\d+(?:\.\d+)?/.exec(s.slice(i))
            if (numMatch) {
                i += numMatch[0].length
                return parseFloat(numMatch[0])
            }
            var idMatch = /^[a-zA-Z_][a-zA-Z0-9_]*/.exec(s.slice(i))
            if (idMatch) {
                var name = idMatch[0].toLowerCase()
                i += idMatch[0].length
                skipWs()
                if (s.charAt(i) === "(") {
                    i++
                    var arg = parseExpr()
                    skipWs()
                    if (arg === null || s.charAt(i) !== ")") return null
                    i++
                    if (name === "sqrt") return arg < 0 ? null : Math.sqrt(arg)
                    if (name === "abs") return Math.abs(arg)
                    if (name === "round") return Math.round(arg)
                    if (name === "floor") return Math.floor(arg)
                    if (name === "ceil") return Math.ceil(arg)
                    if (name === "sin") return Math.sin(arg)
                    if (name === "cos") return Math.cos(arg)
                    return null
                }
                if (name === "pi") return Math.PI
                if (name === "e") return Math.E
                return null
            }
            return null
        }
        var res = parseExpr()
        skipWs()
        if (res === null || i !== s.length || !isFinite(res)) return null
        return res
    }

    function _formatNumber(n) {
        if (Math.abs(n - Math.round(n)) < 1e-9) return String(Math.round(n))
        return String(parseFloat(n.toFixed(6)))
    }

    function computeInlineResult(rawText) {
        var raw = String(rawText || "").trim()
        if (raw === "") return null
        var explicitEqual = raw.indexOf("=") === 0
        var expr = explicitEqual ? raw.slice(1).trim() : raw
        if (expr === "") return null

        // Color converter (#RRGGBB)
        var hexMatch = /^#([0-9A-Fa-f]{6})$/.exec(expr)
        if (hexMatch) {
            var hex = "#" + hexMatch[1].toUpperCase()
            var r = parseInt(hexMatch[1].slice(0, 2), 16)
            var g = parseInt(hexMatch[1].slice(2, 4), 16)
            var b = parseInt(hexMatch[1].slice(4, 6), 16)
            var rn = r / 255.0, gn = g / 255.0, bn = b / 255.0
            var cmax = Math.max(rn, gn, bn), cmin = Math.min(rn, gn, bn)
            var d = cmax - cmin
            var l = (cmax + cmin) / 2.0
            var sat = d === 0 ? 0 : d / (1 - Math.abs(2 * l - 1))
            var hue = 0
            if (d !== 0) {
                if (cmax === rn) hue = ((gn - bn) / d) % 6
                else if (cmax === gn) hue = (bn - rn) / d + 2
                else hue = (rn - gn) / d + 4
                hue = Math.round(hue * 60)
                if (hue < 0) hue += 360
            }
            var rgbStr = "rgb(" + r + ", " + g + ", " + b + ")"
            var hslStr = "hsl(" + hue + ", " + Math.round(sat * 100) + "%, " + Math.round(l * 100) + "%)"
            var hyprStr = "rgba(" + hexMatch[1].toLowerCase() + "ff)"
            return {
                kind: "COLOR",
                title: rgbStr + " // " + hslStr,
                detail: "HYPRLAND: " + hyprStr,
                copyValue: rgbStr,
                swatchHex: hex
            }
        }

        // Unit conversion (<val><from> to|in|-> <to>)
        var unitMatch = /^(-?\d+(?:\.\d+)?)\s*([a-zA-Z]+)\s*(?:to|in|->)\s*([a-zA-Z]+)$/i.exec(expr)
        if (unitMatch) {
            var val = parseFloat(unitMatch[1])
            var uFrom = unitMatch[2].toLowerCase()
            var uTo = unitMatch[3].toLowerCase()
            var outVal = null
            if (uFrom === "px" && uTo === "rem") outVal = val / 16.0
            else if (uFrom === "rem" && uTo === "px") outVal = val * 16.0
            else if (uFrom === "c" && uTo === "f") outVal = (val * 9.0 / 5.0) + 32.0
            else if (uFrom === "f" && uTo === "c") outVal = (val - 32.0) * 5.0 / 9.0
            else if ((uFrom === "gb" || uFrom === "gib") && (uTo === "mb" || uTo === "mib")) outVal = val * (uFrom === "gib" || uTo === "mib" ? 1024.0 : 1000.0)
            else if ((uFrom === "mb" || uFrom === "mib") && (uTo === "gb" || uTo === "gib")) outVal = val / (uFrom === "mib" || uTo === "gib" ? 1024.0 : 1000.0)
            else if ((uFrom === "mb" || uFrom === "mib") && (uTo === "kb" || uTo === "kib")) outVal = val * (uFrom === "mib" || uTo === "kib" ? 1024.0 : 1000.0)
            else if (uFrom === "km" && uTo === "mi") outVal = val * 0.621371
            else if (uFrom === "mi" && uTo === "km") outVal = val / 0.621371
            else if (uFrom === "m" && uTo === "ft") outVal = val * 3.28084
            else if (uFrom === "ft" && uTo === "m") outVal = val / 3.28084
            else if (uFrom === "kg" && uTo === "lb") outVal = val * 2.20462
            else if (uFrom === "lb" && uTo === "kg") outVal = val / 2.20462
            else if (uFrom === "deg" && uTo === "rad") outVal = val * Math.PI / 180.0
            else if (uFrom === "rad" && uTo === "deg") outVal = val * 180.0 / Math.PI
            if (outVal !== null && isFinite(outVal)) {
                var formatted = _formatNumber(outVal) + " " + uTo
                return {
                    kind: "UNIT",
                    title: _formatNumber(outVal) + " " + uTo.toUpperCase(),
                    detail: val + " " + uFrom.toUpperCase() + " -> " + formatted.toUpperCase(),
                    copyValue: _formatNumber(outVal),
                    swatchHex: ""
                }
            }
        }

        // Math evaluator (either = prefix or strict numeric expression with operator)
        if (explicitEqual || (/^\s*[\d.(].*[+\-*/%^]/.test(expr) && /[0-9]/.test(expr))) {
            var numVal = _safeEvalMath(expr)
            if (numVal !== null) {
                var strNum = _formatNumber(numVal)
                return {
                    kind: "CALC",
                    title: strNum,
                    detail: expr + " = " + strNum,
                    copyValue: strNum,
                    swatchHex: ""
                }
            }
        }
        return null
    }

    function handlePointerHover(index, localItem, mx, my, moved) {
        var pt = localItem.mapToItem(root, mx, my)
        if (lastPointerPos.x < 0) {
            lastPointerPos = pt
            return
        }
        var dx = Math.abs(pt.x - lastPointerPos.x)
        var dy = Math.abs(pt.y - lastPointerPos.y)
        if (dx >= 1 || dy >= 1) {
            lastPointerPos = pt
            if (moved || dx >= 2 || dy >= 2)
                selectedIndex = index
        }
    }

    function refreshList() {
        var rawQ = launcher ? (launcher.query || "") : ""
        var trimmed = rawQ.trim()
        inlineComputation = computeInlineResult(trimmed)

        if (!launcher || !launcher.available) {
            filteredItems = []
            selectedIndex = 0
            return
        }
        var cmdMode = (activeTab === "commands") || (trimmed.indexOf(">") === 0)
        if (cmdMode) {
            var q = (trimmed.indexOf(">") === 0 ? trimmed.slice(1) : trimmed).trim().toLowerCase()
            var cmds = launcher.safeCommands || []
            var out = []
            for (var i = 0; i < cmds.length; ++i) {
                if (q === "" || cmds[i].title.toLowerCase().indexOf(q) !== -1 || cmds[i].detail.toLowerCase().indexOf(q) !== -1) {
                    out.push(cmds[i])
                }
            }
            filteredItems = out
        } else if (trimmed.indexOf("=") === 0 || trimmed === "@") {
            filteredItems = []
        } else {
            var base = launcher.filteredEntries()
            if (settings && !settings.launcherShowRecents && trimmed === "") {
                var alpha = base.slice()
                alpha.sort(function(a, b) { return a.name.localeCompare(b.name) })
                filteredItems = alpha
            } else {
                filteredItems = base
            }
        }
        if (selectedIndex >= filteredItems.length) {
            selectedIndex = Math.max(0, filteredItems.length - 1)
        }
    }

    function iconForEntry(entry) {
        if (!entry) return "grid"
        var tag = entry.iconTag || ""
        if (tag === "TRM" || tag === "EDT" || tag === "IDE") return "terminal"
        if (tag === "WEB" || tag === "PKT") return "wifi"
        if (tag === "AUD") return "audio"
        if (tag === "MON") return "settings"
        return "grid"
    }

    function effectiveRecentIds() {
        if (!launcher || !launcher.recentIds) return []
        if (settings && !settings.launcherShowRecents) return []
        var maxRec = settings ? Math.max(1, settings.launcherMaxRecents) : launcher.recentIds.length
        return launcher.recentIds.slice(0, maxRec)
    }

    function isRecent(entryId) {
        return effectiveRecentIds().indexOf(entryId) !== -1
    }

    function copyComputationResult() {
        if (!inlineComputation) return
        var val = inlineComputation.copyValue
        if (utilities) utilities.copyText(val)
        inlineResultCopied(val)
        if (!settings || settings.launcherCloseOnLaunch) {
            closeRequested()
        }
    }

    function activateCurrent() {
        var trimmed = launcher ? (launcher.query || "").trim() : ""
        if (trimmed === "@") {
            if (launcher) launcher.runSafeCommand("open-clipboard")
            safeCommandTriggered("open-clipboard")
            closeRequested()
            return
        }
        if (inlineComputation && (filteredItems.length === 0 || trimmed.indexOf("=") === 0)) {
            copyComputationResult()
            return
        }
        if (filteredItems.length === 0 || selectedIndex < 0 || selectedIndex >= filteredItems.length) return
        var item = filteredItems[selectedIndex]
        if (activeTab === "commands" || trimmed.indexOf(">") === 0) {
            launcher.runSafeCommand(item.id)
            safeCommandTriggered(item.id)
        } else {
            launcher.launchEntry(item.id)
            entryLaunched(item.id)
        }
        if (!settings || settings.launcherCloseOnLaunch) {
            closeRequested()
        }
    }

    function moveSelection(delta) {
        if (filteredItems.length === 0) return
        var next = Math.max(0, Math.min(filteredItems.length - 1, selectedIndex + delta))
        selectedIndex = next
        if (layoutMode === "grid") {
            resultGrid.positionViewAtIndex(next, GridView.Contain)
        } else {
            resultList.positionViewAtIndex(next, ListView.Contain)
        }
    }

    onOpenChanged: {
        if (open) {
            lastPointerPos = Qt.point(-1, -1)
            if (settings && (settings.launcherDefaultLayout === "grid" || settings.launcherDefaultLayout === "list")) {
                layoutMode = settings.launcherDefaultLayout
            }
            activeTab = "apps"
            selectedIndex = 0
            if (launcher) launcher.setQuery("")
            searchField.text = ""
            refreshList()
            searchField.focusInput()
        }
    }

    onActiveTabChanged: {
        selectedIndex = 0
        refreshList()
    }

    Connections {
        target: root.launcher
        function onEntriesChanged() { root.refreshList() }
        function onQueryChanged() { root.refreshList() }
    }

    Component.onCompleted: refreshList()

    visible: open || revealBox.opacity > 0.01

    // Scrim backdrop (click outside to dismiss)
    Rectangle {
        anchors.fill: parent
        color: Tokens.surfaceOverlay
        opacity: root.open ? 0.72 : 0.0
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
        id: revealBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.min(84, Math.max(Tokens.spaceLg, parent.height * 0.1))
        width: Math.min(Tokens.launcherWidth, parent.width - Tokens.spaceXl)
        height: Math.min(500, parent.height - anchors.topMargin - Tokens.spaceXl)
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea {
            anchors.fill: launcherCard
        }

        TacticalPanel {
            id: launcherCard
            anchors.fill: parent
            code: "COMMAND TERMINAL // APPLICATION LAUNCHER"
            title: root.activeTab === "apps" ? "DEPLOY APPLICATION" : "SAFE COMMAND WHITELIST"
            statusText: root.launcher && root.launcher.available ? (root.filteredItems.length + " READY") : "UNAVAILABLE"
            statusTone: root.launcher && root.launcher.available ? "signal" : "alert"
            alertState: !(root.launcher && root.launcher.available)

            // Mode switcher + search input
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                TacticalTextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: !root.commandModeActive
                        ? "SEARCH APPS // =CALC // >CMD // @CLIP..."
                        : "FILTER SAFE SYSTEM COMMANDS..."
                    enabledState: root.launcher && root.launcher.available
                    onTextChanged: {
                        if (root.launcher) root.launcher.setQuery(searchField.text)
                        root.selectedIndex = 0
                        root.refreshList()
                    }
                    onTextSubmitted: root.activateCurrent()
                    onEscapePressed: root.closeRequested()

                    Keys.onDownPressed: function(event) {
                        root.moveSelection(root.layoutMode === "grid" ? 2 : 1)
                        event.accepted = true
                    }
                    Keys.onUpPressed: function(event) {
                        root.moveSelection(root.layoutMode === "grid" ? -2 : -1)
                        event.accepted = true
                    }
                    Keys.onRightPressed: function(event) {
                        if (root.layoutMode === "grid" && searchField.text === "") {
                            root.moveSelection(1)
                            event.accepted = true
                        }
                    }
                    Keys.onLeftPressed: function(event) {
                        if (root.layoutMode === "grid" && searchField.text === "") {
                            root.moveSelection(-1)
                            event.accepted = true
                        }
                    }
                    Keys.onTabPressed: function(event) {
                        if (!root.settings || root.settings.launcherShowCommandsTab) {
                            root.activeTab = (root.activeTab === "apps" ? "commands" : "apps")
                        }
                        event.accepted = true
                    }
                }

                TacticalButton {
                    text: root.layoutMode === "grid" ? "GRID" : "LIST"
                    iconName: "grid"
                    active: root.layoutMode === "grid"
                    variant: root.layoutMode === "grid" ? "primary" : "default"
                    implicitWidth: 74
                    implicitHeight: Tokens.controlHeightLg
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        root.layoutMode = (root.layoutMode === "list" ? "grid" : "list")
                        searchField.focusInput()
                    }
                }

                TacticalButton {
                    text: "APPS"
                    active: !root.commandModeActive
                    variant: !root.commandModeActive ? "primary" : "default"
                    implicitWidth: 68
                    implicitHeight: Tokens.controlHeightLg
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        root.activeTab = "apps"
                        if (searchField.text.trim().indexOf(">") === 0) {
                            searchField.text = ""
                        }
                        searchField.focusInput()
                    }
                }

                TacticalButton {
                    visible: !root.settings || root.settings.launcherShowCommandsTab
                    text: "CMDS"
                    active: root.commandModeActive
                    variant: root.commandModeActive ? "primary" : "default"
                    implicitWidth: visible ? 68 : 0
                    implicitHeight: Tokens.controlHeightLg
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        root.activeTab = "commands"
                        searchField.focusInput()
                    }
                }
            }

            // Inline Calculator / Unit Converter / Hex Color Banner OR '@' Clipboard Shortcut
            Rectangle {
                visible: root.inlineComputation !== null || searchField.text.trim() === "@"
                Layout.fillWidth: true
                height: visible ? 52 : 0
                color: Tokens.surfaceElevated
                border.width: Tokens.focusBorderWidth
                border.color: Tokens.signal

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Tokens.spaceSm
                    anchors.rightMargin: Tokens.spaceSm
                    spacing: Tokens.spaceSm

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: (root.inlineComputation && root.inlineComputation.swatchHex !== "" && Tokens.isValidHexColor(root.inlineComputation.swatchHex))
                            ? root.inlineComputation.swatchHex
                            : Tokens.signal
                        border.width: Tokens.borderWidth
                        border.color: Tokens.text

                        TacticalIcon {
                            visible: !(root.inlineComputation && root.inlineComputation.swatchHex !== "")
                            anchors.centerIn: parent
                            iconName: searchField.text.trim() === "@" ? "clipboard" : "palette"
                            iconSize: 16
                            color: Tokens.textOnSignal
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: searchField.text.trim() === "@"
                                ? "OPEN CLIPBOARD VAULT (CLIPHIST)"
                                : (root.inlineComputation ? root.inlineComputation.title : "")
                            color: Tokens.signal
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontBody
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: searchField.text.trim() === "@"
                                ? "PRESS [ENTER] TO JUMP TO SAVED CLIPBOARD ENTRIES"
                                : (root.inlineComputation ? root.inlineComputation.detail : "")
                            color: Tokens.muted
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                            elide: Text.ElideRight
                        }
                    }

                    StatusPill {
                        text: searchField.text.trim() === "@" ? "CLIP" : (root.inlineComputation ? root.inlineComputation.kind : "CALC")
                        tone: "signal"
                    }

                    TacticalButton {
                        text: searchField.text.trim() === "@" ? "OPEN" : "COPY"
                        variant: "primary"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            if (searchField.text.trim() === "@") {
                                if (root.launcher) root.launcher.runSafeCommand("open-clipboard")
                                root.safeCommandTriggered("open-clipboard")
                                root.closeRequested()
                            } else {
                                root.copyComputationResult()
                            }
                        }
                    }
                }
            }

            // Results list or empty/error state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                EmptyState {
                    anchors.fill: parent
                    visible: root.filteredItems.length === 0 && root.inlineComputation === null && searchField.text.trim() !== "@"
                    code: !(root.launcher && root.launcher.available) ? "OFFLINE" : "NO MATCH"
                    title: !(root.launcher && root.launcher.available)
                        ? "LAUNCHER INDEX UNAVAILABLE"
                        : ("NO " + (!root.commandModeActive ? "APPLICATIONS" : "COMMANDS") + " MATCHED")
                    detail: !(root.launcher && root.launcher.available)
                        ? (root.launcher ? root.launcher.errorMessage : "Service not initialized")
                        : "TRY A DIFFERENT QUERY OR PRESS [TAB] FOR SAFE COMMANDS"
                    iconName: "search"
                    alertTone: !(root.launcher && root.launcher.available)
                }

                ListView {
                    id: resultList
                    anchors.fill: parent
                    visible: root.filteredItems.length > 0 && root.layoutMode === "list"
                    model: root.filteredItems
                    clip: true
                    spacing: Tokens.spaceXs
                    currentIndex: root.selectedIndex

                    delegate: Rectangle {
                        id: rowDel
                        required property var modelData
                        required property int index
                        readonly property bool isSelected: rowDel.index === root.selectedIndex
                        readonly property bool isHovered: rowMouse.containsMouse

                        width: resultList.width
                        height: 48
                        color: rowDel.isSelected ? Tokens.surfaceElevated : (rowDel.isHovered ? Tokens.surfacePressed : Tokens.background)
                        border.width: rowDel.isSelected ? Tokens.focusBorderWidth : Tokens.borderWidth
                        border.color: rowDel.isSelected ? Tokens.signal : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceSm
                            spacing: Tokens.spaceSm

                            // Left icon badge
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                color: rowDel.isSelected ? Tokens.signal : Tokens.surface
                                border.width: Tokens.borderWidth
                                border.color: rowDel.isSelected ? Tokens.signal : Tokens.border

                                TacticalIcon {
                                    anchors.centerIn: parent
                                    iconName: root.commandModeActive ? "terminal" : root.iconForEntry(rowDel.modelData)
                                    iconSize: 16
                                    color: rowDel.isSelected ? Tokens.textOnSignal : Tokens.signal
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: root.commandModeActive ? (rowDel.modelData.title || "") : (rowDel.modelData.name || "")
                                    color: rowDel.isSelected ? Tokens.signal : Tokens.text
                                    font.family: Tokens.fontUi
                                    font.pixelSize: Tokens.fontBody
                                    font.bold: rowDel.isSelected
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: root.commandModeActive
                                        ? (rowDel.modelData.detail || "")
                                        : ((rowDel.modelData.genericName || "") + " // " + (rowDel.modelData.execDisplay || ""))
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    elide: Text.ElideRight
                                }
                            }

                            StatusPill {
                                visible: !root.commandModeActive && root.isRecent(rowDel.modelData.id) && searchField.text === ""
                                Layout.preferredWidth: visible ? implicitWidth : 0
                                text: "RECENT"
                                tone: "signal"
                            }

                            StatusPill {
                                visible: !root.commandModeActive
                                Layout.preferredWidth: visible ? implicitWidth : 0
                                text: rowDel.modelData.category || "APP"
                                tone: "neutral"
                            }

                            TacticalIcon {
                                visible: rowDel.isSelected
                                iconName: "chevron-right"
                                iconSize: 14
                                color: Tokens.signal
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.handlePointerHover(rowDel.index, rowMouse, mouseX, mouseY, false)
                            onPositionChanged: function(mouse) { root.handlePointerHover(rowDel.index, rowMouse, mouse.x, mouse.y, true) }
                            onClicked: {
                                root.selectedIndex = rowDel.index
                                root.activateCurrent()
                            }
                        }
                    }
                }

                // Marathon Runner Inventory Matrix Mode (2-column Vault / Implant Slot Grid)
                GridView {
                    id: resultGrid
                    anchors.fill: parent
                    visible: root.filteredItems.length > 0 && root.layoutMode === "grid"
                    model: root.filteredItems
                    clip: true
                    cellWidth: Math.floor(width / 2)
                    cellHeight: 86
                    currentIndex: root.selectedIndex

                    delegate: Item {
                        id: gridCellWrap
                        required property var modelData
                        required property int index
                        readonly property bool isSelected: gridCellWrap.index === root.selectedIndex
                        readonly property bool isHovered: gridMouse.containsMouse
                        readonly property bool isMru: !root.commandModeActive && root.isRecent(gridCellWrap.modelData.id)

                        width: resultGrid.cellWidth
                        height: resultGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            color: gridCellWrap.isSelected ? Tokens.surfaceElevated : (gridCellWrap.isHovered ? Tokens.surfacePressed : Tokens.background)
                            border.width: gridCellWrap.isSelected ? Tokens.focusBorderWidth : Tokens.borderWidth
                            border.color: gridCellWrap.isSelected ? Tokens.text : Tokens.border

                            // Edge-to-edge Full-Bleed Top Slot Header Strip (like Marathon Vault/Implant items)
                            Rectangle {
                                id: slotTopStrip
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 18
                                color: gridCellWrap.isSelected ? Tokens.signal : (gridCellWrap.isMru ? Tokens.signalMuted : Tokens.surfacePressed)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Tokens.spaceXs
                                    anchors.rightMargin: Tokens.spaceXs
                                    spacing: Tokens.spaceXs

                                    Text {
                                        text: "¤ " + ((gridCellWrap.index + 1) * 65 + (gridCellWrap.isMru ? 120 : 0))
                                        color: (gridCellWrap.isSelected || gridCellWrap.isMru) ? Tokens.textOnSignal : Tokens.text
                                        font.family: Tokens.fontMono
                                        font.pixelSize: Tokens.fontMicro
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: "// " + (root.commandModeActive ? "SAFE" : (gridCellWrap.modelData.category || "APP"))
                                        color: (gridCellWrap.isSelected || gridCellWrap.isMru) ? Tokens.textOnSignal : Tokens.muted
                                        font.family: Tokens.fontMono
                                        font.pixelSize: Tokens.fontMicro
                                        elide: Text.ElideRight
                                    }

                                    // 2x2 Pixel-Matrix Dither Cluster (from Marathon Vault item cards)
                                    Grid {
                                        columns: 2
                                        spacing: 1
                                        Repeater {
                                            model: 4
                                            delegate: Rectangle {
                                                width: 3
                                                height: 3
                                                color: (gridCellWrap.isSelected || gridCellWrap.isMru) ? Tokens.textOnSignal : Tokens.muted
                                            }
                                        }
                                    }
                                }
                            }

                            // Main module icon + title row below full-bleed header
                            RowLayout {
                                anchors.top: slotTopStrip.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: Tokens.spaceSm
                                spacing: Tokens.spaceSm

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    color: gridCellWrap.isSelected ? Tokens.signal : Tokens.surface
                                    border.width: Tokens.borderWidth
                                    border.color: gridCellWrap.isSelected ? Tokens.signal : Tokens.borderStrong

                                    TacticalIcon {
                                        anchors.centerIn: parent
                                        iconName: root.commandModeActive ? "terminal" : root.iconForEntry(gridCellWrap.modelData)
                                        iconSize: 16
                                        color: gridCellWrap.isSelected ? Tokens.textOnSignal : Tokens.signal
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        Layout.fillWidth: true
                                        text: (root.commandModeActive ? (gridCellWrap.modelData.title || "") : (gridCellWrap.modelData.name || "")).toUpperCase()
                                        color: gridCellWrap.isSelected ? Tokens.text : Tokens.text
                                        font.family: Tokens.fontUi
                                        font.pixelSize: Tokens.fontBody
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.commandModeActive
                                            ? (gridCellWrap.modelData.detail || "")
                                            : (gridCellWrap.modelData.execDisplay || "")
                                        color: gridCellWrap.isSelected ? Tokens.signal : Tokens.muted
                                        font.family: Tokens.fontMono
                                        font.pixelSize: Tokens.fontMicro
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            // Marathon Selection Reticle Corner Brackets ([   ] from Vault cursor)
                            Rectangle { visible: gridCellWrap.isSelected; width: 10; height: 2; color: Tokens.text; anchors.bottom: parent.bottom; anchors.left: parent.left }
                            Rectangle { visible: gridCellWrap.isSelected; width: 2; height: 10; color: Tokens.text; anchors.bottom: parent.bottom; anchors.left: parent.left }
                            Rectangle { visible: gridCellWrap.isSelected; width: 10; height: 2; color: Tokens.text; anchors.bottom: parent.bottom; anchors.right: parent.right }
                            Rectangle { visible: gridCellWrap.isSelected; width: 2; height: 10; color: Tokens.text; anchors.bottom: parent.bottom; anchors.right: parent.right }

                            MouseArea {
                                id: gridMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.handlePointerHover(gridCellWrap.index, gridMouse, mouseX, mouseY, false)
                                onPositionChanged: function(mouse) { root.handlePointerHover(gridCellWrap.index, gridMouse, mouse.x, mouse.y, true) }
                                onClicked: {
                                    root.selectedIndex = gridCellWrap.index
                                    root.activateCurrent()
                                }
                            }
                        }
                    }
                }
            }

            // Footer keyboard hint bar with Marathon Keycap Badges ([Q] [E] [ESC])
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                Repeater {
                    model: [
                        { key: root.layoutMode === "grid" ? "↑↓←→" : "↑↓", label: "SELECT" },
                        { key: "ENTER", label: "DEPLOY" },
                        { key: "TAB", label: "APPS/CMDS" },
                        { key: "ESC", label: "BACK" }
                    ]
                    delegate: Row {
                        id: hintDel
                        required property var modelData
                        spacing: 4

                        Rectangle {
                            width: keyTxt.implicitWidth + 8
                            height: 16
                            color: Tokens.keycapBg
                            border.width: 1
                            border.color: Tokens.borderStrong

                            Text {
                                id: keyTxt
                                anchors.centerIn: parent
                                text: hintDel.modelData.key
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: hintDel.modelData.label
                            color: Tokens.muted
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: root.launcher && root.launcher.lastActionNote !== ""
                    text: root.launcher ? root.launcher.lastActionNote : ""
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                }
            }
        }
    }
}
