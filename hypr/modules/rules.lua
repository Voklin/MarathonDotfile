-- ==============================================================================
-- MARATHON Tactical — Window & Layer Rules (Hyprland Lua API)
-- ==============================================================================
-- Verify installed syntax on CachyOS with `hyprctl version` (`NOT RUN — requires CachyOS`).

-- Utility & authentication dialogs float centered cleanly
hl.window_rule({
    name = "marathon-float-utilities",
    match = {
        class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol|nm-connection-editor|blueman-manager|polkit-gnome-authentication-agent-1|org\\.kde\\.polkit-kde-authentication-agent-1)$",
    },
    float = true,
    center = true,
})

-- File picker / Wayland portals
hl.window_rule({
    name = "marathon-float-portals",
    match = {
        class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)$",
    },
    float = true,
    center = true,
})

-- System monitors / TUI popouts
hl.window_rule({
    name = "marathon-float-tui-tools",
    match = {
        title = "^(marathon-btop|marathon-yazi)$",
    },
    float = true,
    center = true,
    size = "1120 720",
})

-- Image viewer & screenshot annotation float centered cleanly
hl.window_rule({
    name = "marathon-float-viewers",
    match = {
        class = "^(imv|com\\.gabm\\.satty|satty)$",
    },
    float = true,
    center = true,
})

-- Common dialog titles
hl.window_rule({
    name = "marathon-float-dialogs",
    match = {
        title = "^(Open File|Save File|Confirm|Preferences|Settings)$",
    },
    float = true,
    center = true,
})

-- Picture-in-Picture overlays stay floating & pinned
hl.window_rule({
    name = "marathon-pip",
    match = {
        title = "^(Picture-in-Picture|Picture in picture)$",
    },
    float = true,
    pin = true,
})

-- Prevent idle sleep while fullscreen video/game window is active
hl.window_rule({
    name = "marathon-fullscreen-idleinhibit",
    match = {
        fullscreen = true,
    },
    idle_inhibit = "focus",
})

-- Quickshell layer surfaces: disable compositor fade/blur so QML PanelReveal renders crisply
hl.layer_rule({
    name = "marathon-shell-layers",
    match = {
        namespace = "^marathon-(hud|launcher|control-center|notifications|toasts|session|osd|settings|clipboard|capture|sysmon|calendar|cheatsheet|backdrop)$",
    },
    no_anim = true,
    blur = false,
})

