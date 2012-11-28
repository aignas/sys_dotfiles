-- A Keyboard widget
--      ideas borrowed from the awesome wiki.
--
--{{{ Environment

local setmetatable = setmetatable
local tostring = tostring
local tonumber = tonumber

local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')
local imagebox = require('wibox.widget.imagebox')

local capi = {
    client = client,
    mouse = mouse
}

--}}}

M = { mt = {} }
M.layout = {}

--{{{ Configuration of the widget
-- Make an empty table for the sexkbmap commands
M.cfg = setmetatable({}, { __mode = 'k' })

-- Some aliases to ease my life
M.cfg = {
    img_dir = awful.util.getdir("config") .. "/icons/wi_kbd",
    layout = {
        { "gb", "" },
    },
    setxkbmap = {
        model = ""
    },
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
M.layout.setxkbmap = function (args)
    -- Assign local vars
    local layout = tostring(args.layout)
    local variant = tostring(args.variant) or ""

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

    return awful.util.spawn_with_shell(cmdstr)
end

--- Switches a layout and interacts with userdata which is configured before
-- initializing the commands (hopefully)...
M.layout.switch = function (idx)
    --Assign local vars
    local layout_table = M.cfg.layout
    local current = M.cfg.current
    local idx = tonumber(idx)
    local success = false

    -- Execute setxkbmap
    if idx ~= current then
        success = M.layout.setxkbmap({
                    layout = layout_table[idx][1], 
                    variant = layout_table[idx][2]
                })
    end

    if success then
        M.cfg.current = idx

        w:emit_signal("kbdee::update")
        local cl = awful.client.focus.history.get(capi.mouse.screen, 0)
        if cl then cl:emit_signal("kbdee::update") end

        return true
    end

    -- Did not succeed to change the layout
    return false
end

--- Selects the next layout in the list
M.layout.next = function ()
    local idx = M.cfg.current + 1

    -- Out of bounds ?
    if idx > M.cfg.layout_table then
        idx = 1
    end

    return M.layout.switch({
        idx = idx
    })
end

--- Selects the previous layout in the list
M.layout.prev = function ()
    local idx = M.cfg.current - 1

    -- Out of bounds ?
    if idx == 0 then
        idx = #M.cfg.layout_table
    end

    return M.layout.switch({
        idx = idx
    })
end

function M.layout.menu_gen ()
    local theme = beautiful.get()
    local menu_table = {}

    for i,entry in ipairs(M.cfg.layout) do
        menu_table[i] = { 
            -- Name of the layout
            entry[1] .. " " .. entry[2], 
            function () M.layout.switch(i) end, 
            M.cfg.img_dir .. "/24/" .. entry[1] .. ".png"
        }
    end

    return awful.menu({items = menu_table})
end
--}}}

--{{{ Imgbox commands
local update = function (w, current)
    local layout = M.cfg.layout[current][1]
    w:set_image(M.cfg.img_dir .. "/48/" .. layout .. ".png")
end

M.new = function (cfg)
    cfg = cfg or M.cfg
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
            M.layout.switch(idx)
        end
    )

    capi.client.connect_signal("kbdee::update", 
        function (c) 
            awful.client.property.set(c, "kbdee::layout", M.cfg.current) 
        end)
    
    -- return the widget
    return w
end
--}}}


-- Set the metatable, like other awful widgets and return it
function M.mt:__call(...)
    return M.new(...)
end

return setmetatable(M, M.mt)

-- ft - filetype
-- et - expandtab
-- sw - shiftwidth
-- ts - tabstop
-- sts - shifttabstop
-- tw - textwidth
-- fdm - foldmethod
-- vim: ft=lua:et:sw=4:ts=8:sts=4:tw=80:fdm=marker
