-- Mixer widget
-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment


local awful = require('awful')
local naughty = require('naughty')
local capi = {
    awesome = awesome,
    mouse = mouse,
    timer = timer,
    unpack = unpack,
    wibox = wibox
}
local os = os
local string = string

local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell

--}}}

module('mounter')

--{{{ Config
cfg = {}
cfg.mypromptbox = {}
--}}}

--{{{ Some common functions

function traydevice(prompt)
    local device_name = ""
    local mypromptbox = prompt or cfg.mypromptbox
    awful.prompt.run({ 
      prompt = "Mount: " 
    }, mypromptbox[capi.mouse.screen].widget,
    function (...) 
      mypromptbox[capi.mouse.screen].text = exec("traydevice /dev/" .. capi.unpack(arg), false)
    end,
    awful.completion.shell, awful.util.getdir("cache") .. "/mount-history",
    50)
end

--}}}
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
