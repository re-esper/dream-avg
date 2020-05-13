-----------------------------------------------------------------------------------------
-- cocos2d-x single instances
-----------------------------------------------------------------------------------------
export("Director",          cc.Director:getInstance())
export("TextureCache",      cc.Director:getInstance():getTextureCache())
export("FrameCache",        cc.SpriteFrameCache:getInstance())
export("AnimationCache",    cc.AnimationCache:getInstance())
export("Scheduler",         cc.Director:getInstance():getScheduler())
export("FileUtils",         cc.FileUtils:getInstance())
export("Application",       cc.Application:getInstance())
export("UserDefault",       cc.UserDefault:getInstance())

-----------------------------------------------------------------------------------------
-- cocos2d-x utils
-----------------------------------------------------------------------------------------
function util.loadSpriteFrame(filename, imageName, col, row)
    local tex = TextureCache:addImage(filename)
    col, row = col or 1, row or 1
    local w, h = tex:getPixelsWide() / col, tex:getPixelsHigh() / row
    for y = 0, row - 1 do
        for x = 0, col - 1 do
            local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(x * w, y * h, w, h))
            if col == 1 and row == 1 then
                FrameCache:addSpriteFrame(frame, imageName or filename)
            else
                FrameCache:addSpriteFrame(frame, (imageName or filename) .. "_" .. (y * col + x + 1))
            end
        end            
    end
end

function util.removeSpriteFrame(imageName)
    FrameCache:removeSpriteFrameByName(imageName)
    TextureCache:removeTextureForKey(imageName)
end

--[[
    build a cc.Layer or cc.LayerColor or cc.LayerGradient instance
    @param params table of paramters. the valid paramters are:
        "color"     the color or the start color of the gradient
        "color2"    the end color of the gradient
        "colordir"  the direction of gradient color
]]
function cc.Layer:build(params)
    local layer
    local color1 = params["color"] and cc.convertColor(params["color"], "4b")
    local color2 = params["color2"] and cc.convertColor(params["color2"], "4b")
    if not color1 and not color2 then
        -- creates a fullscreen black layer
        layer = cc.Layer:create()
    elseif not color2 then
        -- creates a Layer with color
        layer = cc.LayerColor:create(color1)
    else
        -- creates a full-screen Layer with a gradient between start and end
        layer = cc.LayerGradient:create(color1, color2, params["colordir"])
    end
    return layer
end

--[[
    build a cc.Sprite instance
    @param params table of paramters. the valid paramters are:
        "src"       the file name or frame name of the image, or a cc.Texture2D/cc.SpriteFrame instance
        "rect"      the subrect of the image
]]
function cc.Sprite:build(params)
    local sprite
    local src = params["src"]
    local rect = params["rect"]    
    local t = type(src)
    if t == "userdata" then t = tolua.type(src) end
    if not src then
        sprite = cc.Sprite:create()
    elseif t == "string" then
        local frame = FrameCache:getSpriteFrame(src)
        if frame then
            sprite = cc.Sprite:createWithSpriteFrame(frame)
        else            
            sprite = rect and cc.Sprite:create(src, rect) or cc.Sprite:create(src)
        end
    elseif t == "cc.Texture2D" then
        sprite = rect and cc.Sprite:createWithTexture(src, rect) or cc.Sprite:createWithTexture(src)
    elseif t == "cc.SpriteFrame" then
        sprite = cc.Sprite:createWithSpriteFrame(src)
    end
    assert(sprite, string.format("cc.Sprite:build() - create sprite failure, src = %s", tostring(src)))
    if params["tiled"] then
        sprite:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
        sprite:align(cc.p(0, 0), 0, 0)
    end
    return sprite
end

--[[
    build a ccui.Scale9Sprite instance
    @param params table of paramters. the valid paramters are:
        "src"       the file name or frame name of the image, or a cc.SpriteFrame instance
        "rect"      the subrect of the image
        "insets"    specified cap insets
]]
function ccui.Scale9Sprite:build(params)
    local sprite
    local src = params["src"]
    local rect = params["rect"]   
    local capinsets = params["insets"]
    local t = type(src)
    if t == "userdata" then t = tolua.type(src) end
    if not src then
        sprite = ccui.Scale9Sprite:create()
    elseif t == "string" then
        local frame = FrameCache:getSpriteFrame(src)
        if frame then
            sprite = capinsets and ccui.Scale9Sprite:createWithSpriteFrame(frame, capinsets) or ccui.Scale9Sprite:createWithSpriteFrame(frame)
        elseif rect then            
            sprite = capinsets and ccui.Scale9Sprite:create(src, rect, capinsets) or ccui.Scale9Sprite:create(src, rect)
        else                        
            sprite = capinsets and ccui.Scale9Sprite:create(capinsets, src) or ccui.Scale9Sprite:create(src)    
        end
    elseif t == "cc.SpriteFrame" then
        sprite = capinsets and ccui.Scale9Sprite:createWithSpriteFrame(src, capinsets) or ccui.Scale9Sprite:createWithSpriteFrame(src)   
    end
    assert(sprite, string.format("ccui.Scale9Sprite:build() - create sprite failure, src = %s", tostring(src)))
    return sprite    
end


--[[
    build a cc.Label instance
    @param params table of paramters. the valid paramters are:
        "text"      the initial text
        "font"      a font file or a font family name
        "size"      the font size
        "color"     the text color
        "align"     the text horizontal alignment
        "valign"    the text vertical alignment
        "dimensions"
]]
function cc.Label:build(params)
    local label
    local text = tostring(params["text"])
    local font = params["font"] or "Arial"
    local size = params["size"] or 32
    local halign = params["align"] or cc.TEXT_ALIGNMENT_LEFT
    local valign = params["valign"] or cc.VERTICAL_TEXT_ALIGNMENT_TOP
    if FileUtils:isFileExist(font) then
        label = cc.Label:createWithTTF(text, font, size, params["dimensions"] or cc.size(0, 0), halign, valign)
    else
        label = cc.Label:createWithSystemFont(text, font, size, params["dimensions"] or cc.size(0, 0), halign, valign)
    end
    if params["color"] then label:setTextColor(cc.convertColor(params["color"], "4b")) end    
    return label
end

function cc.Animation:build(pattern, begin, length, time, rollBack)
    local frames = {}
    local last = begin + length - 1
    for index = begin, last do
        local frameName = string.format(pattern, index)
        table.insert(frames, FrameCache:getSpriteFrame(frameName))
    end
    if rollBack then
        for index = last - 1, begin + 1, -1 do
            local frameName = string.format(pattern, index)
            table.insert(frames, FrameCache:getSpriteFrame(frameName))
        end
    end        
    return cc.Animation:createWithSpriteFrames(frames, time)    
end

local function enumerateChildren_(node, callback)
    callback(node)
    local children = node:getChildren()
    for _, child in ipairs(children) do
        enumerateChildren_(child, callback)
    end      
end
local function enumerateChildrenByType_(node, clstype, callback)
    if tolua.type(node) == clstype then callback(node) end
    local children = node:getChildren()
    for _, child in ipairs(children) do
        enumerateChildrenByType_(child, clstype, callback)
    end      
end
function util.enumerateChildren(root, clstype, callback)
    if type(clstype) == "function" then
        enumerateChildren_(root, clstype)
    elseif not clstype then
        enumerateChildren_(root, callback)
    else
        enumerateChildrenByType_(root, clstype, callback)
    end            
end

local function enumerateChildrenCond_(node, cond, callback)
    if cond(node) then
        callback(node)
        local children = node:getChildren()
        for _, child in ipairs(children) do
            enumerateChildrenCond_(child, cond, callback)
        end
    end
end
function util.enumerateChildrenWithCondition(root, cond, callback)
    enumerateChildrenCond_(root, cond, callback)
end

function util.cloneNodeWithChild(node)
    local nnode = node:clone()
    local children = node:getChildren()
    for _, child in ipairs(children) do
        local z = child:getLocalZOrder()
        local nchild = util.cloneNodeWithChild(child)        
        nnode:addChild(nchild, z)
    end
    return nnode
end

function util.replaceNode(node, replaced_node)
    local parent = replaced_node:getParent()
    local x, y = replaced_node:getPosition()
    local z = replaced_node:getLocalZOrder()
    local children = replaced_node:getChildren()
    for _, child in ipairs(children) do
        local zz = child:getLocalZOrder()
        child:removeFromParent()
        node:addChild(child, zz)
    end
    parent:addChild(node, z)
    node:setPosition(x, y)
    replaced_node:removeFromParent()
end

function util.loadCode(fileName)
    local data = FileUtils:getDataFromFile(fileName)
    if data then return loadstring(data) end
end