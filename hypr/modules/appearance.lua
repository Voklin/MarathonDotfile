-- ==============================================================================
-- MARATHON Tactical — Compositor Visual Geometry & Layout (Lua API)
-- ==============================================================================
-- Strict sharp corners (0 px rounding), 4 px inner gaps, 8 px outer inset,
-- high-contrast acid-lime focus rail (#C9FF16) against muted dark border (#1E352B).

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        ["col.active_border"] = "rgba(c9ff16ff)",
        ["col.inactive_border"] = "rgba(1e352bff)",
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        },
    },

    dwindle = {
        pseudotile = true,
        preserve_split = true,
        smart_split = false,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        background_color = "rgba(080b0aff)",
        vfr = true,
        focus_on_activate = true,
    },
})

