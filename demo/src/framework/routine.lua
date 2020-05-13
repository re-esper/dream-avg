local coroutine = coroutine
function coroutine.xpresume(co, err)
    local succeed, result = coroutine.resume(co)
    if not succeed and err then
        err(co)
    end
    return succeed
end

local routine = {}
export("routine", routine)

local _waitingCoroutines = {}
local _signals = {}
local _scheduler = nil

local __CO__TRACKBACK__ = function(co)
    release_print(debug.traceback(co, ""))
end

local table = table
local function _update(dt)
    local waking = {}
    for co, t in pairs(_waitingCoroutines) do
        if t.time and t.time > 0 then                  
            t.time = t.time - dt
            if t.time <= 0 then                
                table.insert(waking, co)    
            end
        elseif t.cond then
            if t.cond() then
                table.insert(waking, co)
            end
        end
    end
    for _, co in ipairs(waking) do
        _waitingCoroutines[co] = nil
        coroutine.xpresume(co, __CO__TRACKBACK__)
    end
end

function routine.execute(func)
    if not _scheduler then        
        _scheduler = Scheduler:scheduleScriptFunc(_update, 0, false)
    end
    local co = coroutine.create(func)
    return co, coroutine.xpresume(co, __CO__TRACKBACK__)        
end

function routine.clear()
    if _scheduler then
        Scheduler:unscheduleScriptEntry(_scheduler)
        _scheduler = nil
    end
    -- release all the coroutines' reference, so the garbage collector will destruct them
    _waitingCoroutines = {} 
    _signals = {}
end

function routine.wait(cond)
    local co = coroutine.running()
    assert(co, "routine.wait can only be called in a coroutine.")

    if type(cond) == "number" then
        _waitingCoroutines[co] = { time = cond }
    elseif type(cond) == "function" then
        _waitingCoroutines[co] = { cond = cond }
    elseif type(cond) == "string" then
        if _signals[cond] == nil then
            _signals[cond] = { co }
        else
            table.insert(_signals[cond], co)
        end               
    end    
    return coroutine.yield()
end

function routine.signal(signal)
    local waitingSignalTasks = _signals[signal]
    if waitingSignalTasks then
        _signals[signal] = nil
        for _, co in ipairs(waitingSignalTasks) do
            coroutine.xpresume(co, __CO__TRACKBACK__)
        end
    end
end

function routine.kill(co)
    if _waitingCoroutines[co] then
        -- yield from delay or condition
        _waitingCoroutines[co] = nil
        return true
    else
        -- yield from a signal
        for _, waitingSignalTasks in pairs(_signals) do
            for index, t in ipairs(waitingSignalTasks) do
                if co == t then
                    table.remove(waitingSignalTasks, index)
                    return true
                end
            end
        end
    end
    return false
end