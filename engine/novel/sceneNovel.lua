local RichTextEx = require "framework.extends.richtextex"
function setup(data)
    -- initialize layers
    local backlayer = cc.Node:create():addTo(-1)
    local actorlayer = cc.Node:create():addTo(0)
    local uilayer = cc.Node:create():addTo(2)
    local background = cc.Sprite:create():position(video.center):addTo(backlayer)

    -- initialize textBox and nameBox
    local textBoxWidth = 1350
    local textBoxHeight = 228
    local nameBoxLeft = 240
    local textNode = cc.Node:create():position(0, 0):addTo(uilayer)
    local textFrame = ccui.Scale9Sprite:create("ingame/textboxframe.png"):opacity(1)
    textFrame:anchor(0.5, 0):position(video.center.x, 0):addTo(textNode)
    textFrame:setContentSize(video.width, textBoxHeight + 92)
    if textFrame:getContentSize().width < video.width then
        textFrame:setContentSize(video.width, textFrame:getContentSize().height)
    end
    textFrame:setColor(cc.c3b(255, 135, 162))
    local textBox = RichTextEx:create {
        font = const.DEFAULT_FONT_NAME,
        size = const.DEFAULT_FONT_SIZE,
        shadowOffset = { 1, -1 },
        style = ccui.RichText.FontStyle.shadow
    }
    textBox:anchor(0.5, 1):position(video.width / 2, textBoxHeight):addTo(textNode)
    textBox:setContentSize(textBoxWidth, textBoxHeight + 36)
    textBox:ignoreContentAdaptWithSize(false)
    local nameNode = cc.Node:create():position(nameBoxLeft, textBoxHeight):addTo(uilayer)
    --[[local nameFrame = ccui.Scale9Sprite:create("ingame/nameboxframe.png"):anchor(0.5, 0):position(0, 8):addTo(nameNode)
    nameFrame:setContentSize(180, 52)]]
    local nameBox = ccui.Text:create("", const.DEFAULT_FONT_NAME, 42):anchor(0.5, 0):position(0, -4):addTo(nameNode, 1)
    nameBox:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
    nameBox:setTextVerticalAlignment(1)

    -- initialize click glyph
    local tex = TextureCache:addImage(const.NOVEL_CLICK_GLYPH)
    local clickGlyphFrames
    if tex:getPixelsHigh() > tex:getPixelsWide() then
        clickGlyphFrames = tex:getPixelsHigh() / tex:getPixelsWide()
        util.loadSpriteFrame(const.NOVEL_CLICK_GLYPH, "clickglyph", 1, clickGlyphFrames)
    else
        clickGlyphFrames = tex:getPixelsWide() / tex:getPixelsHigh()
        util.loadSpriteFrame(const.NOVEL_CLICK_GLYPH, "clickglyph", clickGlyphFrames, 1)
    end
    AnimationCache:addAnimation(cc.Animation:build("clickglyph_%d", 1, clickGlyphFrames, const.NOVEL_CLICK_GLYPH_INTERVAL), "novelClickAni")
    local clickGlyph = cc.Sprite:create():anchor(0.5, 0):position(video.width / 2 + textBoxWidth / 2 + 16, 72):addTo(textNode)
    clickGlyph:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
    clickGlyph:hide()

    -- initialize bottom buttons
    local autoPlayStateImages = { [false] = "ingame/auto.png", [true] = "ingame/auto1.png" }
    local btnAutoPlay = ccui.Button:create(autoPlayStateImages[novel._isAutoPlayEnabled], "ingame/auto2.png")
        :anchor(0.5, 0):position(video.width - 740, 8):addTo(textNode)
    btnAutoPlay.setEnabledState = function(enabled)
        btnAutoPlay:loadTextureNormal(autoPlayStateImages[enabled])
    end
    btnAutoPlay:addClickEventListener(function(sender)
        novel._enableAutoPlay(not novel._isAutoPlayEnabled)
    end)
    btnAutoPlay:enableMouseHover()
    local fastForwardStateImages = { [false] = "ingame/fastforward.png", [true] = "ingame/fastforward1.png" }
    local btnFastForward = ccui.Button:create(fastForwardStateImages[novel._isFastForwardEnabled], "ingame/fastforward2.png")
        :anchor(0.5, 0):position(video.width - 640, 8):addTo(textNode)
    btnFastForward.setEnabledState = function(enabled)
        btnFastForward:loadTextureNormal(fastForwardStateImages[enabled])
    end
    btnFastForward:addClickEventListener(function(sender)
        novel._enableFastForward(not novel._isFastForwardEnabled)
    end)
    btnFastForward:enableMouseHover()
    local btnSave = ccui.Button:create("ingame/save.png", "ingame/save2.png"):anchor(0.5, 0):position(video.width - 505, 12):addTo(textNode)
    local uiSaveGame
    btnSave:addClickEventListener(function(sender)
        if uiSaveGame then
            uiSaveGame:removeFromParent()
        end
        local UISaveGame = require "ui.saveGameUI"
        uiSaveGame = UISaveGame:create(novel._backgroundFile):addTo(100)
        uiSaveGame:show()
    end)
    btnSave:enableMouseHover()
    local btnLoad = ccui.Button:create("ingame/load.png", "ingame/load2.png"):anchor(0.5, 0):position(video.width - 370, 12):addTo(textNode)
    local uiLoadGame
    btnLoad:addClickEventListener(function(sender)
        if uiLoadGame then
            uiLoadGame:removeFromParent()
        end
        local UILoadGame = require "ui.loadGameUI"
        uiLoadGame = UILoadGame:create(novel._backgroundFile):addTo(100)
        uiLoadGame:show()
    end)
    btnLoad:enableMouseHover()
    local btnSystem = ccui.Button:create("ingame/system.png", "ingame/system2.png"):anchor(0.5, 0):position(video.width - 210, 12):addTo(textNode)
    local uiConfig
    btnSystem:addClickEventListener(function(sender)
        if not uiConfig then
            local UIConfigure = require "ui.configUI"
            uiConfig = UIConfigure:create(novel._backgroundFile):addTo(100)
        else
            uiConfig:setBackgroundImage(novel._backgroundFile)
        end
        uiConfig:show()
    end)
    btnSystem:enableMouseHover()
    local btnHideUI = ccui.Button:create("ingame/close.png", "ingame/close2.png"):anchor(0.5, 0):position(video.width - 80, 8):addTo(textNode)
    btnHideUI:addClickEventListener(function(sender)
        if not novel._isGameUIHidden then
            novel._isGameUIHidden = true
            uilayer:setVisible(false)
        end
    end)
    btnHideUI:enableMouseHover()

    -- start
    audio:reset()
    novel._setupUIs(backlayer, actorlayer, uilayer, background, textNode, nameNode, textBox, nameBox, clickGlyph, btnAutoPlay, btnFastForward)
    novel._executeStoryScript(data)
end

function onTouch(touch, event)
    if event == "began" then
        if novel._isGameUIHidden then
            novel._uiLayer:setVisible(true)
            novel._isGameUIHidden = false
        elseif novel._isAutoPlayEnabled then
            novel._enableAutoPlay(false)
        elseif novel._isFastForwardEnabled then
            novel._enableFastForward(false)
        elseif novel._isTextSpawning then
            novel._textObject:setSpawnSpeed(const.NOVEL_TEXT_SPEED_FAST)
        else
            routine.signal("any_touch")
        end
    end
end

function leave()
end