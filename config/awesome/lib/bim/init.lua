-- A mode utility to help with the key bindings
-- (C) Copyright Ignas Anikevicius
--
local ipairs = ipairs
local setmetatable = setmetatable
local print = print

local capi = {
    root = root,
    client = client,
    mouse = mouse
}

local theme = require("beautiful").get()
local awful = {
    util = require("awful.util"),
}
local naughty = require("naughty")

M = { }

local mode_not = nil

