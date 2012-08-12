-- Smapi battery widget
-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment


local awful = require('awful')
local wibox = require('wibox')
local capi = {
    awesome = awesome,
    timer = timer
}

local io = require('io')
local tostring = tostring
local string = string
local math = math
local tonumber = tonumber
--}}}

local smapi = { mt = {} }

--{{{ Config
--cfg = {}
--}}}

--{{{ Some common functions

local function s_read (bat, file)
    local bat = tostring(bat) or 0
    local file = file or 'remaining_percent'
    local f = io.open('/sys/devices/platform/smapi/BAT'..bat..'/'..file, r)
    local r = "err"
    -- read only existing files
    if f then 
        r = f:read()
        f:close()
    end
    return r
end

local function color(args)
  val = tonumber(args.val)
  min = tonumber(args.min)
  max = tonumber(args.max)
  c_start  = args.color or { 233,66,66 }
  c_finish = args.to_color or { 77,233,66 }
  f = val/(max - min) - .5

  r_diff = c_finish[1] - c_start[1]
  g_diff = c_finish[2] - c_start[2]
  b_diff = c_finish[3] - c_start[3]

  -- calculate rgb values
  r_v = c_start[1] + r_diff * (math.sin(f*math.pi)+1)/2
  g_v = c_start[2] + g_diff * (math.sin(f*math.pi)+1)/2
  b_v = c_start[3] + b_diff * (math.sin(f*math.pi)+1)/2

  -- do some string magic
  return string.format("#%02x%02x%02x", r_v, g_v, b_v)
end

--}}}

--{{{ Widget

-- Initialize the top of the battery, which is just a static progressbar
local mybat = {}
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
mybat.l_top = wibox.layout.margin(
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
mybat.wi = wibox.layout.fixed.vertical()
mybat.wi:add(mybat.l_top)
mybat.wi:add(mybat.bot)

-- Add some margins
mybat.l_wi = wibox.layout.margin(
  mybat.wi,     -- widget to use
  2,0,2,2       -- l,r,t,b
)

local mytext = {}
mytext.wi = wibox.widget.textbox()
mytext.wi:set_text('%%%')
mytext.l_wi = wibox.layout.margin(
  mytext.wi,    -- widget to use
  2,1,2,2       -- l,r,t,b
)

local all_wi = wibox.layout.fixed.horizontal()
all_wi:add(mybat.l_wi)
all_wi:add(mytext.l_wi)

mywi = all_wi
prev_r = ""

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

return smapi

--}}}
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
