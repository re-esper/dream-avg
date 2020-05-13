-----------------------------------------------------------------------------------------
-- scene transitions
-----------------------------------------------------------------------------------------
local _scene_transitions = {
    crossfade       = cc.TransitionCrossFade,
    fade            = {cc.TransitionFade, cc.BLACK},
    fadebl          = cc.TransitionFadeBL,
    fadedown        = cc.TransitionFadeDown,
    fadetr          = cc.TransitionFadeTR,
    fadeup          = cc.TransitionFadeUp,
    flipangular     = {cc.TransitionFlipAngular, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    flipx           = {cc.TransitionFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    flipy           = {cc.TransitionFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
    jumpzoom        = cc.TransitionJumpZoom,
    moveinb         = cc.TransitionMoveInB,
    moveinl         = cc.TransitionMoveInL,
    moveinr         = cc.TransitionMoveInR,
    moveint         = cc.TransitionMoveInT,
    progressccw     = cc.TransitionProgressRadialCCW,
    progresscw      = cc.TransitionProgressRadialCW,
    progressh       = cc.TransitionProgressHorizontal,
    progressv       = cc.TransitionProgressVertical,
    progressinout   = cc.TransitionProgressInOut,
    progressoutin   = cc.TransitionProgressOutIn,    
    pageturn        = {cc.TransitionPageTurn, false},
    rotozoom        = cc.TransitionRotoZoom,
    shrinkgrow      = cc.TransitionShrinkGrow,
    slideinb        = cc.TransitionSlideInB,
    slideinl        = cc.TransitionSlideInL,
    slideinr        = cc.TransitionSlideInR,
    slideint        = cc.TransitionSlideInT,
    splitcols       = cc.TransitionSplitCols,
    splitrows       = cc.TransitionSplitRows,
    turnofftiles    = cc.TransitionTurnOffTiles,
    zoomflipangular = cc.TransitionZoomFlipAngular,
    zoomflipx       = {cc.TransitionZoomFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    zoomflipy       = {cc.TransitionZoomFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
}
local function _transitionScene(scene, transition, time, more)
    if Director:getRunningScene() then
        if transition then
            local key = string.lower(tostring(transition))
            if _scene_transitions[key] then
                local t = _scene_transitions[key]
                time = time or 0.5
                more = more or t[2]
                if not t[".isclass"] then
                    scene = t[1]:create(time, scene, more)
                else
                    scene = t:create(time, scene)
                end
            end
        end
        Director:replaceScene(scene)        
    else
        Director:runWithScene(scene)
    end
end

-----------------------------------------------------------------------------------------
-- scene framework
-----------------------------------------------------------------------------------------
local _scene_framework_apis = {
    "setup", "leave", "cleanup", "tick",
    "onTouch",
}
for _, v in ipairs(_scene_framework_apis) do
    rawset(_G, v, 0)
end

-- current scene and root layer
local _scene = nil
local _layer = nil
local _touchListener = nil
local _customListeners = nil
function util.loadScene(script, data, transition, time, more)
    -- stop prev scene
    if _scene then
        if tick ~= 0 then
            _layer:unscheduleUpdate()
        end
        if onTouch ~= 0 and _touchListener then
            _layer:getEventDispatcher():removeEventListener(_touchListener)
        end
        for _, listener in ipairs(_customListeners or {}) do
            Director:removeEventListener(listener)
        end
        if leave ~= 0 then 
            leave()
        end
        _scene:stopAllActions()
    end

    -- load the scene script
    for _, v in ipairs(_scene_framework_apis) do
        rawset(_G, v, 0)
    end

    require(script)
    unrequire(script)

    assert(type(setup) == "function", string.format("Error in loading %s, 'setup' function is missing.", script))
   
    -- initialize
    _scene = cc.Scene:create()
    _layer = cc.Layer:create()
    _scene:addChild(_layer)
    _customListeners = {}  
    
    local _cleanup = cleanup
    _scene:registerScriptHandler(function(event)
        if event == "enter" then
            setup(data)
        elseif event == "cleanup" and _cleanup ~= 0 then
            _cleanup()
        end
    end)

    -- touchable supported
    if onTouch ~= 0 then
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(function(touch, event)
            return onTouch(touch, "began")
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)
            return onTouch(touch, "move")
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)
            return onTouch(touch, "end")
        end, cc.Handler.EVENT_TOUCH_ENDED)
        _layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, _layer)
        _touchListener = listener
    end

    -- updater supported
    if tick ~= 0 then
        _layer:scheduleUpdateWithPriorityLua(tick, 1)
    end

    -- transition the cocos2d-x scene
    _transitionScene(_scene, transition, time, more)
end

function util.getScene()
    return _scene
end

function util.getLayer()
    return _layer
end

function util.listenEvent(eventname, handler, global)
    local listener = cc.EventListenerCustom:create(eventname, function(event)
        handler(event.userdata)
    end)
    Director:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    if not global and _customListeners then
        table.insert(_customListeners, listener)
    end
end

function util.pushEvent(eventname, data)
    local event = cc.EventCustom:new(eventname)  
    event.userdata = data
    Director:getEventDispatcher():dispatchEvent(event)      
end

-- shortcut "addTo"
function cc.Node:addTo(target, zorder, tag)
    if type(target) == "userdata" then
        target:addChild(self, zorder or self:getLocalZOrder(), tag or self:getTag())
    else
        _layer:addChild(self, target or self:getLocalZOrder(), zorder or self:getTag())
    end    
    return self
end
