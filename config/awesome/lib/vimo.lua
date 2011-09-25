-- ViMo library

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local table = { 
    insert = table.insert
}
local capi = {
    root = root
}

local awesome = awesome
local ipairs = ipairs
local pairs = pairs
local tostring = tostring

local modkey = "Mod4"
local altkey = "Mod1"
local ctrlkey = "Control"
local shkey = "Shift"

module("vimo")

-- Reserved
local mastertable = {}
keys_global_def = {}
--use shifty?
shifty_use = false
naughty_width = 150

local mode_state = "none"

function init (table)
    for l,v in pairs(table) do
        local t = { name = "", keytable = {}, descr = "" }
        t.name = l
        for _, k in ipairs(v) do
            if _ == 1 then keys_global_def = awful.util.table.join(keys_global_def, k.keys) end
            t.keytable = awful.util.table.join(t.keytable, k.keys)
            t.descr = t.descr .. "\n"
            t.descr = t.descr ..  tostring(k.keysym) .. " : " ..  ( k.desc or "<no_description>" )
        end
        t.keytable = awful.util.table.join(t.keytable,
                        awful.key({ "Control" }, "c", function () mode_switch("none") end),
                        awful.key({ }, "Escape", function () mode_switch("none") end),
                        awful.key({ modkey }, "h", 
                            function () help_switch(t.name) end))
        mastertable[t.name] = { t.name, t.keytable, t.descr }
    end
    return keys_global_def
end

function mode_switch (mode)
    local keys_global = {}
    if ( mode_state ~= "none" or mode == "none" ) then 
        keys_global = keys_global_def
        naughty.destroy(mode_keychain)
        naughty.destroy(help_keychain)
        help_keychain = false
        mode_state = "none"
    else
        keys_global_def = capi.root.keys()
        mode_state = mastertable[mode][1]
        mode_keychain = naughty.notify({
            text = mode_state .. " mode active",
            timeout = 0,
            position = "bottom_right",
            width = naughty_width,
            bg = "#705050"
        })
        keys_global = awful.util.table.join( mastertable[mode][2] )
    end
    return capi.root.keys(keys_global)
end

function help_switch (mode)
    if not help_keychain then 
        help_keychain = naughty.notify({
            title = mastertable[mode][1] .. " mode help",
            text = mastertable[mode][3],
            timeout = 0,
            width = naughty_width,
            position = "bottom_right",
        })
    else 
        naughty.destroy(help_keychain)
        help_keychain = false
    end
end

function key (mod, key, desc, press, release)
    local modlist, b = "", ""
    for a = 1, #mod do
        if mod[a] == modkey then b = "$"
        elseif mod[a] == altkey then b = "M"
        elseif mod[a] == ctrlkey then b = "C"
        elseif mod[a] == shkey then b = "S"
        end
        modlist = tostring(modlist .. b)
    end
    if #mod > 0 then modlist = tostring(modlist .. "-") end
	local k = {
		keys = awful.key(mod, key, press, release),
		keysym = modlist .. tostring(key),
		desc = tostring(desc),
	}
    return k
end

buffer = ""
function bufkey (mod, exp, func)
    -- the first key will denote the button to activate this thing
    -- the later will be grabbed via capi.keygrabber.run
    -- and if everything is true, then execute the function.
    --
    -- This should be combined with the existing mode code as it would  be
    -- easier to incorporate the help function.
    local key = ""
    if exp:sub(1,1) == "<" then
        key = exp:match("<.->"):sub(2,-2)
    else
        key = exp(1,1)
    end
    return key( mod, key, func )
    
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
