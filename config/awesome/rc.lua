-- Configuration file of Ignas Anikevicius
-- inspired from dunz0r as well as anrxc and others
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Widgets
--local wi_bat = require("obvious.smapi")
--require("vicious")
-- kAwouru's MPD library
require("lib/mpd") ; mpc = mpd.new({ hostname="localhost" })
-- keybind library inspired by ierton
require("lib/vimo")
-- dynamic tagging lib inspired by farhaven and the dyn tagging patches in
-- awesome. Basically it is supposed to provide very basic set features
require("lib/dyntag")
require("lib/shifty2")
-- modular config
require("myrc.menu")

-- Print the date when the theme was loaded
print("---<<<||| rc.lua - Loaded on: "..os.date().."|||>>>---")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config").."/themes/gns-ank/theme.lua")

-- Defaul Modifier Keys
local altkey = "Mod1"
local modkey = "Mod4"
local ctrl = "Control"
local shkey = "Shift"

local mkey1 = "Hyper_L"
local mkey2 = "Super_L"
local mkey3 = "Super_R"

-- Some aliases for easier life
local home   = os.getenv("HOME")
local cfgdir = awful.util.getdir("config")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- This is used later as the default terminal and editor to run.
env = { 
    terminal = "urxvtc",
    terminal_s = "urxvt",
    terminal_d = "urxvtd",
    terminal_x = "xterm",
    terminal_alt = "roxterm",
    editor = "vim",
    browser = "firefox",
    browser_alt = "luakit",
    browser_alt2 = "uzbl-tabbed",
    mail    = "thunderbird",
    skype = "skype",
    nm = "wicd-client" 
}

env.terminal_root   = env.terminal .. " -e sudo -s"
env.fileman         = env.terminal .. " -e ranger"
env.mpd_client      = env.terminal .. " -T ::mpd:: -e ncmpcpp"
env.irc             = env.terminal .. " -T ::irc:: -e weechat-curses"
env.editor_cmd      = env.terminal .. " -e " .. env.editor
env.nm_c            = env.terminal .. " -e wicd-curses"

function run_once(prog_list)
    local user = os.getenv("USER")
    if not prog_list then
        return nil
    end
    for _, prog in ipairs(prog_list) do
        sexec("pgrep -u " .. user .. " -x " .. prog .. " || (" .. prog .. ")")
    end
end

run_once({  
    env.terminal_d,
    env.nm,
    env.skype,
    env.mail
})

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,               --1
    awful.layout.suit.tile.left,          --2
    awful.layout.suit.fair,               --3
    awful.layout.suit.tile.bottom,        --4
    awful.layout.suit.tile.top,           --5
    awful.layout.suit.fair.horizontal,    --6
    awful.layout.suit.max,                --7
    awful.layout.suit.floating            --8
}

-- {{{ Tags
use_titlebar = false

--{{{ shifty2: configured tags
-- Define a tag table which hold all screen tags.
shifty2.config.tags = {
    ["term"]    = { layout=layouts[3], position = 1, init=true},
    ["calc"]    = { layout=layouts[1], position = 2},
    ["tex"]     = { layout=layouts[1], position = 3},
    ["web"]     = { layout=layouts[7], position = 4, exclusive = true },
    ["mail"]    = { layout=layouts[5], position = 5, exclusive = true },
    ["im"]      = { layout=layouts[3], position = 6},
    ["irc"]     = { layout=layouts[1], position = 6},
    ["ardour"]  = { layout=layouts[1], position = 7},
    ["jack"]    = { layout=layouts[1], position = 7},
    ["other"]   = { layout=layouts[1], position = 7},
    ["mpd"]     = { layout=layouts[1], position = 8},
    ["media"]   = { layout=layouts[1], position = 8},
    ["vm"]      = { layout=layouts[8], position = 9},
    ["wine"]    = { layout=layouts[8], position = 9}
}
--}}}

--{{{ shifty2: application matching rules
-- order here matters, early rules will be applied first
shifty2.config.apps = {
    { match = { "luakit", "Uzbl", "Firefox", "Namoroka", "Navigator", "Transmission" }, 
        tag = "web" },
    { match = { "Thunderbird", "Lanikai", "mutt" }, 
        tag = "mail" },
    { match = { "::ranger::" }, 
        slave = true },
    { match = { "OpenOffice.*" } , 
        tag = "office" } ,
    { match = { "Mplayer.*","Mirage","gimp","gtkpod","Ufraw","easytag" }, 
        tag = "media", nopopup = true, } ,
    { match = { "MPlayer", "Gnuplot", "galculator", "Wicd-client.py" }, 
        float = true },
    { match = { "Skype.*", "Pidgin.*" }, 
        tag = "im" },
    { match = { "::irc::", "WeeChat" }, 
        tag = "irc" },
    { match = { "URxvt" }, 
        slave = true },
}
--}}}

shifty2.config.defaults={
    layout = layouts[1],
    ncol = 1,
    mwfact = 0.60,
    floatBars = false,
    guess_name = false,
    guess_position = false
}

function client_prop(c) 
    f = function (prop, str) 
        return 
            prop and 
                ( str 
                .. ((type(prop)=="boolean") and "" or (" = " .. prop)) 
                .. "\n" ) 
            or "" 
    end 
        
    naughty.notify({ 
        title = "Client info", 
        text = "" 
        .. f(c.class, "class") 
        .. f(c.instance, "instance") 
        .. f(c.name, "name") 
        .. f(c.type, "type") 
        .. f(c.role, "role") 
        .. f(c.pid, "pid") 
        .. f(c.window, "window_id") 
        .. f(c.machine, "machine") 
        .. f(c.skip_taskbar, "skip taskbar") 
        .. f(c.floating, "floating") 
        .. f(c.minimized, "minimized") 
        .. f(c.maximized_horizontal, "maximized horizontal") 
        .. f(c.maximized_vertical, "maximized vertical") 
    }) 
end 

-- {{{ Menu
awful.menu.menu_keys = {
    up     = { "k", "Up"       },
    down   = { "j", "Down"     },
    exec   = { "l", "Right", "Return"    },
    back   = { "h", "Left"     },
    close  = { ";", "Escape", "w" }
}

myrc.menu.init(env)
menu_main = myrc.menu.build()

-- }}}
-- {{{ Wibox
-- Create a wibox for each screen and add it
wibox_top = {}
wibox_tsk = {}
wibox_bot = {}

-- Widgets for wibox_top:
-- Create a systray
wi_systray = widget({ type = "systray" })

wi_promptbox_top = {}
wi_promptbox_bot = {}

wi_layoutbox = {}

wi_tasklist = {}
wi_tasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

wi_taglist = {}
wi_taglist.buttons = awful.util.table.join(
                    awful.button({          }, 1, awful.tag.viewonly),
                    awful.button({ modkey   }, 1, awful.client.movetotag)  ,
                    awful.button({          }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey   }, 3, awful.client.toggletag)
                    )

-- Create a textclock widget
wi_clock = awful.widget.textclock({align=right}, " %X<big>|</big>%e/%m/%y %a ", 1)

-- Initialize widget
--wi_clock = widget({ type = "textbox" })
-- Register widget
--vicious.register(wi_clock, vicious.widgets.date, "%b %d, %R", 60)

-- Keyboard map indicator and changer
wi_kbdcfg = {}
wi_kbdcfg.command = "setxkbmap"
wi_kbdcfg.addargs = {
    "-model thinkpad -option caps:super", -- Setxkbmap options
    " xmodmap ~/.Xmodmap"  -- Other commands to execute afterwards
}
wi_kbdcfg.layout = {
    { "gb", "" },
    { "lt", "std" },
    { "ru", "phonetic" },
    { "fr", "" },
    { "gb", "dvorakukp" }
}
wi_kbdcfg.current = 1  -- default layout
--wi_kbdcfg.widget = widget({ type = "textbox", align = "center" })
wi_kbdcfg.widget = widget({ type = "imagebox" })
--wi_kbdcfg.widget.text = " " .. wi_kbdcfg.layout[wi_kbdcfg.current][1] .. " "
wi_kbdcfg.widget.image = image(cfgdir.."/icons/flags/24/" .. wi_kbdcfg.layout[wi_kbdcfg.current][1] .. ".png")
--wi_kbdcfg.widget.bg_image = image(cfgdir.."icons/flags/24/" .. wi_kbdcfg.layout[wi_kbdcfg.current][1] .. ".png")
wi_kbdcfg.naughty = nil
wi_kbdcfg.dvorlayout = " ` 1 2 3 4 5 6 7 8 9 0 - =\n    / , . p y f g c r l [ ] \n     a o e u i d h t n s ' #\n    \\ ; q j k x b m w v z"

function wi_kbdcfg.tog (a,b)
    if wi_kbdcfg.naughty then naughty.destroy(wi_kbdcfg.naughty) end
    local l = #(wi_kbdcfg.layout)
    local changed = true
    if not ( a == "s" or a == "j" or b > 0 ) then
        naughty.notify({text = "Keyboard switcher - Invalid arguments"})
        changed = false 
        error()
    elseif a == "j" then
        if wi_kbdcfg.current == b 
            then changed = false 
            else wi_kbdcfg.current = b 
        end
    elseif a == "sb" then
        for v = b, 1, -1 do
            wi_kbdcfg.current = ( wi_kbdcfg.current + l - 2 ) % l + 1
        end
    elseif a == "sf" then
        for v = b, 1, -1 do
            wi_kbdcfg.current = wi_kbdcfg.current % l + 1
        end
    else
        naughty.notify({text = "Keyboard switcher - Invalid arguments"})
        changed = false 
        error()
    end
    local t, u = wi_kbdcfg.layout[wi_kbdcfg.current], wi_kbdcfg.addargs
    if changed then sexec(wi_kbdcfg.command .. " " .. t[1] .. " " .. t[2] .. " " .. u[1]) end
    local nt = "Current layout - " .. t[1]
    if t[2] ~= "" then 
        nt = nt .. "\nLayout variant - " .. t[2] 
    else nt = nt .. "\nLayout variant - default" 
    end
    wi_kbdcfg.widget.image = image(cfgdir.."/icons/flags/24/" .. t[1] .. ".png")
    --wi_kbdcfg.widget.bg_image = image(cfgdir.."icons/flags/24/" .. t[1] .. ".png")
    wi_kbdcfg.widget.text = " " .. t[1] .. " "
    wi_kbdcfg.naughty = naughty.notify({    
        title = "XKBmap", 
        text = nt,
        icon = image(cfgdir.."/icons/flags/48/" .. t[1] .. ".png"),
        icon_size = "40",
        timeout = 1
    })
end

-- Create stuff for every screen
for s = 1, screen.count() do
    -- Create the wiboxes
    wibox_top[s] = awful.wibox({ position = "top", screen = s })
    wibox_tsk[s] = awful.wibox({ position = "bottom", screen = s })
    wibox_bot[s] = awful.wibox({ position = "bottom", screen = s })

    -- Create a tasklist widget
    wi_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, wi_tasklist.buttons)

    -- Create a promptbox for each screen
    wi_promptbox_top[s] = awful.widget.prompt()
    wi_promptbox_bot[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    wi_layoutbox[s] = awful.widget.layoutbox(s)
    --    wi_layoutbox[s]:buttons(awful.util.table.join(
    --                           awful.button({ }, 1, function () layout_change( 1) end),
    --                           awful.button({ }, 3, function () layout_change(-1) end),
    --                           awful.button({ }, 4, function () layout_change( 1) end),
    --                           awful.button({ }, 5, function () layout_change(-1) end)))
    -- Create a taglist widget
    wi_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, wi_taglist.buttons)

    -- Create a table with widgets that go to the right
    top_right_aligned = {
        layout = awful.widget.layout.horizontal.rightleft
    }
    table.insert(top_right_aligned, wi_clock)
--    table.insert(top_right_aligned, wi_bat())
    if s == 1 then table.insert(top_right_aligned, wi_systray) end
    table.insert(top_right_aligned, wi_kbdcfg.widget)

    top_center_aligned = {
        layout = awful.widget.layout.horizontal.center
    }

    -- Add widgets to the top wibox - order matters
    wibox_top[s].widgets = {
        wi_layoutbox[s],
        top_center_aligned,
        wi_taglist[s],
        wi_promptbox_top[s],
        top_right_aligned,
        layout = awful.widget.layout.horizontal.leftright,
        height = wibox_top[s].height
    }
    wibox_tsk[s].widgets = {
        wi_tasklist[s],
        layout = awful.widget.layout.horizontal.leftright,
        height = wibox_top[s].height
    }
    wibox_bot[s].widgets = {
        wi_promptbox_bot[s],
        layout = awful.widget.layout.horizontal.leftright,
        height = wibox_top[s].height
    }
    wibox_tsk[s].visible = false
    wibox_bot[s].visible = false

end

shifty2.taglist = wi_taglist
shifty2.init()
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({                  }, 3,               function () menu_main:toggle({keygrabber=true}) end)
))

-- Bindings for kbd widget
wi_kbdcfg.widget:buttons(awful.util.table.join(
awful.button({                  }, 1,               function () wi_kbdcfg.tog("sf", 1) end),
awful.button({                  }, 3,               function () wi_kbdcfg.tog("sb", 1) end)
))
-- }}}

-- {{{ Key bindings
-- This setup is modular keybinding stuff.
-- It differs from others so that the keys can be changed according to the mode

keybs = {}
keybs.mode = {}

keybs.mode.mpd = {
    vimo.key({ modkey, altkey }, "m", "Toggle mode", 
    function () vimo.mode_switch("mpd") end),
    vimo.key({ }, "c", "launch client", 
    function ()
        sexec(env.mpd_client) ; vimo.mode_switch("none")
    end),
    vimo.key({ }, "y", "seek 5s back", function () mpc:seek(-5) end),
    vimo.key({ }, "o", "seek 5s fwd",  function () mpc:seek( 5) end),
    vimo.key({ }, "u", "vol down",     function () mpc:volume_down(1) end),
    vimo.key({ }, "i", "vol up",       function () mpc:volume_up(1) end),
    vimo.key({ }, "h", "previous",     function () mpc:previous() end),
    vimo.key({ }, "l", "next",         function () mpc:next() end),
    vimo.key({ }, "j", "play/pause",   function () mpc:toggle_play() end),
    vimo.key({ }, "space", "play/pause",   function () mpc:toggle_play() end),
    vimo.key({ }, "k", "stop",         function () mpc:stop() end)
}

-- Modular program launching
keybs.mode.launch = {
    vimo.key({ modkey, altkey }, "l", "Toggle mode", 
    function () vimo.mode_switch("launch") end),
    vimo.key({ }, "t", "Todo list",    
    function () exec(env.editor_cmd .. " " .. home .. "/todo") end),
    vimo.key({ }, "x", "terminal",     function () exec(env.terminal) end),
    vimo.key({ altkey }, "x", "alt term",     
    function () exec(env.terminal_alt) end),
    vimo.key({ }, "n", "net man tray", function () exec(env.nm) end),
    vimo.key({ altkey }, "n", "net man",      
    function () exec(env.nm_c) end),
    vimo.key({ }, "g", "ed",           function () exec(env.editor_cmd) end),
        vimo.key({ }, "b", "browser",      function () exec(env.browser) end),
        vimo.key({ }, "m", "mail reader",  function () exec(env.mail) end),
        vimo.key({ }, "s", "skype",        function () exec("skype") end),
        vimo.key({ }, "i", "irc client",   function () sexec(env.irc) end)
}

keybs.mode.layout = {
    vimo.key({ modkey }, "space", "Toggle mode", 
                function () vimo.mode_switch("layout") end,
                function () vimo.mode_switch("normal") end),
    vimo.key({ modkey }, "#44", "tile",   function () awful.layout.set(layouts[1])end),
    vimo.key({ modkey }, "#45", "tile_l", function () awful.layout.set(layouts[2])end),
    vimo.key({ modkey }, "#46", "fair",   function () awful.layout.set(layouts[3])end),
    vimo.key({ modkey }, "#30", "tile_b", function () awful.layout.set(layouts[4])end),
    vimo.key({ modkey }, "#31", "tile_t", function () awful.layout.set(layouts[5])end),
    vimo.key({ modkey }, "#32", "fair_h", function () awful.layout.set(layouts[6])end),
    vimo.key({ modkey }, "#16", "max",    function () awful.layout.set(layouts[7])end),
    vimo.key({ modkey }, "#17", "float",  function () awful.layout.set(layouts[8])end),
    vimo.key({ modkey }, "#59", ">>",
                function ()
                    layout_change(1)
                end),
    vimo.key({ modkey }, "#60", "<<", 
                function ()
                    layout_change(-1)
                end)
}

-- kbdcfg bindings. They are binded to the keycodes so that diferent
-- languages would not interfere with them.
-- Buttons are located in the part of numerical keys activated with numlock
keybs.xkbcfg = awful.util.table.join(
    awful.key({ altkey, shkey }, "#44", function () wi_kbdcfg.tog("j", 1) end),
    awful.key({ altkey, shkey }, "#45", function () wi_kbdcfg.tog("j", 2) end),
    awful.key({ altkey, shkey }, "#46", function () wi_kbdcfg.tog("j", 3) end),
    awful.key({ altkey, shkey }, "#30", function () wi_kbdcfg.tog("j", 4) end),
    awful.key({ altkey, shkey }, "#31", function () wi_kbdcfg.tog("j", 5) end),
    awful.key({ altkey, shkey }, "#32", 
                function () naughty.notify({ title = "Dvorak layout",
                    text = wi_kbdcfg.dvorlayout }) 
                end),
    awful.key({ altkey, shkey }, "#59", function () wi_kbdcfg.tog("sb", 1) end),
    awful.key({ altkey, shkey }, "#60", function () wi_kbdcfg.tog("sf", 1) end)
)

-- Prompt key bindings
keybs.prompt = awful.util.table.join(
    awful.key({ modkey }, "r",
                function ()
                    local state = wibox_bot[mouse.screen].visible
                    wibox_bot[mouse.screen].visible = true
                    awful.prompt.run({ prompt = "Zsh: " }, wi_promptbox_bot[mouse.screen].widget,
                    function (...) 
                        wi_promptbox_bot[mouse.screen].text = exec(unpack(arg), false)
                    end,
                    awful.completion.shell, awful.util.getdir("cache") .. "/history",
                    50, function () wibox_bot[mouse.screen].visible = state end)
                end),

    awful.key({ modkey }, "x",
                function ()
                    wibox_top[mouse.screen].visible = true
                    awful.prompt.run({ prompt = "Lua: " }, wi_promptbox_top[mouse.screen].widget,
                    awful.util.eval, nil,
                    awful.util.getdir("cache") .. "/history_eval")
                end)
)

keybs.modestage = {}
keybs.modestage.winman = {
    vimo.key({ modkey, altkey }, "w", "Toggle mode",
                function () vimo.mode_switch("winman") end),
    vimo.key({ }, "h", "",
                function () awful.tag.incmwfact(-0.05)    end),
    vimo.key({ }, "j", "",
                function () awful.client.focus.byidx( 1)
                    if client.focus then client.focus:raise() end
                end),
    vimo.key({ }, "k", "",
                function () awful.client.focus.byidx(-1) 
                    if client.focus then client.focus:raise() end
                end),
    vimo.key({ }, "l", "",
                function () awful.tag.incmwfact( 0.05)    end),
}

keybs.winman = awful.util.table.join(
    -- Standard program
    awful.key({ modkey }, "h", 
                function () 
                    awful.tag.incmwfact(-0.10)
                end),
    awful.key({ modkey }, "l", 
                function () 
                    awful.tag.incmwfact(0.10)
                end),
    awful.key({ modkey }, "j",
                function () 
                    awful.client.focus.byidx( 1)
                    if client.focus then client.focus:raise() end
                end),
    awful.key({ modkey }, "k",
                function ()
                    awful.client.focus.byidx(-1)
                    if client.focus then client.focus:raise() end
                end),

    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx( 1) end),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end),
    --something more usefull;
    --maybe switch to a mode?
    --awful.key({ modkey, "Shift" }, "h", function () awful.client.swap.bydirection("left") end),
    --awful.key({ modkey, "Shift" }, "l", function () awful.client.swap.bydirection("right") end),

    awful.key({ modkey }, "XF86Forward",function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey }, "XF86Back",   function () awful.screen.focus_relative(-1) end),

    awful.key({ modkey, "Control" }, "j",             function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "k",             function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "l",             function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "h",             function () awful.tag.incncol(-1)         end),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto),

    awful.key({ modkey,             }, "Return",        function () exec(env.terminal) end),
    awful.key({ modkey, "Control"   }, "r",             awesome.restart),
    awful.key({ modkey, "Shift"     }, "q",             awesome.quit),

    -- misc program
    awful.key({ modkey,             }, "a",
                function ()
                    local s = mouse.screen
                    wibox_top[s].visible = not wibox_top[s].visible
                end),
    awful.key({ altkey }, "Tab",
                function ()
                    local s = mouse.screen
                    wibox_tsk[s].visible = not wibox_tsk[s].visible
                end),
    awful.key({ modkey,             }, "w", 
                function () menu_main:show({keygrabber=true}) end),
    awful.key({ modkey,             }, "Escape",        awful.tag.history.restore)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,             }, "f",             function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,             }, "q",             function (c) c:kill()                         end),
    awful.key({ modkey, "Control"   }, "space",         awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control"   }, "Return",        function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,             }, "o",             awful.client.movetoscreen                        ),
    awful.key({ modkey,             }, "t",             function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"     }, "t",             function (c) c.sticky = not c.sticky          end),
    awful.key({ modkey,             }, "n",             function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey, "Shift"     }, "m",
                function (c)
                    c.maximized_horizontal = not c.maximized_horizontal
                    c.maximized_vertical   = not c.maximized_vertical
                end),
    awful.key({modkey}, "i",
                function (c) client_prop(c) end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   --keynumber = math.min(9, math.max(#tags[s], keynumber)) ;
   keynumber = math.min(10, keynumber) ;
end

keybs.dtag = awful.util.table.join(
--    awful.key({ modkey }, "#11",
--                function () dyntag.add_p(wi_promptbox_top) end),
--                shifty2.add),
--    awful.key({ modkey }, "#12",
--                function ()
--                    awful.prompt.run({ prompt = "Move " }, wi_promptbox_top[mouse.screen].widget,
--                    function (index)
--                        awful.tag.move(tonumber(index))
--                    end,
--                    awful.util.getdir("cache") .. "/history_eval")
--                end),
--    awful.key({ modkey }, "#10",
--                function ()
--                    local s = mouse.screen
--                    local tg_tbl = {}
--                    for a, b in ipairs(screen[s]:tags()) do
--                        table.insert(tg_tbl, b.name)
--                    end
--                    awful.completion.keyword = tg_tbl
--                    awful.prompt.run({ prompt = "Go To " }, wi_promptbox_top[s].widget,
--                    function (name)
--                        if screen[s]:tags() then
--                            local b = 1
--                            local tg = screen[s]:tags()
--                            while (name ~= tg[b].name) and (b <= #tg) do b=b+1 end
--                            if b <= #tg then
--                                awful.tag.viewonly(screen[s]:tags()[b])
--                            end
--                        end
--                    end,
--                    awful.completion.generic,
--                    awful.util.getdir("cache") .. "/history_eval")
--                end),
--    awful.key({ modkey }, "#13",
--                function ()
--                    awful.tag.delete()
--                end),
    awful.key({ modkey, shkey }, "i", function ()
                keygrabber.run(
                function(modifiers, key, event)
                    local mod_t = {}
                    local mod = ""
                    for k, v in ipairs(modifiers) do mod_t[v] = true; mod = mod.."; "..v end
                    if mod_t.Control and key == "c" then
                        return false
                    end
                    naughty.notify({text = "Modifier = "..mod.."\n key - "..key.."\n"..event })
                    return true
                end)
            end),
    awful.key({ modkey, shkey }, "r", shifty2.rename),
    awful.key({ modkey, shkey }, "e", shifty2.add),
    awful.key({ modkey }, "#59", function () awful.tag.viewidx(-1) end),
    awful.key({ modkey }, "#60", function () awful.tag.viewidx( 1) end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keybs.winman = awful.util.table.join(keybs.winman,
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                awful.tag.viewonly(shifty2.getpos(i))
            end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local s = mouse.screen
                if screen[s]:tags()[i] then
                    awful.tag.viewtoggle(screen[s]:tags()[i])
                end
            end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus and screen[client.focus.screen]:tags()[i] then
                    awful.client.movetotag(screen[client.focus.screen]:tags()[i])
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus and screen[client.focus.screen]:tags()[i] then
                    awful.client.toggletag(screen[client.focus.screen]:tags()[i])
                end
            end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c ; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
-- modular stuff
--vimo.keybs = keybs.mode
vimo.keys_global_def = awful.util.table.join(keybs.winman, keybs.dtag, keybs.prompt, keybs.xkbcfg )
globalkeys = vimo.init(keybs.mode)
root.keys(globalkeys)
-- }}}

--{{{ SHIFTY: initialize shifty
-- the assignment of shifty.taglist must always
--be after its actually initialized 
-- with awful.widget.taglist.new()
shifty2.config.clientkeys = clientkeys
--}}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    -- The first rule means, that the windows will be resized only by WM (no gaps)
    { rule = { },
      properties = { size_hints_honor = false,
                     border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule_any = { 
      instance = { "mplayer", "wicd", "nitrogen", "gimp", "pinentry" }, 
      name = { "Event Tester" } },
      properties = { floating = true } },
    { rule = { name = "Workrave" },
      properties = { focus = false, border_width = 0, raise = false, slave = true } },

    --{ rule = { class = "Uzbl-tabbed" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "web", layout = layouts[7] }) end },
    --{ rule = { class = "Namoroka" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "web", layout = layouts[7] }) end },
    --{ rule = { class = "Firefox" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "web", layout = layouts[7] }) end },
    --{ rule = { class = "Thunderbird" or "Shredder" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "mail", layout = layouts[1] }) end },

    --{ rule = { class = "Skype" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "im", layout = layouts[1] }) end },
    { rule = { class = "Skype", name = "Call with b-e-t-u-k-a" }, -- skype stuff again
      properties = { sticky = true, ontop = true, focus = false, slave = true } },

    --{ rule = { class = "URxvt", name = "::irc::" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "irc", layout = layouts[1] }) end },
    --{ rule = { class = "URxvt", name = "::mpd::" },
    --  callback = function (c) dyntag.match.tagrule(c, { name = "mpd", layout = layouts[1] }) end },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80
