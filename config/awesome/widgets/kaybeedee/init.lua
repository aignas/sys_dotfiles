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
local capi = {
    awesome = awesome,
    client = client
}
local wibox = require('wibox')

--}}}

module('kaybeedee')

--{{{ Configuration of the widget
-- Make an empty table for the sexkbmap commands
cfg = setmetatable({}, { __mode = 'k' })

-- Some aliases to ease my life
cfg.defaults = {
    img_dir = awful.util.getdir("config") .. "/icons/wi_kbd",
    layout = {
        { "gb", "" },
    },
    current = 1
}

cfg.img_dir = cfg.defaults.img_dir
cfg.layout = cfg.defaults.layout
cfg.setxkbmap = {model = ""}

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

function setxkbmap (args)
    local l = args.layout or ""
    local v = args.variant or ""

    -- Check if layout is set
    if #l == 0 then
        naughty.notify({ preset = naughty.config.presets.critical,
            title = "kaybeedee",
            text = "You tried to set the layout without actually specifying it!"
        })
    end

    -- Set the layout cmd
    local cmdstr = "setxkbmap -layout " .. l

    -- Set the variant command if present
    if #v ~= 0 then
        cmdstr = cmdstr .. " -variant " .. v
    end

    return awful.util.spawn(cmdstr)
end

layout = {}
--{{{layout.switch Switch to a layout
--@param: the relative id of the layout to switch to
function layout.switch(index,no_notification)
    local t = cfg.layout
    local s = no_notification or false
    local a = index
    local k = false

    if type(a) ~= "number" then local a = tonumber(a) end

    -- Execute setxkbmap
    if a ~= cfg.current then
        k = setxkbmap({layout = t[a][1], variant = t[a][2]})
    end

    if k then
        cfg.current = a

        -- Do not notify if s is true
        if not s then notify(t[a]) end

        set_icon(t[a][1])

        -- Set the keymap property
        local cl = capi.client.focus or awful.client.focus.history.get()
        if cl then awful.client.property.set(cl,"keymap",cfg.current) end

        return true
    end

    return false
end

--- Go to the next layout
function layout.next()
    cfg.current = cfg.current + 1
    if cfg.current > #cfg.layout then
        cfg.current = 1
    end
    layout.switch(cfg.current)
end

--- Go to the previous layout
function layout.prev()
    cfg.current = cfg.current - 1
    if cfg.current == 0 then
        cfg.current = #cfg.layout
    end
    layout.switch(cfg.current)
end

--- Initialize the layouts
function layout.init(args)
    -- Do some more args checking?
    args = args or cfg.defaults.layout
    cfg.layout = args
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

function layout.xkb_check()
    local f = assert(io.popen("setxkbmap -query"))
    local l,v = "", ""
    local l_t, v_t = {},{}
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

    for i,k in ipairs(cfg.layout) do
        if k[1] == l_t[i] and k[2] == l_v[i] then
            cfg.current = i
            return true
        end
    end
    return false
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
            function () layout.switch(i) end, 
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

    -- Check the current layout
    -- If the current layout is not present in the layout list, then set it to the first one.
    if not layout.xkb_check() then
        cfg.current = 1
    end
    awful.util.spawn_with_shell("setxkbmap -model " .. cfg.setxkbmap.model)
    -- FIXME rewrite the function
    layout.menu = layout.menu_gen()

    -- initiate a widget
    widget = wibox.widget.imagebox()
    widget:set_image(capi.awesome.load_image(cfg.img_dir .. "/24/" 
                     .. cfg.layout[cfg.current][1] .. ".png"))
    -- Do some widget formatting
    mywi = wibox.layout.margin(
        widget,         -- widget to use
        1,1,1,1         -- l,r,t,b
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

capi.client.connect_signal("focus",
    function (c)
        local a = awful.client.property.get(c,"keymap")
        if a then layout.switch(a)
        else
            layout.switch(1,true)
            awful.client.property.set(c,"keymap",cfg.current)
        end
    end
)

-- Set the metatable, like other awful widgets
setmetatable(_M, { __call = function (_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80:foldmethod=marker
