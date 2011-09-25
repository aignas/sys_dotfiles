---------------------------------------------------------------------------
-- @author Ignas Anikevicius &lt;anikevicius@gmail.com&gt;
-- @copyright 2010 Ignas Anikevicius
-- @release v
---------------------------------------------------------------------------

---
-- BIM - Bindings IMproved
--
-- So it will be stuff for awful.
--
--- A rewrite of vimo library.
-- Now keygrabber is utilised. All key presses are registered when in the mode. It returns either if a match is found and a command is executed. It does not stop matching if there is a particular mode activated.
-- Scheme:
--
-- Keygrabber
--  Breaking characters -> go out of the mode
--  Completion key -> show all possible variants.
--  More than 1 match -> true
--  elseif 1 match -> execute and empty buffer
--  elseif 0 matches -> empty buffer
--
-- Table of the keys:
--  { mod = {}, key sequence, title, exec command }
--
-- More functions:
--  keys with names more than 1-character-long are placed in <> (e.g. <Menu>, <F1>)
--  after <Tab> is pressed, then the matches are shown via naughty
--

-- Grab environment we need
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local capi = { 
    key = key,
    keygrabber = keygrabber
}
local util = require("awful.util")

--- Create easily new key objects ignoring certain modifiers.
module("awful.buffer")

--- Modifiers to ignore.
-- By default this is initialized as { "Lock", "Mod2" }
-- so the Caps Lock or Num Lock modifier are not taking into account by awesome
-- when pressing keys.
-- @name ignore_modifiers
-- @class table
ignore_modifiers = { "Lock", "Mod2" }

-- control keys which are used to control everything while in buffer mode.
local control_keys = {}

-- TODO find an easy way how to hook up this function that 
--      the defaultkeys should not be defined somewhere very far.
function defaultkeys (args)
    local ret = {}
    local key = {}
    key.completion = args.completion or "Tab"
    key.toggle = args.toggle or "Menu"
    local subsets = util.subsets(ignore_modifiers)
    -- enter the mode
    k = capi.key({key = key.toggle})
    k:connect_signal("press", function(kobj, ...) enter(...) end)
    -- completion
    control_keys:insert({ mod = "", key = key.completion })
    return ret
end

--- Create a buffer key binding to use.
-- If a modifier is used, then just simply add the specified key combination to the exception list.
--
function new(keys, title, func)
    return { [keys] = { t = title, f = func } }
end


--- Compare a buffer object with current buffer.
-- @param buffer The buffer which is in the memory now.
-- @param keytable The keytable from which to get the possible key sequences.
--
-- TODO display matched stuff function.
function enter (keytable) 
    capi.keygrabber.run(
    function(modifiers, key, event)
        local mod_t = {}
        local mod = ""
        for k,v in ipairs(modifiers) do mod_t[v] = true end
        if ( mod_t.Control and key == "c" ) 
            or ( mod_t.Contorl and key == "[" )
            or ( key == "Escape" ) 
            or ( mod_t.Mod1 and key == "l" ) 
        then return false end
        if key == "Tab" then
            --display matched stuff
            return true
        end
        if key:len() > 1 then key = "<"..key..">" end
        if #match_buffer > 1 then
            return true
        else
            buffer = ""
            if #match_buffer == 1 then keytable[match_buffer[1]].func end
            return false
        end
    end)
end

--- This basically works as follows:
--  buffer is being search in the dictionary of buffer binds.
--  and the returned value is title and the function to execute.
--
--  TODO match only from the beginning of the word.
function match_buffer (buffer, keytable)
    -- if a current buffer is of lenght zero or a not a string, then return nil.
    if buffer:len() == 0 or type(buffer) ~= "string" then return nil end
    keytable = bufferkeys or keytable
    if #keytable == 0 then return nil end
    local ret
    for bind, entry in pairs(table) do
        if bind:match(buffer) then
            ret[#ret +1] = entry
        end
    end
    return ret
end

function mode_keygrab (mod, key, event)
    keygrabber.run(
    function(mod, key, event)
        

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
