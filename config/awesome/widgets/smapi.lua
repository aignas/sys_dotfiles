-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment
local awful = require('awful')
local naughty = require('naughty')
local capi = {
    awesome = awesome,
    timer = timer,
    wibox = wibox
}

local ipairs = ipairs
local io = require('io')
local print = print
local tostring = tostring
local type = type
--}}}

module('smapi')

--{{{ Some common functions

function s_read (bat, file)
    local bat = tostring(bat) or 0
    local file = file or 'remaining_percent'
    local f = io.open('/sys/devices/platform/smapi/BAT'..bat..'/'..file, r)
    local r = f:read()
    f:close()
    return r
end

--}}}

--{{{ Decorations for the progress bar
--[[
-- Need a line for the top, bottom and sides.
local dectop = 
--]]
--}}}

--{{{ Widget

mytext = capi.wibox.widget.textbox()
mytext:set_text(' %%%')

myprog = awful.widget.progressbar({
    width = 4,
    height = 10
})
myprog:set_background_color('#3f3f3f')
myprog:set_color('#4cdcdc')
myprog:set_vertical(true)
myprog:set_max_value(100)
--myprog:set_ticks(true)
--myprog:set_ticks_gap(1)
--myprog:set_ticks_size(4)

local all_widgets = capi.wibox.layout.fixed.horizontal()
all_widgets:add(myprog)
all_widgets:add(mytext)

mywilayout = capi.wibox.layout.margin()
mywilayout:set_widget(all_widgets)
mywilayout:set_right(2)
mywilayout:set_left(2)
mywilayout:set_top(2)
mywilayout:set_bottom(2)

mywi = mywilayout

--}}}

--{{{ Timer

timer = capi.timer { timeout = 30 }
timer:connect_signal("timeout", 
    function() 
        local r = s_read(0,'remaining_percent')
        mytext:set_text(' '..r..'%') 
        myprog:set_value(r) 
    end)
timer:start()
timer:emit_signal("timeout")

--}}}
