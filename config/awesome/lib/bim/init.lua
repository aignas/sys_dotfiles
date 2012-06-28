---------------------------------------------------------------------------
-- @author Ignas Anikevicius &lt;anikevicius@gmail.com&gt;
-- @copyright 2010 Ignas Anikevicius
-- @release v
---------------------------------------------------------------------------
--
--[[ 
This library is called Bindings IMproved.

The idea of the library:
--]]


-- Grab environment we need
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local capi = { 
    key = key,
    keygrabber = keygrabber
}
local awful = require("awful")

--- Create easily new key objects ignoring certain modifiers.
module("bim")

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:foldmethod=marker
