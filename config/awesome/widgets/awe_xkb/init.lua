-- A Keyboard widget
--      ideas borrowed from the awesome wiki.
--
--{{{ Environment

local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local type = type
local io = io
local assert = assert
local string = string

local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')
local oocairo = require('oocairo')
local capi = {
    awesome = awesome,
    dbus = dbus,
    timer = timer,
    wibox = wibox
}

--}}}

module('awe_xkb')

--{{{ Configuration of the widget
-- Make an empty table for the sexkbmap commands
local cfg = setmetatable({}, { __mode = 'k' })
cfg.kbdd = {}

-- Some aliases to ease my life
cfg.defaults = {
    img_dir = awful.util.getdir("config") .. "/icons/wi_kbd",
    layout = {
        { "gb", "" },
    }
}

cfg.kbdd.dbus_addr     = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd"
cfg.kbdd.dbus_sw_cmd   = cfg.kbdd.dbus_addr .. ".set_layout uint32:"
cfg.kbdd.dbus_prev_cmd = cfg.kbdd.dbus_addr .. ".prev_layout"
cfg.kbdd.dbus_next_cmd = cfg.kbdd.dbus_addr .. ".next_layout"
cfg.img_dir = cfg.defaults.img_dir
cfg.layout = cfg.defaults.layout
cfg.setxkbmap = {layout = "", model = "", variant = ""}

--}}}

-- The notification function
notification = nil

--{{{ notify: Notify via naughty
--@param args: a table of args, which contain the layout and the variant
--             should be passed as a dictionary
local function notify(args)
    local map = args[1]
    local var = args[2]
    local nt = "Layout: " .. map

    if var ~= "" then 
        nt = nt .. "(" .. var .. ")"
    else 
        nt = nt .. "(default)"
    end

    if notification then naughty.destroy(notification) end
    notification = naughty.notify({    
        title = "XKBmap", 
        text = nt,
        --icon = capi.awesome.load_image(cfg.img_dir .."/32/" .. map .. ".png"),
        --width = 150,
        timeout = 1
    })
end
--}}}

layout = {}
--{{{layout.switch Switch to a layout
--@param: the relative id of the layout to switch to
function layout.switch(a)
    local t = cfg.layout
    if type(a)~="number" then
        a = tonumber(a)
    end
    awful.util.spawn_with_shell(cfg.kbdd.dbus_sw_cmd .. a)
    notify(t[a+1])
    set_icon(t[a+1][1])
end

--- Go to the next layout
function layout.next()
    awful.util.spawn_with_shell(cfg.kbdd.dbus_next_cmd)
end

--- Go to the previous layout
function layout.prev()
    awful.util.spawn_with_shell(cfg.kbdd.dbus_prev_cmd)
end
--}}}

--{{{layout.set Set layouts
--@param: table of indeces, which point to the global list of "available" layouts
--        e.g. {1,2,3,4} for for layouts or {2,3,1,4} for different order
function layout.set(table)
    local cmd_string = "setxkbmap"
    for i, k in pairs(setxkbmap) do
        cmd_string = cmd_string
            .. " -" .. i .. " \"" .. k .. "\""
    end

    awful.util.spawn_with_shell(cmd_string)
    cfg.layout = l
end
--}}}

--{{{
-- A function stolen from
--    http://lua-users.org/wiki/SplitJoin
function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function layout.xkb2awe()
    local f = assert(io.popen("setxkbmap -query"))
    local l,v = "", ""
    local l_t, v_t, l_all = {},{},{}
    for line in f:lines() do
        if line:match("layout") then
            l = line:sub(13)
        end
        if line:match("variant") then
            v = line:sub(13)
        end
    end
    f:close()

    l_t = Split(l,",")
    l_v = Split(v,",")

    -- Construct a layout table
    for i,layout in ipairs(l_t) do
        l_all[i] = { l_t[i], l_v[i] }
    end
    return l_all
end
--}}}

--{{{layout.menu_gen Generate a menu.
function layout.menu_gen ()
    local theme = beautiful.get()
    local menu_table = {}

    for i,k in ipairs(cfg.layout or default.layout) do
        menu_table[i] = { 
            -- Name of the layout
            k[1].." "..k[2], 
            function () layout.switch(i-1) end, 
            capi.awesome.load_image(cfg.img_dir .. "/24/" .. k[1]..".png")
        }
    end

    return awful.menu({items = menu_table})
end
--}}}

-- FIXME make incorporate in notify
--{{{set_icon Set the widgets icon
function set_icon (code)
  -- Set the icon
  widget:set_image(capi.awesome.load_image(cfg.img_dir .. "/24/" .. code .. ".png"))
end
--}}}

--{{{ new widget
-- @param-args...
function new(...)
    local args = {...}
    local theme = beautiful.get()

    -- run the kbdd daemon if it is not running  already
    awful.util.spawn_with_shell("if ! ps -A | grep -q kbdd; then kbdd; fi")
    cfg.layout = layout.xkb2awe()
    -- FIXME rewrite the function
    layout.menu = layout.menu_gen()

    -- initiate a widget
    widget = capi.wibox.widget.imagebox()
    widget:set_image(capi.awesome.load_image(cfg.img_dir .. "/24/" .. cfg.layout[1][1] .. ".png"))
    -- Do some widget formatting
    mywi = capi.wibox.layout.margin(
        widget,         -- widget to use
        1,1,1,1         -- l,r,t,b
    )

    -- Connect to the daemon
    capi.dbus.request_name("session", "ru.gentoo.kbdd")
    capi.dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
    capi.dbus.connect_signal("ru.gentoo.kbdd", 
        function(...)
            local t = cfg.layout
            local data = {...}
            local a = data[2]
            set_icon(t[a+1][1])
        end
    )

    -- Set bindings for the widget
    mywi:buttons(awful.util.table.join(
        awful.button({}, 1, function () layout.next() end),
        awful.button({}, 3, function () layout.prev() end),
        awful.button({}, 2, function () layout.menu:toggle({keygrabber=true}) end)
    ))

    return mywi
end
--}}}

-- Set the metatable, like other awful widgets
setmetatable(_M, { __call = function (_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
