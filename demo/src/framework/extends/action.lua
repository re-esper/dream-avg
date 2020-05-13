local cca = {}

-- instant
local function _ccaInstantAction(name, action)
    action = action or cc[name:gsub("^%w", string.upper)]
    cca[name] = function(t) return action:create(unpack(t)) end
end

_ccaInstantAction("show")
_ccaInstantAction("hide")
_ccaInstantAction("toggle", cc.ToggleVisibility)
_ccaInstantAction("removeSelf", cc.ToggleVisibility)
_ccaInstantAction("flipX")
_ccaInstantAction("flipY")
_ccaInstantAction("place")
_ccaInstantAction("call", cc.CallFunc)


-- easing
local _ease_table = {}
local function _ccaEaseAction(name, rate)
    local cls = "Ease" .. name:gsub("^%w", string.upper)
    if rate then
        _ease_table[name] = function(act) return cc[cls]:create(act, rate) end
    else
        _ease_table[name] = function(act) return cc[cls]:create(act) end
    end
end

_ccaEaseAction("backIn")
_ccaEaseAction("backOut")
_ccaEaseAction("backInOut")
_ccaEaseAction("bounceIn")
_ccaEaseAction("bounceInOut")
_ccaEaseAction("bounceOut")
_ccaEaseAction("elasticIn", 0.3)
_ccaEaseAction("elasticInOut", 0.3)
_ccaEaseAction("elasticOut", 0.3)
_ccaEaseAction("exponentialIn")
_ccaEaseAction("exponentialInOut")
_ccaEaseAction("exponentialOut")
_ccaEaseAction("in", 1.0)
_ccaEaseAction("inOut", 1.0)
_ccaEaseAction("out", 1.0)
_ccaEaseAction("sineIn")
_ccaEaseAction("sineInOut")
_ccaEaseAction("sineOut")

-- interval
local function _ccaIntervalAction(name, action)
    action = action or cc[name:gsub("^%w", string.upper)]
    cca[name] = function(t)
        local ease = _ease_table[t[#t]]
        if ease then
            table.remove(t)
            return ease(action:create(unpack(t)))
        else
            return action:create(unpack(t))
        end
    end
end

_ccaIntervalAction("rotateTo")
_ccaIntervalAction("rotateBy")
_ccaIntervalAction("moveTo")
_ccaIntervalAction("moveBy")
_ccaIntervalAction("skewTo")
_ccaIntervalAction("skewBy")
_ccaIntervalAction("jumpTo")
_ccaIntervalAction("jumpBy")
_ccaIntervalAction("bezierTo")
_ccaIntervalAction("bezierBy")
_ccaIntervalAction("splineTo", cc.CardinalSplineTo)
_ccaIntervalAction("splineBy", cc.CardinalSplineBy)
_ccaIntervalAction("romTo", cc.CatmullRomTo)
_ccaIntervalAction("romBy", cc.CatmullRomBy)
_ccaIntervalAction("scaleTo")
_ccaIntervalAction("scaleBy")
_ccaIntervalAction("blink")
_ccaIntervalAction("fadeTo")
_ccaIntervalAction("fadeIn")
_ccaIntervalAction("fadeOut")
_ccaIntervalAction("tintTo")
_ccaIntervalAction("tintBy")
_ccaIntervalAction("orbitCamera")

cca["moveTo"] = function(t)
    local ease = _ease_table[t[#t]]
    local duration, x, y = unpack(t)
    local action
    if type(x) == "table" then
        action = cc.MoveTo:create(duration, x)
    else
        action = cc.MoveTo:create(duration, cc.p(x, y))
    end
    if ease then
        return ease(action)
    else
        return action
    end
end

cca["moveBy"] = function(t)
    local ease = _ease_table[t[#t]]
    local duration, x, y = unpack(t)
    local action
    if type(x) == "table" then
        action = cc.MoveBy:create(duration, x)
    else
        action = cc.MoveBy:create(duration, cc.p(x, y))
    end
    if ease then
        return ease(action)
    else
        return action
    end
end

cca["jumpTo"] = function(t)
    local ease = _ease_table[t[#t]]
    local duration, x, y, height, count = unpack(t)
    local action
    if type(x) == "table" then
        action = cc.JumpTo:create(duration, x, y, height)
    else
        action = cc.JumpTo:create(duration, cc.p(x, y), height, count)
    end
    if ease then
        return ease(action)
    else
        return action
    end
end

cca["jumpBy"] = function(t)
    local ease = _ease_table[t[#t]]
    local duration, x, y, height, count = unpack(t)
    local action
    if type(x) == "table" then
        action = cc.JumpBy:create(duration, x, y, height)
    else
        action = cc.JumpBy:create(duration, cc.p(x, y), height, count)
    end
    if ease then
        return ease(action)
    else
        return action
    end
end

-- 3 formats:
-- animate { animation } animation is a cc.Animation instance
-- animate { "animationName" } animation name in AnimationCache
-- animate { pattern, start, end, time }
cca["animate"] = function(t)
    local paramcnt = #t
    local ease = _ease_table[t[paramcnt]]
    if ease then paramcnt = paramcnt - 1 end
    local animation
    if paramcnt == 4 then
        animation = cc.Animation:build(unpack(t))
    else
        local ani = t[1]
        if type(ani) == "userdata" and tolua.type(ani) == "cc.Animation" then
            animation = ani
        else
            animation = AnimationCache:getAnimation(ani)
        end
    end
    assert(animation, "cca.animate - invalid animation")
    if ease then
        return ease(cc.Animate:create(animation))
    else
        return cc.Animate:create(animation)
    end
end

-- remove easing support of "delay"
cca["delay"] = function(t)
    return cc.DelayTime:create(unpack(t))
end

-- specials
-- format: spawn { ..., "ease" }
cca["spawn"] = function(t)
    local ease = _ease_table[t[#t]]
    if ease then table.remove(t) end
    local action = #t > 1 and cc.Spawn:create(unpack(t)) or t[1]
    if ease then
        return ease(action)
    else
        return action
    end
end

-- format: sequence { n, ..., "ease" }, repeat n times
-- if n == -1, repeat forever
-- n and "ease" can be ignored
cca["sequence"] = function(t)
    local ease = _ease_table[t[#t]]
    if ease then table.remove(t) end
    local times = t[1]
    if type(times) == "number" then table.remove(t, 1) end
    local action = #t > 1 and cc.Sequence:create(unpack(t)) or t[1]
    if ease then
        action = ease(action)
    end
    if type(times) ~= "number" then
        return action
    elseif times > 0 then
        return cc.Repeat:create(action, times)
    else
        return cc.RepeatForever:create(action)
    end
end

-- exports them all!
for name, func in pairs(cca) do
    export(name, func)
end

