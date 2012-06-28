-- Smapi battery widget
-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment


local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')
local capi = {
    awesome = awesome,
    timer = timer,
    wibox = wibox
}
local vicious = require(vicious)
local vicious.contrib = require("vicious.contrib")

local io = require('io')
local tostring = tostring
local string = string
local math = math
local tonumber = tonumber
local img = oocairo.image_surface_create_from_png
local cfgdir = awful.util.getdir("config")
local sexec  = awful.util.spawn_with_shell
--}}}

module('smapi')

--{{{ Some common functions
function color(args)
  val = tonumber(args.val)
  min = tonumber(args.min)
  max = tonumber(args.max)
  c_start  = args.color or { 233,66,66 }
  c_finish = args.to_color or { 77,233,66 }
  f = val/(max - min) - .5

  r_diff = c_finish[1] - c_start[1]
  g_diff = c_finish[2] - c_start[2]
  b_diff = c_finish[3] - c_start[3]

  r_v = c_start[1] + r_diff * (math.sin(f*math.pi)+1)/2
  g_v = c_start[2] + g_diff * (math.sin(f*math.pi)+1)/2
  b_v = c_start[3] + b_diff * (math.sin(f*math.pi)+1)/2

  return string.format("#%02x%02x%02x", r_v, g_v, b_v)
end

--}}}

--{{{ Widget

-- Initialize the top of the battery, which is just a static progressbar
mybat = {}
mybat.top = awful.widget.progressbar({
  width = 5,
  height = 1
})
mybat.top:set_background_color('#000000')
mybat.top:set_color('#797979')
mybat.top:set_vertical(true)
mybat.top:set_max_value(100)
mybat.top:set_value(100)
-- Add some margins to the widget
mybat.l_top = capi.wibox.layout.margin(
  mybat.top,    -- widget to use
  2,2,0,1       -- l,r,t,b
)

-- Initialize the battery itself
mybat.bot = awful.widget.progressbar({
  width = 8,
  height = 12
})
mybat.bot:set_background_color('#000000')
mybat.bot:set_vertical(true)
mybat.bot:set_max_value(100)
mybat.bot:set_ticks(true)
mybat.bot:set_ticks_gap(1)
mybat.bot:set_ticks_size(2)

-- Assemble the two progressbars to make up a battery.
mybat.wi = capi.wibox.layout.fixed.vertical()
mybat.wi:add(mybat.l_top)
mybat.wi:add(mybat.bot)

-- Add some margins
mybat.l_wi = capi.wibox.layout.margin(
  mybat.wi,     -- widget to use
  2,0,2,2       -- l,r,t,b
)

mytext = {}
mytext.wi = capi.wibox.widget.textbox()
mytext.wi:set_text('%%%')
mytext.l_wi = capi.wibox.layout.margin(
  mytext.wi,    -- widget to use
  2,1,2,2       -- l,r,t,b
)

local all_wi = capi.wibox.layout.fixed.horizontal()
all_wi:add(mybat.l_wi)
all_wi:add(mytext.l_wi)

mywi = all_wi
prev_r = ""

local theme = beautiful.get()

--}}}

--{{{ Timer

timer = capi.timer { timeout = 30 }
timer:connect_signal("timeout", 
    function() 
        local r = s_read(0,'remaining_percent')
        local r_old = prev_r
        if r~=r_old then
            mytext.wi:set_text(r..'%') 
            mybat.bot:set_value(r) 
            mybat.bot:set_color(color({min=0,max=100,val=r}))
            prev_r = r
        end
    end)
timer:start()
timer:emit_signal("timeout")

--}}}
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
