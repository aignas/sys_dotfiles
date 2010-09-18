local key_buffer = ""

--- Compare a key object with modifiers and key.
-- @param key The key object.
-- @param pressed_mod The modifiers to compare with.
-- @param pressed_key The key to compare with.
function match(key, pressed_mod, pressed_key)
    if string.len(pressed_key) > 1 then pressed_key = "<"..pressed_key..">" end
    -- First, add it to the buffer
    key_buffer = key_buffer .. pressed_key
    -- Then compare the buffer with the key
    if key_buffer ~= key.key 
        then return false
        else 
    -- Then, compare mod
    local mod = key.modifiers
    -- For each modifier of the key object, check that the modifier has been
    -- pressed.
    for _, m in ipairs(mod) do
        -- Has it been pressed?
        if not util.table.hasitem(pressed_mod, m) then
            -- No, so this is failure!
            return false
        end
    end
    -- If the number of pressed modifier is ~=, it is probably >, so this is not
    -- the same, return false.
    if #pressed_mod ~= #mod then
        return false
    end
    return true
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
