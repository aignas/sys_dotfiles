-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Widget and layout library
require("wibox")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

--require("lib/mpd") ; mpc = mpd.new({ hostname="localhost" })
require("lib/hfunc")

require("scratch")

-- Widgets
require("widgets/smapi")
require("widgets/mixer")

-- {{{ Variable definitions
-- Some aliases for easier life
local home   = os.getenv("HOME")
local cfgdir = awful.util.getdir("config")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- Themes define colours, icons, and wallpapers
beautiful.init(cfgdir.."/themes/gns-ank/theme.lua")
sexec("cat "..home.."/.fehbg | zsh")
--[[
if screen.count()~=1 then
    background_setter
else
    for s = 1,screen.count() do 
        -- a clever thing to set the wallpaper for each screen separately with feh.
        -- Found it in ArchLinux forums
        sexec("DISPLAY=:0."..s.." feh --bg-fill " ..cfgdir.. "/themes/gns-ank/wallpaper")
    end
end
--]]

-- Default application definitions.
prg = {
    terminal = "urxvt",
    terminal_alt = "xterm",
--    editor = "urxvt -e vim",
    editor = "gvim",
    browser = "icecat",
    mua = "thunderbird",
    nm = "wicd-client"
}

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.max,                -- 1
    awful.layout.suit.tile,               -- 2
    awful.layout.suit.fair,               -- 3
    awful.layout.suit.fair.horizontal,    -- 4
    awful.layout.suit.floating,           -- 5
    awful.layout.suit.max.fullscreen,     -- 6
}
-- }}}

--{{{ Startup
hello_msg = {
    "Awesome",
    "rc.lua loaded at: "..os.date().."",
    "--------------------------------------------------------"
}
os.execute("echo \""..hello_msg[3].."\n"..hello_msg[1].."\n"..hello_msg[2].."\n"..hello_msg[3].."\"")
sexec(home.."/bin/startup")
--}}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    if s==1 then
        tags[1] = awful.tag({ "α","β","γ","δ","ε","ζ" }, 1, 
            {layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[3]})
    else
        tags[s] = awful.tag({ "α","β","γ","δ","ε","ζ" }, s, 
            {layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]})
    end

end
-- }}}

-- {{{ Menu
-- Default keygrabber keys
awful.menu.menu_keys = {
    up     = { "k", "к", "Up" },
    down   = { "j", "й", "Down"  },
    exec   = { "l", "л", "Right", "Return" },
    back   = { "h", "х", "Left" },
    close  = { "Escape", "Menu" }
}

-- Create a laucher widget and a main menu
mymenu = {}
mymenu.awesome = {
   { "&manual", prg.terminal .. " -e man awesome" },
   { "LUA &docs", prg.browser .. " /usr/share/doc/awesome-9999/html/luadoc/index.html" },
   { "&edit config", prg.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "&restart", awesome.restart },
   { "&quit", hfunc.awesome_quit }
}

mymenu.web = {
    { "&icecat", "icecat" },
    { "&MUA", prg.mua },
    { "&skype", "skype" }
}

mymenu.devel = {
    { "&ipython", prg.terminal .. " -e ipython -pylab" },
    { "&sage", prg.terminal .. " -e sage" },
    { "&mathematica", "mathematica" },
    { "ms&ketch", home.."downloads/Soft/marvinbeans/bin/./msketch" }
}

mymenu.media = {
    { "&MPD client", prg.terminal .. " -e ncmpcpp" },
    { "&Visualization", "projectM-pulseaudio" },
    { "&GIMP", "gimp" },
    { "&Inkscape", "inkscape" },
    { "&QJackCtl", "qjackctl" },
    { "&Ardour", "ardour" },
}

mymenu.main = awful.menu({ 
    items = { 
        { "&terminal", prg.terminal },
        { " ", nil },
        { "&media", mymenu.media },
        { "&devel", mymenu.devel },
        { "we&b", mymenu.web },
        { "a&wesome", mymenu.awesome, beautiful.awesome_icon },
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Volume widget
volume = { widget = mixer.mywi }

-- Battery widget
battery = { widget = smapi.mywi }

-- Keyboard map indicator and changer
mykbdcfg = {}
mykbdcfg.command = "setxkbmap"
mykbdcfg.addargs = {
    "-model thinkpadz60 -option caps:hyper, terminate:ctrl_alt_bksp", -- Setxkbmap options
--    " xmodmap "..home.."/.Xmodmap"  -- Other commands to execute afterwards
}
mykbdcfg.img_dir = cfgdir.."/icons/flags/24/"
mykbdcfg.layout = {
    { "gb", "" },
    { "lt", "std" },
    { "ru", "phonetic" },
    { "fr", "" },
    { "lt", "" },
}
mykbdcfg.current = 1  -- default layout
mykbdcfg.widget = wibox.widget.imagebox()
img = oocairo.image_surface_create_from_png
mykbdcfg.widget:set_image(img(cfgdir.."/icons/flags/24/" .. mykbdcfg.layout[mykbdcfg.current][1] .. ".png"))
mykbdcfg.naughty = nil

function mykbdcfg.tog (a,b)
    if mykbdcfg.naughty then naughty.destroy(mykbdcfg.naughty) end
    local l_len = #(mykbdcfg.layout)
    local l = mykbdcfg.current
    local changed = true
    if a == "j" then
        if l == b then changed = false 
        else l = b end
    elseif a == "s" and math.abs(b) == 1 then l = l + b
        if l == 0 then l = l_len
        elseif l == l_len + 1 then l = 1 end
    else
        naughty.notify({text = "Keyboard switcher - Invalid arguments"})
        changed = false 
        error()
    end
    local t, u = mykbdcfg.layout[l], mykbdcfg.addargs
    if changed then 
        mykbdcfg.current = l
        sexec(mykbdcfg.command .. " " .. t[1] .. " " .. t[2])
        sexec(u[2])
    end
    local nt = "Current layout - " .. t[1]
    if t[2] ~= "" then 
        nt = nt .. "\nLayout variant - " .. t[2] 
    else nt = nt .. "\nLayout variant - default" 
    end
    mykbdcfg.widget:set_image(img(cfgdir.."/icons/flags/24/" .. t[1] .. ".png"))
    mykbdcfg.naughty = naughty.notify({    
        title = "XKBmap", 
        text = nt,
        icon = img(cfgdir.."/icons/flags/48/" .. t[1] .. ".png"),
        width = 250,
        timeout = 1
    })
end

mykbdcfg.menu_table = {}
for i,k in ipairs(mykbdcfg.layout) do
    mykbdcfg.menu_table[i] = { k[1].." "..k[2], 
        function () mykbdcfg.tog("j", i) end, 
        img(cfgdir.."/icons/flags/32/" .. k[1]..".png")}
end
mykbdcfg.menu = awful.menu({items = mykbdcfg.menu_table})
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mywibox2 = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )

-- Bindings for kbd widget
mykbdcfg.widget:buttons(awful.util.table.join(
    awful.button({}, 1, function () mykbdcfg.menu:toggle({keygrabber=true}) end),
    awful.button({}, 4, function () mykbdcfg.tog("s", -1) end),
    awful.button({}, 5, function () mykbdcfg.tog("s", 1) end)
))

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylayoutbox[s])
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mytextclock)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mykbdcfg.widget)
    right_layout:add(volume.widget)
    right_layout:add(battery.widget)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymenu.main:toggle({keygrabber=true}) end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, "Left",   awful.tag.viewprev),
    awful.key({ modkey }, "Right",  awful.tag.viewnext),

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
    awful.key({                   }, "Menu",    function () mymenu.main:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(  0) end),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1) end),

    awful.key({ modkey }, "XF86Forward", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey }, "XF86Back",    function () awful.screen.focus_relative(-1) end),

    awful.key({ modkey }, "u",   awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab", awful.tag.history.restore),
    awful.key({ modkey }, "`",
        function ()
            scratch.drop("urxvt","top","center",1,.4,true)
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return",  function () awful.util.spawn(prg.terminal) end),

    awful.key({ modkey, "Control" }, "r",       function () awesome.restart() end),
    awful.key({ modkey, "Shift" }, "BackSpace", function () hfunc.awesome_quit() end),

    awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1)         end),

    -- Utils
    awful.key({ modkey, "Mod1"  }, "#24", function () mykbdcfg.menu:toggle({keygrabber=true}) end),
    awful.key({ "Shift", "Mod1" }, "#44", function () mykbdcfg.tog("j", 1) end),
    awful.key({ "Shift", "Mod1" }, "#45", function () mykbdcfg.tog("j", 2) end),
    awful.key({ "Shift", "Mod1" }, "#46", function () mykbdcfg.tog("j", 3) end),
    awful.key({ "Shift", "Mod1" }, "#30", function () mykbdcfg.tog("j", 4) end),

    awful.key({ modkey, "Shift" }, "#52", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Shift" }, "#53", function () awful.layout.inc(layouts,  1) end),

    awful.key({ modkey, "Shift" }, "n",   function () awful.client.restore() end),
    awful.key({ modkey, "Shift" }, "i",   function () hfunc.lua_xev() end),

    -- Prompt
    awful.key({ modkey },            "r",     
            function () 
                awful.prompt.run({ 
                    prompt = "Zsh: " 
                }, mypromptbox[mouse.screen].widget,
                function (...) 
                    mypromptbox[mouse.screen].text = exec(unpack(arg), false)
                end,
                awful.completion.shell, awful.util.getdir("cache") .. "/history",
                50)
            end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Lua: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "Escape", function (c) c:kill() end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.sticky = not c.sticky end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized end),
    awful.key({ modkey, "Shift"   }, "XF86Forward", function (c) awful.client.movetoscreen(c, 1) end),
    awful.key({ modkey, "Shift"   }, "XF86Back",    function (c) awful.client.movetoscreen(c, -1) end),
    awful.key({ modkey, "Shift"   }, "p",
        function (c)
            local cliname = ""
            awful.prompt.run({ prompt = "Enter Client Name: " },
            mypromptbox[mouse.screen].widget,
            function(...)
                naughty.notify({text=unpack(arg)})
                c:name(unpack(arg))
            end,nil)
        end),

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey          }, "i", function (c) hfunc.client_prop(c) end)
)

-- Compute the maximum number of digit we need, limited to 6
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(6, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     size_hints_honor = false,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- floating clients
    { rule_any = { 
        instance = { "mplayer", "gimp", "nitrogen"}, 
        name = { "Event Tester", "Welcome to Wolfram Mathematica 8" }
    },
      properties = { floating = true } },
    { rule = { name = "volume::mixer" },
      properties = { floating = true, ontop = true, sticky = true } },
    { rule = { class = "Wicd-client.py"},
      properties = { floating = true, ontop = true, sticky = true } },
    { rule = { class = "Ipython"},
      properties = { floating = true, ontop = true, sticky = true } },
    { rule = { class = "Skype", name = "Call with" },
      properties = { sticky = true, ontop = true, slave=true, nofocus = true  } },
    { rule = { class = "Skype", name = "ignas.anikevicius" },
      properties = { floating = true, ontop = true, slave=true, nofocus = true  } },
    { rule = { class = "Skype" },
      properties = { switchtotag = true, tag = tags[1][6] } },
    { rule_any = { 
        instance = { "Navigator" },
        class = { "Icecat", "Firefox", "Chrome", "luakit" }
    },
      properties = { tag = tags[1][2] } },
    { rule = {
        instance = "gvim",
        name = "Thunderbird Compose Message"
        },
      properties = { tag = tags[screen.count()][5] } },
    { rule_any = {
        instance = { "Msgcompose" },
        name = { "Send Message" },
        class = { "Thunderbird" },
        },
      properties = { switchtotag = true, tag = tags[screen.count()][5] } },
    { rule = { 
        class = "Thunderbird",
        instance = "Mail"
    },
      properties = { tag = tags[1][5] } },
    { rule = {
        name = "topterm"
    },
      properties = { maximized_horizontal = true } },
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
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

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
