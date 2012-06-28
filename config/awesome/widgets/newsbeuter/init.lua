-- Newsbeuter widget
-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment


local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')
local capi = {
    awesome = awesome,
    timer = timer,
    wibox = wibox
}

local io = require('io')
local assert = assert
local setmetatable = setmetatable
local tostring = tostring
local string = string
local cfgdir = awful.util.getdir("config")
local sexec  = awful.util.spawn_with_shell
--}}}

module('newsbeuter')

function set_text(args)
    local text = args.text or "0"
    --text = string.match(text, "%d+")
    local widget = args.widget or mynewscount.wi or nil
    if not widget then
        return false
    else
        widget:set_text(text)
    end
end

function new()
    mynewscount = {}
    mynewscount.wi = capi.wibox.widget.textbox()
    mynewscount.wi:set_text('%%')
    mynewscount.l_wi = capi.wibox.layout.margin(
      mynewscount.wi,    -- widget to use
      2,1,2,2       -- l,r,t,b
    )
    local myicon = {}
    myicon.wi = capi.wibox.widget.imagebox()
    myicon.wi:set_image(capi.awesome.load_image(cfgdir .. "/widgets/rss.png"))
    myicon.l_wi = capi.wibox.layout.margin(
      myicon.wi,    -- widget to use
      4,1,2,2       -- l,r,t,b
    )

    local mywi = capi.wibox.layout.fixed.horizontal()
    mywi:add(myicon.l_wi)
    mywi:add(mynewscount.l_wi)

    local file = assert(io.popen('newsbeuter -x print-unread'))
    local output = file:read('*all')
    file:close()
    output = string.match(output, "%d+")
    set_text({text="?/"..output})

    return mywi
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })
