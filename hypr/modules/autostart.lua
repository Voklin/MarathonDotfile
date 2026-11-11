-- ==============================================================================
-- MARATHON Tactical — Session Autostart (Isolated Profile, Lua API)
-- ==============================================================================
-- NOTE: Do NOT launch competing notification daemons (dunst / mako / swaync) here;
-- MARATHON NotificationsAdapter checks org.freedesktop.Notifications ownership first.

hl.on("hyprland.start", function()
    -- Export Wayland display variables to systemd user / dbus environment
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Start optional Wayland helper daemons safely (cliphist, hypridle, polkit) without conflicts
    hl.exec_cmd("bash ~/.config/marathon-tactical/scripts/session-daemons.sh")

    -- Start MARATHON Tactical Quickshell entrypoint
    -- Isolated lifecycle + log at ~/.local/state/marathon-tactical/quickshell.log
    hl.exec_cmd("bash ~/.config/marathon-tactical/scripts/shell-ctl.sh start")
end)

