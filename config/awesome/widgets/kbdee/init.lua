-- A Keyboard widget
--      ideas borrowed from the awesome wiki.
--
--{{{ Environment

local setmetatable = setmetatable
local tostring = tostring
local tonumber = tonumber

local awful = require('awful')
local theme = require('beautiful').get()
local naughty = require('naughty')
local imagebox = require('wibox.widget.imagebox')

local capi = {
    client = client,
    mouse = mouse
}

--}}}

kbdee = { mt = {} }
kbdee.layout = {}

--{{{ Configuration of the widget
-- Make an empty table for the setxkbmap commands
kbdee.cfg = setmetatable({}, { __mode = 'k' })

-- Some aliases to ease my life
kbdee.cfg = {
    img_dir = awful.util.getdir("config") .. "/icons/wi_kbd",
    layout = {
        { "gb", "" },
    },
    setxkbmap = {
        model = ""
    },
    xmodmap = nil,
    current = 1
}


--}}}

--[[
Design of the whole thing:

    I have a widget box which is updated via signals.

    I have a snippet which stores and updates layouts per window.

    I can configure the thing.
--]]

--{{{ Layout commands
--
--- This wraps the setxkbmap command, so that it becomes easier to use it
-- Arguments are defined by a table list
kbdee.layout.setxkbmap = function (args)
    -- Assign local vars
    local layout = tostring(args.layout)
    local variant = tostring(args.variant) or ""
    local xmodmap = tostring(args.xmodmap) or nil

    -- Check if a layout is specified
    if #layout == 0 then
        naughty.notify({ 
            preset = naughty.config.presets.critical,
            title = "KBDee",
            text = "You tried to set the layout without actually specifying it!"
        })
    end

    -- Set the layout cmd
    local cmdstr = "setxkbmap" ..
                    " -layout " .. layout

    -- Check if variant entry is valid:
    if #variant ~= 0 then 
        cmdstr = cmdstr .. " -variant " .. variant
    end

    -- Add the xmodmap if present
    if xmodmap then
        cmdstr = cmdstr .. " && xmodmap " .. xmodmap
    end

    return awful.util.spawn_with_shell(cmdstr)
end

--- Switches a layout and interacts with userdata which is configured before
-- initializing the commands (hopefully)...
kbdee.layout.switch = function (idx)
    --Assign local vars
    local layout_table = kbdee.cfg.layout
    local current = kbdee.cfg.current
    local idx = tonumber(idx)
    local success = false

    -- Execute setxkbmap
    if idx ~= current then
        success = kbdee.layout.setxkbmap({
                    layout = layout_table[idx][1], 
                    variant = layout_table[idx][2],
                    xmodmap = kbdee.cfg.xmodmap
                })
    end

    if success then
        kbdee.cfg.current = idx

        w:emit_signal("kbdee::update")
        local cl = awful.client.focus.history.get(capi.mouse.screen, 0)
        if cl then cl:emit_signal("kbdee::update") end

        return true
    end

    -- Did not succeed to change the layout
    return false
end

--- Selects the next layout in the list
kbdee.layout.next = function ()
    local idx = kbdee.cfg.current + 1

    -- Out of bounds ?
    if idx > kbdee.cfg.layout_table then
        idx = 1
    end

    return kbdee.layout.switch({
        idx = idx
    })
end

--- Selects the previous layout in the list
kbdee.layout.prev = function ()
    local idx = kbdee.cfg.current - 1

    -- Out of bounds ?
    if idx == 0 then
        idx = #kbdee.cfg.layout_table
    end

    return kbdee.layout.switch({
        idx = idx
    })
end

function kbdee.layout.menu_gen ()
    local menu_table = {}

    for i,entry in ipairs(kbdee.cfg.layout) do
        menu_table[i] = { 
            -- Name of the layout
            entry[1] .. " " .. entry[2], 
            function () kbdee.layout.switch(i) end, 
            kbdee.cfg.img_dir .. "/24/" .. entry[1] .. ".png"
        }
    end

    return awful.menu({items = menu_table})
end
--}}}

--{{{ Imgbox commands
local update = function (w, current)
    local layout = kbdee.cfg.layout[current][1]
    w:set_image(kbdee.cfg.img_dir .. "/48/" .. layout .. ".png")
end

kbdee.new = function (cfg)
    cfg = cfg or kbdee.cfg
    w = imagebox()

    -- update the widget
    update (w, cfg.current)

    -- create some signals
    capi.client.add_signal("kbdee::update")
    capi.client.add_signal("property::kbdee::layout")
    w:add_signal("kbdee::update")

    -- Connect them
    w:connect_signal("kbdee::update", function () update (w, cfg.current) end)

    capi.client.connect_signal("focus",
        function (c)
            local idx = awful.client.property.get(c,"kbdee::layout") or 1

            -- Do the actual switching
            kbdee.layout.switch(idx)
        end
    )

    capi.client.connect_signal("kbdee::update", 
        function (c) 
            awful.client.property.set(c, "kbdee::layout", kbdee.cfg.current) 
        end)
    
    -- return the widget
    return w
end
--}}}

-- Set the metatable, like other awful widgets and return it
function kbdee.mt:__call(...)
    return kbdee.new(...)
end

return setmetatable(kbdee, kbdee.mt)

-- ft - filetype
-- et - expandtab
-- sw - shiftwidth
-- ts - tabstop
-- sts - shifttabstop
-- tw - textwidth
-- fdm - foldmethod
-- vim: ft=lua:et:sw=4:ts=8:sts=4:tw=80:fdm=marker
