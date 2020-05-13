local function _handleTemplateLiterals(str)
    local prev, idx = 1, 1
    local r = ""
    while true do
        local sidx, eidx, expression = string.find(str, "${(.-)}", idx)
        if not sidx then
            r = r .. string.sub(str, prev)
            break
        end
        r = r .. string.sub(str, prev, sidx - 1)
        idx = eidx
        prev = eidx + 1
        local f = loadstring("return " .. expression)
        if f then r = r .. tostring(f()) end
        idx = idx + 1
    end
    return r
end
local function Charactor_call(self, text)
    local skip = novel._preScriptCommand()
    if skip then return self end
    if FileUtils:isFileExist(text) then -- play voice
        audio:playEffect(text, const.DEFAULT_VOICE_CHANNEL)
        return self
    end
    novel._showName(self.name)
    novel._textObject:setText(_handleTemplateLiterals(text))
    novel._textObject:setSpawnSpeed(novel._isFastForwardEnabled and const.NOVEL_TEXT_SPEED_FAST or const.NOVEL_TEXT_SPEED)
    novel._isTextSpawning = true
    novel._textObject:startSpawn(function()
        novel._isTextSpawning = false
        routine.signal("chat_text_done")
    end)
    routine.wait("chat_text_done")
    novel._clickGlyph:show()
    novel._clickGlyph:playAnimationForever("novelClickAni")
    if novel._isAutoPlayEnabled then
        routine.wait(const.NOVEL_AUTOPLAY_DELAY)
    elseif novel._isFastForwardEnabled then
        routine.wait(0.01)
    else -- normal
        routine.wait("any_touch")
    end
    novel._clickGlyph:stopAllActions()
    novel._clickGlyph:hide()
    novel._showName("")
    novel._textObject:clear()
    audio:stopEffect(const.DEFAULT_VOICE_CHANNEL, const.DEFAULT_VOICE_FADEOUT) -- stop the voice of playing
end
local function Charactor_newindex(self, peer, key, val)
    if key == "image" then
        val = val ~= "" and val or self._defaultImage
        self:_loadContent(val)
    elseif self._parts[key] then
        local subspr = self._parts[key]
        val = val ~= "" and val or subspr._defaultImage
        subspr:frame(val)
    else
        self._userDataTable[key] = true
        rawset(peer, key, val)
    end
end
local function Charactor_initialize(self, params)
    self._parts = {}
    self._params = params -- readonly
    local mt = getmetatable(self)
    mt.__call = Charactor_call
    local peer_mt = getmetatable(tolua.getpeer(self))
    peer_mt.__newindex = function(t, key, val) return Charactor_newindex(self, t, key, val) end
    for k, v in pairs(params) do
        if k == "image" then
            -- handle this in constructor
        elseif k == "name" then
            self.name = v
        elseif k == "x" then
            self:setPositionX(v)
        elseif k == "y" then
            self:setPositionY(v)
        elseif k == "scale" then
            self:setScale(v)
        elseif k == "parts" then
            for name, t in pairs(v) do
                local subspr = cc.Sprite:create():addTo(self)
                self._parts[name] = subspr
                for prop, propv in pairs(t) do
                    if prop == "file" then
                        subspr._defaultImage = propv
                        subspr:frame(propv)
                    elseif prop == "x" then
                        subspr:setPositionX(propv)
                    elseif prop == "y" then
                        subspr:setPositionY(propv)
                    elseif prop == "scale" then
                        subspr:setScale(propv)
                    elseif prop == "anchor" then
                        subspr:setAnchorPoint(unpack(propv))
                    end
                end
            end
        else
            self[k] = v
        end
    end
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)
end
local function Charactor_loadUserData(self, userData)
    local peer = tolua.getpeer(self)
    for k, v in pairs(userData) do
        self._userDataTable[k] = true
        rawset(peer, k, clone(v))
    end
end
local function Charactor_serialize(self)
    local peer = tolua.getpeer(self)
    local userData = {}
    for k, _ in pairs(self._userDataTable) do
        userData[k] = clone(rawget(peer, k))
    end
    return {
        params = self._params,
        userdata = userData
    }
end
local function Charactor_reset(self) -- reset for new scene
    local params = self._params
    self:setPositionX(params["x"] or video.center.x)
    self:setPositionY(params["y"] or 0)
    self:setScale(params["scale"] or 1)
    if self._defaultImage then
        self:_loadContent(self._defaultImage)
    end
end
local function Charactor_show(self, imageFile)
    if imageFile then
        self.image = imageFile
    end
    if not self:getParent() then
        self:addTo(novel._actorLayer)
    end
    self:setVisible(true)
end

-- normal Charactor inherit from cc.Sprite
local Charactor = class("Charactor", cc.Sprite)
function Charactor:ctor(params)
    self._userDataTable = {}
    self._defaultImage = params["image"]
    Charactor_initialize(self, params)
    self.image = self._defaultImage
end
function Charactor:_loadContent(imageFile)
    if imageFile and imageFile ~= "" then
        self:frame(imageFile)
    end
end
-- live2d Charactor inherit from cc.Live2DSprite
local Live2DCharactor = class("Live2DCharactor", function(modelFile)
    return cc.Live2DSprite:create(modelFile)
end)
function Live2DCharactor:ctor(modelFile, params)
    self._userDataTable = {}
    Charactor_initialize(self, params)
end
function Live2DCharactor:_loadContent(imageFile)
    -- do nothing, can't change model on fly
end
-- spine Charactor inherit from sp.SkeletonAnimation
local SpineCharactor = class("SpineCharactor", function(modelFile)
    local ext = FileUtils:getFileExtension(imageFile)
    if ext == ".json" then
        local atlasFile = string.gsub(modelFile, ".json", ".atlas")
        return sp.SkeletonAnimation:createWithJsonFile(modelFile, atlasFile)
    else
        local atlasFile = string.gsub(modelFile, ".skel", ".atlas")
        return sp.SkeletonAnimation:createWithBinaryFile(modelFile, atlasFile)
    end
end)
function SpineCharactor:ctor(modelFile, params)
    self._userDataTable = {}
    Charactor_initialize(self, params)
end
function SpineCharactor:_loadContent(imageFile)
end
-- creator
local function buildCharactor(params)
    local imageFile = params["image"]
    local charactor, imageFileExt
    if imageFile then
        assert(FileUtils:isFileExist(imageFile), "Charactor construct failed: 'image' is invalid")
        imageFileExt = FileUtils:getFileExtension(imageFile)
    end
    if imageFileExt == ".json" then
        if string.find(imageFile, ".model3.json") then
            charactor = Live2DCharactor:create(imageFile, params)
        else
            charactor = SpineCharactor:create(imageFile, params)
        end
    elseif imageFileExt == ".skel" then
        charactor = SpineCharactor:create(imageFile, params)
    else
        charactor = Charactor:create(params)
    end
    charactor.show = Charactor_show
    charactor._loadUserData = Charactor_loadUserData
    charactor._serialize = Charactor_serialize
    charactor._reset = Charactor_reset
    charactor:retain()
    return charactor
end

-- default narrator
local narrator = Charactor:create({ name = "" })
export("_", narrator)
-- 'Charactor' interface
export("Charactor", buildCharactor)