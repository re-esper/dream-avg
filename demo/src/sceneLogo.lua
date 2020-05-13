local function enterTitleScene()
    util.loadScene("sceneMainMenu", nil, "fade", const.LOGO_TRANSITION_TIME, cc.WHITE)
end

function setup()
    cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo()
    cc.Sprite:create("logo.png"):position(video.center.x, video.center.y):scale(2/3):addTo()
    util.getScene():performDelay(enterTitleScene, 1.0)
end

function onTouch(touch, event)
    if event == "began" then
        enterTitleScene()
    end
end

function leave()
end