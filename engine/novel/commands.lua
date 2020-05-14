local novelFunc = {}

function novelFunc.background(imageFile, duration)
    local withTransition = duration and type(duration) == "number" and duration > 0
    if withTransition and novel._backgroundFile then
        novel._background:fadeOut(duration, true)
    else
        novel._background:removeFromParent()
    end
    novel._background = cc.Sprite:create(imageFile):position(video.center):scale("full"):addTo(novel._backLayer)
    novel._backgroundFile = imageFile
    -- hide all characters if switching background
    local children = novel._actorLayer:getChildren()
    for _, child in ipairs(children) do
        child:setVisible(false)
    end
    if withTransition then
        novel._background:fadeIn(duration)
        novel._uiLayer:hide()
        routine.wait(duration)
        novel._uiLayer:show()
    end
end
function novelFunc.bgm(musicFile, fade)
    if musicFile == "" then
        audio:stopMusic(fade or const.DEFUALT_BGM_FADEIN)
    else
        audio:playMusic(musicFile, true, fade or const.DEFUALT_BGM_FADEIN)
    end
end
function novelFunc.sound(soundFile, channel, fade, isLoop)
    if soundFile == "" then
        audio:stopEffect(channel, fade)
    else
        audio:playEffect(soundFile, channel or 0, isLoop, fade)
    end
end
function novelFunc.wait(cond)
    routine.wait(cond)
end

function novelFunc.storyJumpTo(script, ...)
    if not FileUtils:isFileExist(script) then
        script = script .. '.lua'
    end
    novel.startStoryScript(script, ...)
end
function novelFunc.loadScene(sceneFile, ...)
    novel._safeLoadScene(sceneFile, ...)
end

function novelFunc.random(lower, upper)
    local r = novel._random()
    if lower and upper then -- [lower, upper]
        local l = math.floor(lower)
        local u = math.floor(upper)
        return math.floor(r * (u - l + 1)) + l
    elseif lower then -- [1, lower]
        local u = math.floor(lower)
        return math.floor(r * u) + 1
    end
    return r
end

-- exports them all!
for name, func in pairs(novelFunc) do
    export(name, func)
end