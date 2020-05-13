local NameInput = function(params)
    local results = novel._preUserInput("NameInputBox")
    if results then return results end

    local framespr = ccui.Scale9Sprite:create("dialog_frame.png"):position(video.center):addTo()
    framespr:setContentSize(1080, 480)
    local bgsize = framespr:getContentSize()
    local textColor = cc.c3b(0x2c, 0x8e, 0x81)
    local label = cc.Label:build { text = "请输入主人公姓名", font = const.DEFAULT_FONT_NAME, size = 46, color = textColor }
        :anchor(0, 0.5):position(80, 380):addTo(framespr)
    label:enableBold()
    local line = cc.DrawNode:create():anchor(0, 1):position(80, 380 - 46 / 2 - 12):addTo(framespr)
    line:drawSolidRect(cc.p(0, 0), cc.p(label:getContentSize().width, 6), cc.c4f(textColor.r / 0xff, textColor.g / 0xff, textColor.b / 0xff, 1))

    local label1 = cc.Label:build { text = "姓氏：", font = const.DEFAULT_FONT_NAME, size = 42, color = textColor }
        :anchor(0, 0.5):position(80, 260):addTo(framespr)
    label1:enableBold()
    local editbox1= ccui.EditBox:create(cc.size(280, 60), "editbox.png"):anchor(0, 0.5):position(200, 260):addTo(framespr)
    editbox1:setFontSize(42)
    editbox1:setMaxLength(4)
    editbox1:setText(params['firstName'])

    local label2 = cc.Label:build { text = "名字：", font = const.DEFAULT_FONT_NAME, size = 42, color = textColor }
        :anchor(0, 0.5):position(80 + 450, 260):addTo(framespr)
    label2:enableBold()
    local editbox2 = ccui.EditBox:create(cc.size(280, 60), "editbox.png"):anchor(0, 0.5):position(200 + 450, 260):addTo(framespr)
    editbox2:setFontSize(42)
    editbox2:setMaxLength(4)
    editbox2:setText(params['lastName'])

    local btn = ccui.Button:create("dialog_btn_1.png", "dialog_btn_2.png"):position(bgsize.width / 2, 120):scale(2 / 3):addTo(framespr)
    btn:setTitleFontName(const.DEFAULT_FONT_NAME)
    btn:setTitleFontSize(40)
    btn:setTitleColor(cc.c3b(0x44, 0x22, 0))
    btn:getTitleRenderer():enableBold()
    btn:setTitleText("确定")
    btn:addClickEventListener(function(sender)
        audio:playEffect("sound/confirm3.ogg")
        routine.signal("input_box_confirm")
    end)
    btn:enableMouseHover(const.BUTTON_HOVER_SOUND)

    novel._uiLayer:hide()
    routine.wait("input_box_confirm")
    results = { firstName = editbox1:getText(), lastName = editbox2:getText() }
    framespr:removeFromParent()
    novel._uiLayer:show()

    novel._postUserInput("NameInputBox", results)
    return results
end

export("NameInput", NameInput)