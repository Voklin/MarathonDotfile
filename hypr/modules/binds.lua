-- ==============================================================================
-- MARATHON Tactical — Keybindings & Safe Launcher Activation (Lua API)
-- ==============================================================================
-- Synced with docs/KEYBINDINGS.md
-- Safety Policy: Bare single-key Super interception is NOT enabled by default so
-- Super+* tiling chords never break unverified. Super+Space and Super+D are safe
-- defaults; optional bare-Super release is documented below for CachyOS tests.

local M = _G.MARATHON or { apps = {} }

-- --- Core Fallback Controls (independent of Quickshell health) ---
hl.bind("SUPER + Return", function()
    hl.exec_cmd(M.apps.terminal or "ghostty")
end)
hl.bind("SUPER + SHIFT + Return", function()
    hl.exec_cmd(M.apps.terminalFallback or "alacritty")
end)
hl.bind("SUPER + E", function()
    hl.exec_cmd(M.apps.fileManager or "dolphin")
end)
hl.bind("SUPER + B", function()
    hl.exec_cmd(M.apps.browser or "firefox")
end)
hl.bind("SUPER + T", function()
    hl.exec_cmd((M.apps.terminal or "ghostty") .. " -e yazi")
end)
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + S", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- --- MARATHON Tactical Shell Overlays (GlobalShortcut + Safe Fallbacks) ---
hl.bind("SUPER + comma", hl.dsp.global("marathon-tactical:settings"))
hl.bind("SUPER + Space", hl.dsp.global("marathon-tactical:launcher"))
hl.bind("SUPER + D", hl.dsp.global("marathon-tactical:launcher"))
hl.bind("SUPER + C", hl.dsp.global("marathon-tactical:control-center"))
hl.bind("SUPER + N", hl.dsp.global("marathon-tactical:notifications"))
hl.bind("SUPER + X", hl.dsp.global("marathon-tactical:session"))
hl.bind("SUPER + SHIFT + E", hl.dsp.global("marathon-tactical:session"))
hl.bind("SUPER + SHIFT + V", hl.dsp.global("marathon-tactical:clipboard"))
hl.bind("Print", hl.dsp.global("marathon-tactical:capture"))
hl.bind("SUPER + SHIFT + S", hl.dsp.global("marathon-tactical:capture"))
hl.bind("SUPER + M", hl.dsp.global("marathon-tactical:sysmon"))
hl.bind("SUPER + A", hl.dsp.global("marathon-tactical:calendar"))
hl.bind("SUPER + slash", hl.dsp.global("marathon-tactical:cheatsheet"))
hl.bind("SUPER + F1", hl.dsp.global("marathon-tactical:cheatsheet"))
hl.bind("SUPER + SHIFT + N", hl.dsp.global("marathon-tactical:nightlight"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock --config ~/.config/marathon-tactical/hypr/hyprlock.conf"))

-- Optional bare-Super release trigger (enable ONLY after testing Super+* chords on CachyOS):
-- hl.bind("SUPER + SUPER_L", hl.dsp.global("marathon-tactical:launcher"), { release = true })

-- --- Focus Movement (Vim + Arrow keys; bracketright handles focus-right since Super+L is lock) ---
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + bracketright", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + bracketleft", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

-- --- Move Windows Across Tile Grid ---
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- --- Resize Active Window ---
hl.bind("SUPER + ALT + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

-- --- Workspaces (1..9) ---
for i = 1, 9 do
    local ws = tostring(i)
    hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- Cycle active monitor workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- --- Mouse Drag Move & Resize ---
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- Audio & Backlight Hardware Keys (PipeWire + brightnessctl + OSD signal) ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+ && qs ipc call marathon refreshBrightnessOsd"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%- && qs ipc call marathon refreshBrightnessOsd"), { repeating = true, locked = true })

-- --- Emergency Shell Reload / Exit (always works even if UI hangs) ---
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("bash ~/.config/marathon-tactical/scripts/shell-ctl.sh restart"))
hl.bind("SUPER + SHIFT + CTRL + BackSpace", hl.dsp.exit())

