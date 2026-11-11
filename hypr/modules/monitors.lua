-- ==============================================================================
-- MARATHON Tactical — Multi-Monitor Topology & Hotplug Catch-All (Lua API)
-- ==============================================================================
-- Catch-all preferred mode guarantees hotplugged and mixed-DPI monitors work
-- out of the box without hardcoding machine-specific connector names.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- Optional workstation overrides (discover real connector names via `hyprctl monitors all`):
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "1920x0", scale = 1 })
--
-- Multi-monitor workspace binding examples:
-- hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
-- hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })
-- hl.workspace_rule({ workspace = "3", monitor = "eDP-1" })
-- hl.workspace_rule({ workspace = "4", monitor = "eDP-1" })
-- hl.workspace_rule({ workspace = "5", monitor = "eDP-1" })
-- hl.workspace_rule({ workspace = "6", monitor = "DP-2", default = true })
-- hl.workspace_rule({ workspace = "7", monitor = "DP-2" })
-- hl.workspace_rule({ workspace = "8", monitor = "DP-2" })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

