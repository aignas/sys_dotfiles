-- Global variables for luakit
globals = {
 -- homepage         = "http://luakit.org/",
 -- homepage         = "http://github.com/mason-larobina/luakit",
    homepage         = "http://archlinux.org/",
    scroll_step      = 20,
    zoom_step        = 0.1,
    max_cmd_history  = 100,
    max_srch_history = 100,
 -- http_proxy       = "http://example.com:3128",
    download_dir     = luakit.get_special_dir("DOWNLOAD") or (os.getenv("HOME") .. "/downloads"),
}

-- Make useragent
local rv, out, err = luakit.spawn_sync("uname -sm")
local webkit_version = string.format("WebKitGTK+/%d.%d.%d", luakit.webkit_major_version,
    luakit.webkit_minor_version, luakit.webkit_micro_version)
local luakit_version = string.format("luakit/%s", luakit.version)
globals.useragent = string.format("Mozilla/5.0 (%s) %s %s", string.match(out, "([^\n]*)"), webkit_version, luakit_version)

-- Search common locations for a ca file which is used for ssl connection validation.
local ca_files = {luakit.data_dir .. "/ca-certificates.crt",
    "/etc/certs/ca-certificates.crt", "/etc/ssl/certs/ca-certificates.crt",}
for _, ca_file in ipairs(ca_files) do
    if os.exists(ca_file) then
        globals.ca_file = ca_file
        break
    end
end

-- Change to stop navigation sites with invalid or expired ssl certificates
globals.ssl_strict = false

-- Search engines
search_engines = {
    luakit      = "http://luakit.org/search/index/luakit?q={0}",
    google      = "http://google.com/search?q={0}",
    duckduckgo  = "http://duckduckgo.com/?q={0}",
    Wiki        = "http://en.wikipedia.org/wiki/Special:Search?search={0}",
    debbugs     = "http://bugs.debian.org/{0}",
    imdb        = "http://imdb.com/find?s=all&q={0}",
    sourceforge = "http://sf.net/search/?words={0}",

    ThinkWiki   = "http://www.thinkwiki.org/wiki/Special:GoogleFind?domains=www.thinkwiki.org&q={0}&sa=Google+Search&sitesearch=www.thinkwiki.org&client=pub-9115710338321120&forid=1&channel=1405984697&ie=ISO-8859-1&oe=ISO-8859-1&sig=myLy8cf2xe40P1pS&cof=GALT%3A%23606060%3BGL%3A1%3BDIV%3A%23336699%3BVLC%3A663399%3BAH%3Acenter%3BBGC%3AFFFFFF%3BLBGC%3A336699%3BALC%3A002bb8%3BLC%3A002bb8%3BT%3A000000%3BGFNT%3A002bb8%3BGIMP%3A002bb8%3BFORID%3A9&hl=en",
    AUR         = "http://aur.archlinux.org/packages.php?O=0&K={0}&do_Search=Go",
    ArchWiki    = "http://wiki.archlinux.org/index.php?title=Special%3ASearch&search={0}&go=Go",
    ArchForums  = "https://bbs.archlinux.org/search.php?action=search&keywords={0}&author=&forum=-1&search_in=all&sort_by=0&sort_dir=DESC&show_as=topics&search=Submit",
    youtube     = "http://www.youtube.com/results?search_query={0}&aq=f"
}

-- Fake the cookie policy enum here
cookie_policy = { always = 0, never = 1, no_third_party = 2 }

-- Per-domain webview properties
domain_props = { --[[
    ["all"] = {
        ["enable-scripts"]          = false,
        ["enable-plugins"]          = false,
        ["enable-private-browsing"] = false,
        ["user-stylesheet-uri"]     = "",
        ["accept-policy"]           = cookie_policy.never,
    },
    ["youtube.com"] = {
        ["enable-scripts"] = true,
        ["enable-plugins"] = true,
    },
    ["lwn.net"] = {
       ["accept-policy"] = cookie_policy.no_third_party,
    },
    ["forums.archlinux.org"] = {
        ["user-stylesheet-uri"]     = luakit.data_dir .. "/styles/dark.css",
        ["enable-private-browsing"] = true,
    }, ]]
}

-- vim: et:sw=4:ts=8:sts=4:tw=80
