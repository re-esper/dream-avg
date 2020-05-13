local UILayer = require "ui.baseUILayer"
local UILoadGame = class("UILoadGame", UILayer)
local saveSlotUtil = require "ui.saveSlotUtil"
function UILoadGame:ctor(backgroundImage)
    UILayer.ctor(self)
    self._background = cc.Sprite:create(backgroundImage):position(video.center):scale("full"):addTo(self)    
    local logo = cc.Sprite:create("load_logo.png"):anchor(0, 1):position(0, video.height - 15):addTo(self)
    local bg2 = ccui.Scale9Sprite:create("load_bg.png"):position(video.center.x, video.center.y - 48):opacity(0.8):addTo(self, 1)
    bg2:setContentSize(video.width - 24, video.height - 150)

    for y = 0, 1 do
        for x = 0, 3 do
            local slot = ccui.Button:create("slot_back.png", "slot_load_2.png"):addTo(self, 4)
            slot:position(video.center.x - 576 + x * 384, video.center.y + 174 - y * 360)
            slot:enableMouseHover()
            slot:setCascadeOpacityEnabled(true)
            saveSlotUtil.initSaveSlot(slot, y * 4 + x)
            slot:addClickEventListener(function(sender)
                audio:playEffect(const.UI_CONFIRM_SOUND)
                novel.loadGame("save_" .. sender._id .. ".sav")
            end)            
        end
    end

    local btnBack = ccui.Button:create("back1.png", "back2.png"):position(video.center.x, 120):scale(2 / 3):addTo(self, 3)
    btnBack:enableMouseHover(const.BUTTON_HOVER_SOUND)
    btnBack:addClickEventListener(function(sender)
        audio:playEffect(const.UI_CANCEL_SOUND)
        self:hide()
    end)

    self:setCascadeOpacityEnabled(true)
end

function UILoadGame:setBackgroundImage(backgroundImage)
    self._background:frame(backgroundImage)
end

return UILoadGame