local Choice = function(params)
    local choice = novel._preUserInput("Choice")
    if choice then return choice end

    local n = #params
    local btns = {}
    for i, str in ipairs(params) do
        local btn = ccui.Button:create("ingame/choice_normal.png", "ingame/choice_on.png"):addTo()
        btn:setTitleFontName(const.DEFAULT_FONT_NAME)
        btn:setTitleFontSize(42)
        btn:setTitleText(str)
        btn:getTitleRenderer():enableShadow(cc.c4b(0,0,0,255), cc.size(1, -1))
        btn:position(video.center.x, video.center.y - (i - 1 - n / 2) * 144)
        btn._choiceIndex = i
        btn:addClickEventListener(function(sender)
            choice = sender._choiceIndex
            audio:playEffect(const.UI_CONFIRM_SOUND)
        end)
        btn:enableMouseHover(const.BUTTON_HOVER_SOUND)
        table.insert(btns, btn)
    end
    novel._uiLayer:hide()
    routine.wait(function() return choice ~= nil end)
    for _, btn in ipairs(btns) do
        btn:removeFromParent()
    end
    novel._uiLayer:show()

    novel._postUserInput("Choice", choice)
    return choice
end

export("Choice", Choice)