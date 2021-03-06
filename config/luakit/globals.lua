-- Global variables for luakit
globals = {
    homepage            = "http://archlinux.org/",
 -- homepage            = "http://luakit.org/",
 -- homepage            = "http://github.com/mason-larobina/luakit",
    scroll_step         = 40,
    zoom_step           = 0.1,
    max_cmd_history     = 100,
    max_srch_history    = 100,
 -- http_proxy          = "http://example.com:3128",
    default_window_size = "800x600",

 -- Disables loading of hostnames from /etc/hosts (for large host files)
 -- load_etc_hosts      = false,
 -- Disables checking if a filepath exists in search_open function
 -- check_filepath      = false,
}

-- Make useragent
local _, arch = luakit.spawn_sync("uname -sm")
-- Only use the luakit version if in date format (reduces identifiability)
local lkv = string.match(luakit.version, "^(%d+.%d+.%d+)")
globals.useragent = string.format("Mozilla/5.0 (%s) AppleWebKit/%s+ (KHTML, like Gecko) WebKitGTK+/%s luakit%s",
    string.sub(arch, 1, -2), luakit.webkit_user_agent_version,
    luakit.webkit_version, (lkv and ("/" .. lkv)) or "")
globals.useragent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/22.0.1207.1 Safari/537.1"

-- Search common locations for a ca file which is used for ssl connection validation.
local ca_files = {
    -- $XDG_DATA_HOME/luakit/ca-certificates.crt
    luakit.data_dir .. "/ca-certificates.crt",
    "/etc/certs/ca-certificates.crt",
    "/etc/ssl/certs/ca-certificates.crt",
}
-- Use the first ca-file found
for _, ca_file in ipairs(ca_files) do
    if os.exists(ca_file) then
        soup.ssl_ca_file = ca_file
        break
    end
end

-- Change to stop navigation sites with invalid or expired ssl certificates
soup.ssl_strict = false

-- Set cookie acceptance policy
cookie_policy = { always = 0, never = 1, no_third_party = 2 }
soup.accept_policy = cookie_policy.always

-- List of search engines. Each item must contain a single %s which is
-- replaced by URI encoded search terms. All other occurances of the percent
-- character (%) may need to be escaped by placing another % before or after
-- it to avoid collisions with lua's string.format characters.
-- See: http://www.lua.org/manual/5.1/manual.html#pdf-string.format
search_engines = {
    luakit      = "http://luakit.org/search/index/luakit?q=%s",
    google      = "http://google.com/search?q=%s",
    duckduckgo  = "http://duckduckgo.com/?q=%s",
    wikipedia   = "http://en.wikipedia.org/wiki/Special:Search?search=%s",
    imdb        = "http://imdb.com/find?s=all&q=%s",
    sourceforge = "http://sf.net/search/?words=%s",
-- Additional search engines 
    zugaina     = "http://gpo.zugaina.org/Search?search=%s",
    genbugs     = "http://bugs.debian.org/buglist.cgi?quicksearch=%s",
    genwiki     = "http://en.gentoo-wiki.com/w/index.php?search=%s&go=Go",
    youtube     = "http://www.youtube.com/results?search_query=%s",
    linkomanija = "http://www.linkomanija.net/browse.php?search=%s",
    goem        = "http://goem.org/browse.php?search=%s",
    github      = "https://github.com/search?q=%s",
    thinkwiki   = "http://www.thinkwiki.org/wiki/Special:GoogleFind?domains=www.thinkwiki.org&q=%s",
    amazonuk    = "http://www.amazon.co.uk/s/?field-keywords=%s",
    ebayuk      = "http://www.ebay.co.uk/sch/i.html?_nkw=%s",
    archwiki    = "https://wiki.archlinux.org/index.php?search=%s&go=Go"
}

-- Some shortucts for the search engines:
search_engines.eix  = search_engines.zugaina
search_engines.g    = search_engines.google
search_engines.y    = search_engines.youtube
search_engines.lm   = search_engines.linkomanija
search_engines.ghub = search_engines.github
search_engines.tw   = search_engines.thinkwiki
search_engines.w    = search_engines.wikipedia
search_engines.awi  = search_engines.archwiki

-- Set google as fallback search engine
search_engines.default = search_engines.google
-- Use this instead to disable auto-searching
--search_engines.default = "%s"

-- Per-domain webview properties
-- See http://webkitgtk.org/reference/webkitgtk/stable/WebKitWebSettings.html
domain_props = { --[[
    ["all"] = {
        enable_scripts          = false,
        enable_plugins          = false,
        enable_private_browsing = false,
        user_stylesheet_uri     = "",
    },
    ["youtube.com"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["bbs.archlinux.org"] = {
        user_stylesheet_uri     = "file://" .. luakit.data_dir .. "/styles/dark.css",
        enable_private_browsing = true,
    }, ]]
}

-- vim: et:sw=4:ts=8:sts=4:tw=80
