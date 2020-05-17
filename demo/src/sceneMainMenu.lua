local flowerEffect = require "flowerFall"
function setup()
    local backgroundImage = "main.jpg"
    cc.Sprite:create(backgroundImage):position(video.center):scale("full"):opacity(0.9):addTo()

    local heroine = cc.Sprite:create("bgc2.png"):position(video.center.x - 400 - 50, 420 - 100):opacity(0):scale(1.125):addTo(2)

    local title = cc.Sprite:create("title2.png"):position(video.center.x + 360, video.center.y + 250):opacity(0):scale(1):addTo(10)

    local btnStart = ccui.Button:create():position(video.width - 760, 180):opacity(0):scale(0.75):addTo(10)
    btnStart:loadTextures("title_newgame_1.png", "title_newgame_2.png", "title_newgame_1.png")
    btnStart:enableMouseHover(const.BUTTON_HOVER_SOUND)
    btnStart:addClickEventListener(function(sender)
        audio:playEffect("sound/confirm2.ogg")
        novel.reset()
        novel.startStoryScript("chapter_1_1.lua")
    end)

    local btnLoad = ccui.Button:create():position(video.width - 480, 180):opacity(0):scale(0.75):addTo(10)
    btnLoad:loadTextures("title_load_1.png", "title_load_2.png", "title_load_1.png")
    btnLoad:enableMouseHover(const.BUTTON_HOVER_SOUND)
    local uiLoadGame
    btnLoad:addClickEventListener(function(sender)
        if not uiLoadGame then
            local UILoadGame = require "ui.loadGameUI"
            uiLoadGame = UILoadGame:create(backgroundImage):addTo(100)
        end
        audio:playEffect(const.UI_CONFIRM_SOUND)
        uiLoadGame:show()
    end)

    local btnOption = ccui.Button:create():position(video.width - 200, 180):opacity(0):scale(0.75):addTo(10)
    btnOption:loadTextures("title_config_1.png", "title_config_2.png", "title_config_1.png")
    btnOption:enableMouseHover(const.BUTTON_HOVER_SOUND)
    local uiConfig
    btnOption:addClickEventListener(function(sender)
        if not uiConfig then
            local UIConfigure = require "ui.configUI"
            uiConfig = UIConfigure:create(backgroundImage):addTo(100)
        end
        audio:playEffect(const.UI_CONFIRM_SOUND)
        uiConfig:show()
    end)

    flowerEffect.initFlowers()
    for i = 1, 60 * 20 do
        flowerEffect.updateFlowers()
    end

    audio:playMusic("bgm/title_theme.mp3", true, const.LOGO_TRANSITION_TIME * 2)

    -- perform when scene transition is done
    util.getScene():performDelay(function()
        heroine:runAction(spawn {
            moveTo { 1, video.center.x - 400, 420 },
            fadeIn { 0.75 },
        })
        title:runAction(fadeIn { 2.5 })
        btnStart:runAction(sequence {
            delay { 0.25 },
            fadeIn { 2 }
        })
        btnLoad:runAction(sequence {
            delay { 0.5 },
            fadeIn { 2 }
        })
        btnOption:runAction(sequence {
            delay { 0.75 },
            fadeIn { 2 }
        })
    end, const.LOGO_TRANSITION_TIME)
end

function tick(dt)
    flowerEffect.updateFlowers()
end

function leave()
    flowerEffect.stop()
end
