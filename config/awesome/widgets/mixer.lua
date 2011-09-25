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

local tostring = tostring
local type = type
local os = require('os')
--}}}

module('mixer')

--{{{ Some common functions

function launch_mixer()
    local exec = awful.util.spawn_with_shell
    exec("urxvt -title volume::mixer -e alsamixer && "..os.getenv("HOME").."/bin/amixer get_levels")
end


--}}}

--{{{ Widget

mywidget = awful.widget.progressbar()
mywidget:set_vertical(false)
mywidget:set_width(25)
mywidget:set_height(7)
mywidget:set_color('#dcdcdc')
mywidget:set_background_color('#3f3f3f')

awful.util.spawn(os.getenv("HOME").."/bin/amixer get_levels")

mywidget:set_ticks(true)
mywidget:set_ticks_gap(1)
mywidget:set_ticks_size(4)
mywidget:buttons(awful.util.table.join(awful.button({}, 1, function() launch_mixer() end)))

mywilayout = capi.wibox.layout.margin()
mywilayout:set_widget(mywidget)
mywilayout:set_right(2)
mywilayout:set_left(2)
mywilayout:set_top(2)
mywilayout:set_bottom(2)

mywi = mywilayout

mixerstate = false

--{{{ Timer

--}}}
