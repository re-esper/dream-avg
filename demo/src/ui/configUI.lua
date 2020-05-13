local UILayer = require "ui.baseUILayer"
local UIConfigure = class("UIConfigure", UILayer)

function UIConfigure:ctor(backgroundImage)
    UILayer.ctor(self)

    self._background = cc.Sprite:create(backgroundImage):position(video.center):scale("full"):addTo(self)
    
    local logo = cc.Sprite:create("config_logo.png"):anchor(0, 1):position(0, video.height - 15):addTo(self)

    local bg2 = ccui.Scale9Sprite:create("load_bg.png"):position(video.center.x, video.center.y - 48):opacity(0.8):addTo(self, 1)
    bg2:setContentSize(video.width - 24, video.height - 150)

    local btnBack = ccui.Button:create("back1.png", "back2.png"):position(video.center.x, 120):scale(2 / 3):addTo(self, 3)
    btnBack:enableMouseHover(const.BUTTON_HOVER_SOUND)
    btnBack:addClickEventListener(function(sender)
        audio:playEffect(const.UI_CANCEL_SOUND)        
        self:hide()
    end)

    self:setCascadeOpacityEnabled(true)
end

function UIConfigure:setBackgroundImage(backgroundImage)
    self._background:frame(backgroundImage)
end

return UIConfigure