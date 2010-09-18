-- Written by Ignas Anikevicius (gns_ank)
--
-- Environment
local awful = require('awful')
local capi = {
    tag = tag,
    mouse = mouse,
    screen = screen,
    keygrabber = keygrabber,
    client = client
}
local ipairs = ipairs
local pairs = pairs
local table = table
local print = print

module('dyntag')

-- rules
--
-- start in particular tag:
-- if program must start in some tag, check current tag names and if the tag is absent, create new one and start the program
--

--- Tag table wich is defined in rc.lua
-- it is smth like this:
-- tags = { { name, othername } }
-- it could work like this (with a key binding you can create one more tag with
-- a name "name2" or "name3" or etc. the tag is added to the end of the inner
-- index and the tags in the inner index can be switched by a keybinding to go
-- to that inner index.
-- taglist shows only the current tag 
tag_index = {
    { "term" },
    { "calc" },
    { "tex" },
    { "web" },
    { "mail" },
    { "im", "irc" },
    { "ardour", "jack", "other" },
    { "mpd" },
    { "vm", "wine" }
}

filter = {}

match = {}
--- match.byname function is run with parameters:
-- @name the name of the tag
-- returned value is either tag or nil
function name2tag (name, scr)
    local scr = scr or capi.mouse.screen
    if not capi.screen[scr]:tags() then return nil end
    local tg, b = capi.screen[scr]:tags(), {}
    for _, v in ipairs(tg) do
        if v.name ~= name then 
        end
    end
end

--{{{ pos2idx: translate shifty position to tag index
--@param pos: position (an integer)
--@param scr: screen number
function pos2idx(pos, scr)
  local v = 1
  if pos and scr then
    for i = #capi.screen[scr]:tags() , 1, -1 do
      local t = capi.screen[scr]:tags()[i]
      if awful.tag.getproperty(t,"position") and awful.tag.getproperty(t,"position") <= pos then
        v = i + 1
        break 
      end
    end
  end
  return v
end
--}}}

function match.name_s (name, scr)
    local scr = scr or capi.mouse.screen
    if not capi.screen[scr]:tags() then return nil end
    local tg, b = capi.screen[scr]:tags(), 1
    for _,v in ipairs(tg) do
        if v.name == name then return v end
    end
end

function match.tagrule (c, args)
    local args = args or {}
    local scr = args.screen or capi.mouse.screen
    local tag = match.name_s (args.name, scr)
    if not tag then tag = add(args.name, { layout = args.layout or awful.layout.suit.tile })
    --elseif type(tag) ~= "tag" then return 
    end
    c:tags({ tag })
    c.screen = c.tag
end

function add(name, props)
    local tag = match.name_s(name)
    if not tag then 
        local pos
        for _,k in ipairs(tag_index) do
            for __,j in ipairs(k) do
                if name == j then pos = _ end
            end
        end
        local pos_r = pos2idx(pos, capi.mouse.screen)
        tag = awful.tag.add(name, props)
        awful.tag.move(pos_r, tag)
    end
    awful.tag.viewonly(tag)
    return tag
end

function add_p(prompt_box)
    awful.prompt.run({ prompt = "New Tag: " }, prompt_box[capi.mouse.screen].widget,
    function (name, props)
        add(name,props)
    end,
    awful.util.getdir("cache") .. "/history_eval")
end

function c_move(name, scr)
    local scr = scr or capi.client.focus.creen
    local tag = match.byname(name, scr)
    if not tag then 
        tag = awful.tag.add(name, props)
    end
    awful.client.movetotag(tag)
end

--- Filtering function to include current and urgent tags on the screen.
-- @param t The tag.
-- @param screen The screen we are drawing on.
-- @return true if t is not empty, else false
function filter.minimal(t, args)
    if t.selected then
        return true
    else
        for _,k in ipairs(t:clients()) do 
            print(_,k)
            if k.urgent then return true end 
        end
    end

    return false
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
