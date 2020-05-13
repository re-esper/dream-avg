-----------------------------------------------------------------------------------------
-- strict mode
-----------------------------------------------------------------------------------------

if DEBUG > 0 then
    -- strict mode
    rawset(_G, "__G__STRICTWARNING__", true)
    setmetatable(_G, {
        __newindex = function(t, k, v)
            if tostring(k) ~= "_" and __G__STRICTWARNING__ then
                printf("[WARN] implicitly setting _G['%s'] = %s:(%s:%d)", tostring(k), tostring(v), debug.getinfo(2, "S").source, debug.getinfo(2, "l").currentline)
            end
            rawset(t, k, v)
        end,
        __index = function(t, k)
            return nil
        end
    })
end

local export = function(name, val)
    if _G[name] and DEBUG > 0 then
        assert(false, string.format("ERROR: already exported %s = %s, re-assigning to %s:(%s:%d)", tostring(name), tostring(_G[name]), tostring(val), debug.getinfo(2, "S").source, debug.getinfo(2, "l").currentline))
    end
    rawset(_G, name, val)
end
rawset(_G, "export", export)

-----------------------------------------------------------------------------------------
-- utils
-----------------------------------------------------------------------------------------

function unrequire(m)
    package.loaded[m] = nil
    rawset(_G, m, nil)
end

-- array only!
function table.reverse(t)
    local size = #t
    local newt = {} 
    for i, v in ipairs(t) do
        newt[size-i] = v
    end 
    return newt
end
-- array only!
function table.random(t)
    if #t > 0 then return t[math.random(#t)] end
end

function table.isarray(t)
    local idx = 1
    for k, _ in pairs(t) do
        if k ~= idx then return false end
        idx = idx + 1
    end
    return true
end

function table.tostring(value, serializable)
    local result
    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end
    local function _k(v)
        if type(v) == "number" then
            v = "[" .. v .. "]"
        end
        return tostring(v)        
    end
    local function _dump(value, key, indent, keylen)
        local spc = ""
        local childcnt = 0
        if keylen then
            spc = string.rep(" ", keylen - string.len(_k(key)))
        end
        local vt = type(value)
        if vt ~= "table" then
            if not serializable or vt == "number" or vt == "string" or vt == "boolean" then
                result = result .. string.format("\n%s%s%s = %s", indent, _k(key), spc, _v(value))
            else
                -- the value is skipped
                return false 
            end
        else
            if not result then
                result = "{"
            else
                result = result .. "\n" .. string.format("%s%s = {", indent, _k(key))
            end
            local indent2 = indent .. "    "
            local keys = {}
            local keylen = 0
            local values = {}
            for k, v in pairs(value) do
                keys[#keys + 1] = k
                local vk = _v(k)
                local vkl = string.len(vk)
                if vkl > keylen then keylen = vkl end
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            local firstchild = true
            local ischildvalid = true
            for i, k in ipairs(keys) do
                if firstchild then
                    firstchild = false
                elseif ischildvalid then
                    result = result .. "," 
                end
                ischildvalid = _dump(values[k], k, indent2, keylen)
            end
            result = result .. "\n" .. string.format("%s}", indent)
        end
        -- the value is valid
        return true
    end
    _dump(value, "", "")
    return result
end

function table.compare(t1, t2)
    local function _comp(t1, t2)
        local ty1 = type(t1)
        local ty2 = type(t2)
        if ty1 ~= ty2 then return false end
        if ty1 ~= "table" and ty2 ~= "table" then return t1 == t2 end
        for k1, v1 in pairs(t1) do
            local v2 = t2[k1]
            if v2 == nil or not _comp(v1, v2) then return false end
        end
        for k2, v2 in pairs(t2) do
            local v1 = t1[k2]
            if v1 == nil or not _comp(v1, v2) then return false end
        end
        return true
    end
    return _comp(t1, t2)
end


function math.clamp(input, min_val, max_val)
    if input < min_val then
        input = min_val
    elseif input > max_val then
        input = max_val
    end
    return input
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.rrand(min_val, max_val)
    return math.random() * (max_val - min_val) + min_val
end
