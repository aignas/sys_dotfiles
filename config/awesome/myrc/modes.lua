-- menustuff module
-- how it works
--      user defines his bindings for each mode with the first binding being key
--          to switch to and from the mode
--      there is a master table which stores
--          name of the mode (user defined)
--          their key bindings (generated from user key bindings)
--          their desc string (generated from user key bindings)
--
--      user enters the mode and the keys are changed (not inserted)
--      if help button is pressed the help notification appears
--      a notification indicating one is in the mode is shown all the time
--          except normal mode
--
-- Keys for mpd mode:
--      client
--      prev, toggle, stop, next
--      seek back, dec/inc vol, seek fwd
--      exit
--
-- Keys for the launch mode:
--      programs
--      todo list
--      alarms list
--      menu
--
-- Make shortcuts of several keypresses possible. How it could be achieved:
--      for cycle for every letter in the string
--      the bindings are sorted in multiple layers according to letters in respective tables which are defined.
--      The binding mechanism would be more like a dirrectory tree.
--      maybe everything could be done in a modifiers way?
--
--keys_global_def = awful.util.table.join(
-- mpd client with good keybindings
--    awful.key({ modkey    }, "m",       function() mode_switch(mode.mpd) end),
-- launch various programs (maybe should be merged with menumode or viceversa)
--    awful.key({ modkey    }, "l",       function() mode_enter(keys_launch) end),
-- functions of switching tags, creating, deleting and moving them
--    tag_manipulation,
-- layout manipulation
--    layout_manipulation,
-- prompts
--    prompt_keys
--)

require("awful")
require("lib/vimo")
-- kAwouru's MPD library
require("lib/mpd") ; mpc = mpd.new({ hostname="localhost" })

local awful = awful

module("myrc.keybindings")

key.mpd = awful.util.table.join(
    key({ modkey, altkey }, "m", "Toggle mode", function () mode_switch("mpd") end),
    key({           }, "c", "launch client", function ()
                              exec(env.mpd_client .. " &")
                              mode_exit()
                          end),
    key({           }, "y", "seek 5s back", function () mpc:seek(-5) end),
    key({           }, "o", "seek 5s fwd",  function () mpc:seek( 5) end),
    key({           }, "u", "vol down",     function () mpc:volume_down(1) end),
    key({           }, "i", "vol up",       function () mpc:volume_up(1) end),
    key({           }, "h", "previous",     function () mpc:previous end),
    key({           }, "l", "next",         function () mpc:next( 5) end),
    key({           }, "j", "play/pause",   function () mpc:toggle_play(1) end),
    key({           }, "k", "stop",         function () mpc:stop(1) end),
)

-- Modular program launching
key.launch = awful.util.table.join(
    key({ modkey, altkey }, "l", "Toggle mode", function () mode_switch("launch") end),
    key({           }, "t", "Todo list",    function () end),
    key({           }, "x", "terminal",     function () end),
    key({ altkey    }, "x", "alt term",     function () end),
    key({           }, "n", "net man tray", function () end),
    key({ altkey    }, "n", "net man",      function () end),
    key({           }, "g", "ed",           function () end),
    key({           }, "b", "browser",      function () end),
    key({           }, "m", "mail reader",  function () end),
    key({           }, "s", "skype",        function () end),
    key({           }, "i", "irc client",   function () end)
)
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
