-- Mounting framework for awesome
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

module('network')

--{{{ Config
cfg = {}
--}}}

--[[

--- choose_ext
-- This runs a function, which will help communicate Awesome with ACPI.
function choose_ext ()
end

--- Initialize a 

--]]

--{{{ Some common functions


--}}}
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
