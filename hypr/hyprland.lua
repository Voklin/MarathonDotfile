-- ==============================================================================
-- MARATHON Tactical — Isolated Hyprland Lua Profile Entrypoint
-- ==============================================================================
-- Target Syntax: Modern Hyprland Lua configuration (`hyprland.lua`, `hl.*` API).
--
-- Launch safely WITHOUT overwriting ~/.config/hypr/:
--   Hyprland --config ~/.config/marathon-tactical/hypr/hyprland.lua
-- Status on Windows dev host: NOT RUN — requires CachyOS
-- ==============================================================================

local home = os.getenv("HOME") or "/tmp"
local xdg_config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local marathon_dir = xdg_config .. "/marathon-tactical"

local info = debug.getinfo(1, "S")
local source_path = (info and info.source) and info.source:match("^@(.+)$") or ""
local hypr_dir = source_path:match("^(.+)/[^/]+$") or (marathon_dir .. "/hypr")

package.path = hypr_dir .. "/?.lua;" .. package.path

_G.MARATHON = {
    dir = marathon_dir,
    hyprDir = hypr_dir,
    apps = {
        terminal = "ghostty",
        terminalFallback = "alacritty",
        fileManager = "dolphin",
        browser = "firefox",
        editor = "nvim",
        mediaPlayer = "mpv",
        imageViewer = "imv",
        pdfViewer = "zathura",
        systemMonitor = "btop",
        menuLauncher = "qs ipc call marathon toggleLauncher",
    },
}

require("modules.env")
require("modules.monitors")
require("modules.input")
require("modules.appearance")
require("modules.animations")
require("modules.rules")
require("modules.binds")
require("modules.autostart")
require("user-settings")

