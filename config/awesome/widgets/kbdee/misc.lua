--{{{ Some leftover functions
-- A function stolen from
--    http://lua-users.org/wiki/SplitJoin
local function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function M.layout.xkb_check()
    local f = assert(io.popen("setxkbmap -query"))
    local l,v = "", ""
    local l_t, v_t = {},{}
    for line in f:lines() do
        if line:match("layout") then
            l = line:sub(13)
        end
        if line:match("variant") then
            v = line:sub(13)
        end
    end
    f:close()

    l_t = Split(l,",")
    l_v = Split(v,",")

    for i,k in ipairs(M.cfg.layout) do
        if k[1] == l_t[i] and k[2] == l_v[i] then
            M.cfg.current = i
            return true
        end
    end
    return false
end
--}}}
