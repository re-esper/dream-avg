local novel = {}

-- initialize
local function _isCharacter(obj)
    local c = obj.__cname
    return c == "Character" or c == "Live2DCharacter" or c == "SpineCharacter"
end
function novel.initialize()
    novel.reset()
    local variableTable = novel._currentVariableTable
    novel._metatableNovelG = {
        __newindex = function(t, k, v)
            if not variableTable[k] then
                local vt = type(v)
                if vt == "number" or vt == "string" or vt == "boolean" or vt == "table" then -- TODO: deep checking
                    variableTable[k] = true
                elseif _isCharacter(v) then
                    variableTable[k] = true
                end
            elseif v == nil then
                variableTable[k] = nil
            end
            rawset(t, k, v)
        end
    }
    novel._metatableG = getmetatable(_G) -- original _G's metatable
    novel._savePath = FileUtils:getWritablePath() .. const.SAVE_DATA_DIRECTORY .. "/"
    if not FileUtils:isDirectoryExist(novel._savePath) then
        FileUtils:createDirectory(novel._savePath)
    end
    audio:setMusicVolume(const.DEFAULT_BGM_VOLUME)
    audio:setEffectVolume(const.DEFAULT_SOUND_VOLUME)
end

function novel.reset()
    novel._currentVariableTable = {}
    novel._currentCoroutine = nil
    novel._isAutoPlayEnabled = false
    novel._isFastForwardEnabled = false
    novel._isTextSpawning = false
    novel._randomSeed = math.floor(math.random() * 0x80000000)
end

-- novel system interfaces
function novel.startStoryScript(storyScript, ...)
    if select(1, ...) then -- with transition argumenets
        novel._safeLoadScene("novel.sceneNovel", { script = storyScript }, ...)
    else -- defualt
        novel._safeLoadScene("novel.sceneNovel", { script = storyScript }, "fade", const.DEFAULT_SCENE_TRANSITION_TIME)
    end
end

function novel.loadGame(savedGameFile)
    novel._safeLoadScene("novel.sceneNovel", { loadGame = savedGameFile })
end

function novel.saveGame(filePath)
    local data = {}
    data["script"] = novel._currentScript
    data["context"] = novel._currentContext
    data["line"] = novel._currentLine
    data["userInputs"] = novel._userInputs
    data["fileTime"] = os.time()
    local code = loadstring("return " .. table.tostring(data, true))
    FileUtils:writeStringToFile(string.dump(code, true), filePath)
end

-- setup UI objects of novel system
function novel._setupUIs(backlayer, actorlayer, uilayer, background, textNode, nameNode, textBox, nameBox, clickGlyph, btnAutoPlay, btnFastForward)
    novel._backLayer = backlayer -- 背景层节点
    novel._actorLayer = actorlayer -- 立绘层节点
    novel._uiLayer = uilayer -- 界面层节点
    novel._background = background  -- 背景图
    novel._textNode = textNode
    novel._textObject = textBox -- 主文本框
    novel._nameNode = nameNode
    novel._nameObject = nameBox -- 角色名框
    novel._clickGlyph = clickGlyph -- 点击提示动画
    novel._btnAutoPlay = btnAutoPlay
    novel._btnFastforward = btnFastForward
    novel._isGameUIHidden = false
end

-- to make sure loading scene from main coroutine
function novel._safeLoadScene(scene, data, ...)
    local handle
    local args = {...}
    handle = Scheduler:scheduleScriptFunc(function()
        Scheduler:unscheduleScriptEntry(handle)
        -- try to kill the current novel coroutine
        if novel._currentCoroutine then
            if routine.kill(novel._currentCoroutine) then
                print("current coroutine killed")
            end
            novel._currentCoroutine = nil
            setmetatable(_G, novel._metatableG)
        end
        util.loadScene(scene, data, unpack(args))
    end, 0, false)
end

--[[
    story scripts execution:
    novel._currentVariableTable { k1 = true, k2 = true, ... }
    novel._currentContext       { variables = {}, charactors = {} }
    novel._currentScript
    novel._currentLine
    novel._userInputs
    novel._skipToLine
]]
local function _makeStoryScriptContext()
    local context = {}
    context["seed"] = novel._randomSeed
    local variables = {}
    local charactors = {}
    for k, _ in pairs(novel._currentVariableTable) do
        local v = rawget(_G, k)
        local vt = type(v)
        if vt == "number" or vt == "string" or vt == "boolean" or vt == "table" then -- TODO: deep checking
            variables[k] = clone(v)
        elseif _isCharacter(v) then
            v:_reset()
            charactors[k] = v:_serialize()
        end
    end
    context["variables"] = variables
    context["charactors"] = charactors
    novel._currentContext = context
end
local function _loadStoryScriptContext(context)
    novel._randomSeed = context["seed"]
    local variables = context["variables"]
    local variableTable = {}
    for k, v in pairs(variables) do
        variableTable[k] = true
        rawset(_G, k, clone(v))
    end
    local charactors = context["charactors"]
    for k, v in pairs(charactors) do
        variableTable[k] = true
        local c = Character(v["params"])
        c:_loadUserData(v["userdata"])
        rawset(_G, k, c)
    end
    novel._currentContext = context
    novel._currentVariableTable = variableTable
end

-- loading saved game
local function _preLoadGame()
    Scheduler:setTimeScale(10000.0)
    audio:setMusicVolume(0)
    audio:setEffectVolume(0)
    util.getLayer():setVisible(false)
end
local function _postLoadGame()
    Scheduler:setTimeScale(1.0)
    -- cocos2d-x的粒子系统实现不严谨(帧率不同emit会不一致), 这里只能手动修一下
    local children = util.getLayer():getChildren() -- 默认粒子通过:addTo()添加
    for _, child in ipairs(children) do
        if tolua.iskindof(child, "cc.ParticleSystem") then
            child:stop()
            child:start()
        end
    end
    audio:setMusicVolume(const.DEFAULT_BGM_VOLUME)
    audio:setEffectVolume(const.DEFAULT_SOUND_VOLUME)
    util.getLayer():setVisible(true)
end

function novel._executeStoryScript(params)
    -- prepare execution environment
    local code
    if params["script"] then -- normal
        code = util.loadCode(const.STORY_SCRIPT_DIRECTORY .. "/" .. params["script"])
        novel._currentScript = params["script"]
        _makeStoryScriptContext()
        novel._userInputs = {}
    elseif params["loadGame"] then -- loading
        local data = util.loadCode(novel._savePath .. params["loadGame"])()
        code = util.loadCode(const.STORY_SCRIPT_DIRECTORY .. "/" .. data["script"])
        novel._currentScript = data["script"]
        novel._skipToLine = data["line"]
        novel._userInputs = data["userInputs"]
        _loadStoryScriptContext(data["context"])
        _preLoadGame()
    end
    -- execute!!!
    setmetatable(_G, novel._metatableNovelG)
    novel._currentCoroutine = routine.execute(function()
        print("coroutine start @ " .. novel._currentScript)
        xpcall(code, __G__TRACKBACK__)
        novel._currentCoroutine = nil
        setmetatable(_G, novel._metatableG)
        print("coroutine finished")
    end)
end

-- helpers for script commands
function novel._preScriptCommand()
    local dbginfo = debug.getinfo(3) -- 1 - here, 2 - caller, 3 - storyScript
    local currentline = dbginfo.currentline
    novel._currentLine = currentline
    if novel._skipToLine then
        assert(currentline <= novel._skipToLine, "load game failed, story script '" .. dbginfo.source .. "' has changed?")
        if currentline < novel._skipToLine then
            return true
        end
        -- skipping is done!
        novel._skipToLine = nil
        _postLoadGame()
    end
    return false
end

function novel._preUserInput(kind)
    local dbginfo = debug.getinfo(3) -- 1 - here, 2 - caller, 3 - storyScript
    if novel._skipToLine then
        local result = novel._userInputs[kind .. dbginfo.currentline]
        assert(result, "load game failed, story script '" .. dbginfo.source .. "' has changed?")
        return result
    end
    -- stop fast forward mode
    if novel._isFastForwardEnabled then
        novel._enableFastForward(false)
    end
end

function novel._postUserInput(kind, result)
    local dbginfo = debug.getinfo(3) -- 1 - here, 2 - caller, 3 - storyScript
    novel._userInputs[kind .. dbginfo.currentline] = result
end

-- LCG random number
function novel._random()
    novel._randomSeed = bit.band(214013 * novel._randomSeed + 2531011, 0x7fffffff)
    return novel._randomSeed / 0x80000000
end

-- set name box
function novel._showName(name)
    if not name or name == "" then
        novel._nameNode:setVisible(false)
    else
        novel._nameNode:setVisible(true)
        novel._nameObject:setString(name)
    end
end

-- auto mode and skip mode
function novel._enableAutoPlay(enabled)
    if novel._isAutoPlayEnabled == enabled then return end
    if novel._btnAutoPlay and novel._btnAutoPlay.setEnabledState then
        novel._btnAutoPlay.setEnabledState(enabled)
    end
    novel._isAutoPlayEnabled = enabled
    if enabled then routine.signal("any_touch") end
end
function novel._enableFastForward(enabled)
    if novel._isFastForwardEnabled == enabled then return end
    if novel._btnFastforward and novel._btnFastforward.setEnabledState then
        novel._btnFastforward.setEnabledState(enabled)
    end
    Scheduler:setTimeScale(enabled and 2.0 or 1.0) -- speed up everything
    novel._isFastForwardEnabled = enabled
    if enabled then routine.signal("any_touch") end
end

export("novel", novel)