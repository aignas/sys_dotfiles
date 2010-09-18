-- menustuff module
--

local awful = require("awful")
local beautiful = require("beautiful")
local freedesktop_utils = require("freedesktop.utils")

local io = io
local table = table
local awesome = awesome
local ipairs = ipairs
local os = os
local string = string
local mouse = mouse

module("myrc.menu")

local env = {}

-- Reserved
function init(environment)
    env = environment
end

function build()
    local terminal      = (env.terminal or "roxterm") .. " "
    local editor        = (env.editor or "vim") .. " "
    local editor_gui    = (env.editor_gui or "gvim") .. " "
    local editor_cmd    = (env.editor_cmd or terminal .. " -e " .. editor) .. " "
    local browser       = (env.browser or "firefox") .. " "
    local email         = (env.email or "thunderbird-bin") .. " "
    local fileman       = (env.fileman or terminal .. " -e mc") .. " "

    freedesktop_utils.icon_theme = 'elementary'
    freedesktop_utils.icon_size = { '24' }

    local menu_awesome = {
        { "manual",     terminal .. " -e man awesome" },
        { "LuAPI doc",  browser .. "/usr/share/doc/awesome/luadoc/index.html" },
        { "ed config",  editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
        { "restart",    awesome.restart },
        { "quit",       awesome.quit }
    }

    local menu_powermng = {
        { "shutdown",   "shutdown -h now" },
        { "reboot",     "shutdown -r now" }
    }

    local menu_mm = {
    }

    local menu_science = {
        { "SAGE",       terminal .. "-e /opt/sage-bin/sage" },
        { "ipython",    terminal .. "-e ipython" },
        { "matplotlib", terminal .. "-e ipython -pylab" },
        { "gnuplot",    terminal .. "-e gnuplot" }
    }

    local menu_docs = {
    }

    local menu_web = {
    }

    local menu_items = {
        { "open terminal",  terminal },
        { "open browser",   browser },
        { "open reader",    email},
        { "", nil, nil }, --separator
        { "science",        menu_science },
        { "docs",           menu_docs },
        { "multimedia",     menu_mm },
        { "internet",       menu_web },
        { "", nil, nil }, --separator
        { "awesome",        menu_awesome, beautiful.awesome_icon },
        { "", nil, nil }, --separator
        { "power",          menu_powermng }
    }

    return awful.menu({ items = menu_items })

end

-- This function shows menu at position {x, y} aka menu_coord
-- kg is keygrabber (true/false)
function show(menu, kg, menu_coords)
    local old_coords = mouse.coords()
    local menu_coords = menu_coords or {x=0, y=0}
    mouse.coords(menu_coords)
    awful.menu.show(menu, kg)
    mouse.coords(old_coords)
end
--
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
