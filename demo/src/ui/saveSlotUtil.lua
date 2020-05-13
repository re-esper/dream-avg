local m = {}

function m.initSaveSlot(slot, id)    
    local saveFile = novel._savePath .. "save_" .. id .. ".sav"
    local imageFile = novel._savePath .. "save_" .. id .. ".jpg"
    slot._id = id
    if not slot.thumbnail then
        slot.thumbnail = cc.Sprite:create():anchor(0, 0):position(27, 117):addTo(slot)
        slot.icon1 = cc.Sprite:create("icon_chap1.png"):position(40, 82):scale(4 / 3):addTo(slot)
        slot.text1 = ccui.Text:create("", const.DEFAULT_FONT_NAME, 24):addTo(slot)
        slot.text1:anchor(0, 0.5):position(64, 84)
        slot.text1:setTextColor(cc.c4b(0x32, 0x7f, 0x7f, 0xff))        
        slot.icon2 = cc.Sprite:create("icon_time.png"):position(40, 32):scale(4 / 3):addTo(slot)
        slot.text2 = ccui.Text:create("", const.DEFAULT_FONT_NAME, 24):addTo(slot)
        slot.text2:anchor(0, 0.5):position(64, 32)
        slot.text2:setTextColor(cc.c4b(0xa9, 0x87, 0x65, 0xff))
    end
    if FileUtils:isFileExist(saveFile) and FileUtils:isFileExist(imageFile) then
        slot.thumbnail:frame(imageFile)            
        local rt = slot.thumbnail:getTextureRect()
        slot.thumbnail:scale(320 / rt.width, 180 / rt.height)        
        local data = util.loadCode(saveFile)()
        local str = data["script"]
        local neatName = str:match(".*/(.*).lua") or str:match("(.*).lua") or str
        slot.text1:setString("章节: " .. neatName)
        slot.text2:setString(os.date("%c", data["fileTime"]))
    else
        slot.thumbnail:hide()
        slot.icon1:hide()
        slot.icon2:hide()
        slot.text1:setString("")
        slot.text2:setString("")
    end
end

return m