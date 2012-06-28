-- OSD for awesome

-- Grab the environment

local awful = require("awful")
local naughty = require("naughty")
local capi = {
    awesome = awesome,
    mouse = mouse,
    screen = screen
}

local print = print
local pairs = pairs

module('osd')

-- Try to put a notification in the middle of the screen

function notify(args)
    local text = args.text or ""
    local s = capi.screen[capi.mouse.screen] or args.screen
    local wr = s.workarea

    local offset = {
        x = wr.width/2,
        y = wr.height/2
    }

    notification = naughty.notify({text = text})
    notification.box:geometry({ 
        x = offset.x - notification.box.width/2,
        y = offset.y - notification.box.height/2
    })
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:foldmethod=marker
