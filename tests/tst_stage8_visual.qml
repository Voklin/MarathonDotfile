import QtQuick
import QtTest
import "../ui/tokens"
import "../ui/components"
import "../preview/mocks"

Item {
    id: testRoot
    width: 1200
    height: 800

    MockBackend {
        id: backend
    }

    TacticalIcon {
        id: iconProbe
        iconName: "chevron-left"
        iconSize: 16
    }

    LockScreenOverlay {
        id: lockScreen
        anchors.fill: parent
        session: backend.session
        appearance: backend.appearance
        reducedMotion: backend.appearance.reducedMotion
    }

    TestCase {
        id: tc
        name: "MarathonStage8VisualAndAssetsSuite"
        when: windowShown

        function test_tokens_font_resolution_and_icon_probe() {
            verify(Tokens.fontUi.length > 0)
            verify(Tokens.fontMono.length > 0)
            compare(iconProbe.iconName, "chevron-left")
            compare(iconProbe.implicitWidth, 16)
            compare(iconProbe.implicitHeight, 16)
        }

        function test_lock_screen_reduced_motion_and_auth_cycle() {
            backend.resetDefaults()
            backend.appearance.reducedMotion = true
            compare(Tokens.motionMs(Tokens.durationPanel, backend.appearance.reducedMotion), 0)

            compare(lockScreen.lockActive, false)
            backend.session.lock()
            wait(20)
            compare(lockScreen.lockActive, true)
            verify(lockScreen.visible)

            verify(!backend.session.unlock(""))
            verify(backend.session.authError.length > 0)
            compare(lockScreen.lockActive, true)

            verify(backend.session.unlock("marathon"))
            wait(20)
            compare(lockScreen.lockActive, false)
        }

        function test_corporate_faction_palettes() {
            Tokens.setFaction("CYBERACME")
            compare(Tokens.factionId, "CYBERACME")
            compare(Tokens.signal.toString(), "#00f0ff")

            Tokens.setFaction("TRAXUS")
            compare(Tokens.factionId, "TRAXUS")
            compare(Tokens.signal.toString(), "#ff8800")

            Tokens.setFaction("SEKIGUCHI")
            compare(Tokens.factionId, "SEKIGUCHI")
            compare(Tokens.signal.toString(), "#39ff88")

            Tokens.setFaction("RUNNER")
            compare(Tokens.factionId, "RUNNER")
            compare(Tokens.signal.toString(), "#c9ff16")
        }

        function test_runner_emblem_calling_card_system() {
            compare(Tokens.emblems.length, 6)
            Tokens.setEmblem("S50_BOWTIE")
            compare(Tokens.emblemId, "S50_BOWTIE")
            compare(Tokens.activeEmblem.motif, "bowtie")

            Tokens.cycleEmblem()
            compare(Tokens.emblemId, "M03_HEXCORE")
            compare(Tokens.activeEmblem.motif, "hexcore")

            Tokens.setRunnerName("VOKLIN")
            Tokens.setRunnerTitle("ARCHITECT")
            compare(Tokens.runnerName, "VOKLIN")
            compare(Tokens.runnerTitle, "ARCHITECT")

            Tokens.setEmblem("U73_CRUCIFORM")
            Tokens.setRunnerName("RUNNER")
            Tokens.setRunnerTitle("OPERATOR")
            compare(Tokens.emblemId, "U73_CRUCIFORM")
            compare(Tokens.runnerName, "RUNNER")
            compare(Tokens.runnerTitle, "OPERATOR")
        }
    }
}
