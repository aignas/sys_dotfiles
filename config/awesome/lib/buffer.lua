---------------------------------------------------------------------------
-- @author Ignas Anikevicius &lt;anikevicius@gmail.com&gt;
-- @copyright 2010 Ignas Anikevicius
-- @release v
---------------------------------------------------------------------------

-- get the needed environment
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local capi = { 
    keygrabber = keygrabber
}
local debug = debug
local string = string
local print = print
local naughty = require("naughty")
local util = require("awful.util")

--- Create easily new key objects ignoring certain modifiers.
module("buffer")

--- {{{
-- Configurable stuff, which _should_ be configured from rc.lua
config = {
}
--
--- }}}

--- {{{
-- Defaults
keys_enter = config.keys_enter or {
    { {}, "Menu" }
}
keys_exit = config.keys_exit or {
    { {}, "Menu" },
    { {}, "Escape" },
    { {"Mod1"}, "l" },
    { {"Control"}, "c" }
}
-- a binding key looks like this:
-- key_table = {
--      ["m<F12>"] = function () print("Hello world"),
--      ["m<F11>"] = function () print("Hello world 2"),
-- }
keys = config.keys or {}
--
--- }}}

-- Buffer definition
buffer = ""
buffer_display = nil
-- mode variables
mode = {}
mode.current_key = ""
mode.current = false
mode.current_name = ""

fu_completion = function (args)
    local matches = {}
    if keys and args then
        for i,v in pairs(keys) do
            if i:match(args) then
                matches[#matches + 1] = i
            end
        end
    end
    return matches
end

fu_exec = function(args)
    keys[args]()
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
