-- ==============================================================================
-- MARATHON Tactical — Crisp Zero-Overshoot Motion Curves (120–180 ms, Lua API)
-- ==============================================================================

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("marathonSnap", {
    type = "bezier",
    points = { { 0.2, 0.0 }, { 0.0, 1.0 } },
})

hl.curve("marathonLinear", {
    type = "bezier",
    points = { { 0.0, 0.0 }, { 1.0, 1.0 } },
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 2,
    bezier = "marathonSnap",
    style = "slide",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2,
    bezier = "marathonSnap",
    style = "popin 92%",
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 2,
    bezier = "marathonLinear",
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 2,
    bezier = "marathonSnap",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 2,
    bezier = "marathonSnap",
    style = "slide",
})

hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 2,
    bezier = "marathonSnap",
    style = "fade",
})

