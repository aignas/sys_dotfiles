-- Smapi battery widget
-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment

local setmetatable = setmetatable
local tostring = tostring
local tonumber = tonumber
local string = string
local math = math

local io = require('io')

local theme = require('beautiful').get()
local naughty = require('naughty')
local awful = require('awful')
local wibox = require('wibox')

local capi = {
    awesome = awesome,
    timer = timer
}
--}}}

smapi = { mt = {} }

--{{{ Config
-- Make an empty table for the smapi commands
smapi.cfg = setmetatable({}, { __mode = 'k' })

-- Some aliases to ease my life
smapi.cfg = {
    timeout = 30
}

local current = {
    state = '',
    percent = ''
}


--}}}

--{{{ Some common functions

-- This is a helper function, which just reads the files
local function smapi_read (bat, file)
    local bat = tostring(bat) or 0
    local file = file or 'remaining_percent'
    local dir = '/sys/devices/platform/smapi/BAT' .. bat .. '/'
    -- Default value if an error happens
    local f = assert(io.open(dir .. file, 'r'))

    -- read only existing files
    if f then 
        r = f:read()
        f:close()
        -- return the value
        return r
    end

    return false 
end

---
-- function to define a colormap depending on the given value
-- {val, min, max} these are the appropriate values
---
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
--[

local warning = {}

---
-- This is a local function which just prints of a warning if the battery level
-- is too low
---
function warning.low_batt ( percent )
    if n then naughty.destroy(n) end
    local percent = ('(' .. percent .. '%)') or ''
    local text = 'Please <b>plug in</b> into a power socket or it will turn off soon.'

    n = naughty.notify({
        title = 'Battery level is critical' .. percent,
        text = awful.util.linewrap(text, 30),
        preset = naughty.config.presets.critical
    })
end

---
-- This is an update function for the widget which updates the widget itself and
-- then it issues a warning in case the battery level is too low.
---
local update = function (mybat, mytext)
    local r = smapi_read(0, 'remaining_percent')
    local state = smapi_read(0, 'state')
    
    if not r or not state then return false end

    if tonumber(r) < 10
        and state ~= 'charging' then
        warning.low_batt(r)
    end

    -- Shorten the state string and insert some cool utf-8 characters
    if state == 'idle' then
        state = ''
    elseif state == 'charging' then
        state = '⇧'
    elseif state == 'discharging' then
        state = '⚡'
    end

    local r_old = current.percent
    local state_old = current.state

    if r ~= r_old 
        or state_old ~= state then
        mytext:set_text(state) 
        mybat:set_value(r) 
        mybat:set_color(color({min=0,max=100,val=r}))
        current.percent = r
        current.state = state
    end

    return true
end

smapi.new = function (cfg)
    -- The config will be either the passed or the default one.
    local cfg = cfg or smapi.cfg

    -- Initialize the battery itself
    mybat = awful.widget.progressbar({
        width = 6,
        height = 14
    })
    mybat:set_background_color('#000000')
    mybat:set_vertical(true)
    mybat:set_max_value(100)
    mybat:set_ticks(true)
    mybat:set_ticks_gap(1)
    mybat:set_ticks_size(2)

    mytext = wibox.widget.textbox()
    mytext:set_text('%%%')

    local w = wibox.layout.fixed.horizontal()
    w:add(wibox.layout.margin(mybat, 2, 2, 2, 2)) -- w, l, r, t, b
    w:add(wibox.layout.margin(mytext, 2, 1, 4, 2)) -- w, l, r, t, b

    -- update the widget
    update (mybat, mytext)

    -- Register all of the timers with the functions
    local timer = capi.timer { timeout = cfg.timeout }
    timer:connect_signal("timeout", function() update(mybat, mytext) end)
    timer:start()
    timer:emit_signal("timeout")

    -- return the widget
    return w
end

--]]
--}}}


-- Set the metatable, like other awful widgets and return it
function smapi.mt:__call(...)
    return smapi.new(...)
end

return setmetatable(smapi, smapi.mt)

-- ft - filetype
-- et - expandtab
-- sw - shiftwidth
-- ts - tabstop
-- sts - shifttabstop
-- tw - textwidth
-- fdm - foldmethod
-- vim: ft=lua:et:sw=4:ts=8:sts=4:tw=80:fdm=marker
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
