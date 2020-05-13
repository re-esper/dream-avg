-----------------------------------------------------------------------------------------
-- cc.Node extends
-----------------------------------------------------------------------------------------

function cc.Node:schedule(callback, interval)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(interval or 0), cc.CallFunc:create(callback)))
    self:runAction(action)
    return action
end

function cc.Node:performDelay(callback, delay)
    local sequence = cc.Sequence:create(cc.DelayTime:create(delay or 0), cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end

function cc.Node:fadeIn(duration, opacity)
    self:setVisible(true)
    self:setOpacity(0)
    if opacity then
        self:runAction(cc.FadeTo:create(duration, opacity))
    else
        self:runAction(cc.FadeIn:create(duration))
    end
end

function cc.Node:fadeOut(duration, destruct)
    self:setVisible(true)
    if destruct then
        self:runAction(cc.Sequence:create(cc.FadeOut:create(duration), cc.RemoveSelf:create()))
    else
        self:runAction(cc.Sequence:create(cc.FadeOut:create(duration), cc.Hide:create()))
    end
end

function cc.Node:position(x, y)
    if type(x) == "table" then
        self:setPosition(x)
    elseif x and y then
        self:setPosition(x, y)
    elseif x then
        self:setPositionX(x)
    elseif y then
        self:setPositionY(y)
    end
    return self
end

function cc.Node:add(child, zorder, tag)
    self:addChild(child, zorder or child:getLocalZOrder(), tag or child:getTag())
    return self
end

function cc.Node:show()
    self:setVisible(true)
    return self
end

function cc.Node:hide()
    self:setVisible(false)
    return self
end

function cc.Node:scale(scalex, scaley)
    if type(scalex) == "string" then
        local contentSize = self:getContentSize()
        if scalex == "sfull" then -- stretch to fullscreen
            self:setScale(video.width / contentSize.width, video.height / contentSize.height)    
        elseif scalex == "full" then -- scale to fullscreen with keeping aspect ratio
            if video.width / video.height > contentSize.width / contentSize.height then                
                self:setScale(video.width / contentSize.width)
            else
                self:setScale(video.height / contentSize.height)
            end
        end
    elseif scaley then
        self:setScale(scalex, scaley)
    else
        self:setScale(scalex)
    end
    return self
end

function cc.Node:rotation(r)
    self:setRotation(r)
    return self
end

function cc.Node:size(width, height)
    self:setContentSize(width, height)
    return self
end

function cc.Node:opacity(opacity)
    self:setOpacity(opacity * 255)
    return self
end

function cc.Node:zorder(z)
    self:setLocalZOrder(z)
    return self
end

function cc.Node:anchor(anchorx, anchory)
    self:setAnchorPoint(anchorx, anchory)
    return self
end

local _getChildByName = cc.Node.getChildByName
function cc.Node:getChildByName(name)
    local names = string.split(name, ".")
    local node = self
    for _, n in ipairs(names) do
        node = _getChildByName(node, n)
    end
    return node
end

function cc.Node:getFirstChildByPrefix(prefix)
    local reuslt 
    self:enumerateChildren(prefix .. "[[:alnum:]_]*", function(node) reuslt = node end)
    return reuslt
end

local _DEBUGRECT_LINE_WIDTH = 2
function cc.Node:drawDebugRect()
    local cs = self:getContentSize()
    if cs.width > 0 and cs.height > 0 then
        if not self._debugDrawNode then
            self._debugDrawNode = cc.DrawNode:create(_DEBUGRECT_LINE_WIDTH):addTo(self)
        end
        self._debugDrawNode:clear()
        self._debugDrawNode:drawRect(cc.p(0, 0), cc.p(cs.width, cs.height), cc.c4f(1, 0, 0, 1))
    end
end

-----------------------------------------------------------------------------------------
-- cc.Sprite extends
-----------------------------------------------------------------------------------------

function cc.Sprite:frame(frame)    
    if not FrameCache:getSpriteFrame(frame) then
        local tex = TextureCache:addImage(frame)
        local _frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getPixelsWide(), tex:getPixelsHigh()))
        FrameCache:addSpriteFrame(_frame, frame)
    end

    self:setSpriteFrame(frame)
    return self
end

function cc.Sprite:texture(tex)
    if type(tex) == "string" then
        self:setTexture(TextureCache:getTextureForKey(tex))
    else
        self:setTexture(tex)
    end
    return self
end

function cc.Sprite:flipX(b)
    self:setFlippedX(b or true)
    return self
end

function cc.Sprite:flipY(b)
    self:setFlippedY(b or true)
    return self
end

function cc.Sprite:playAnimation(animation, params)
    local animation = type(animation) == "string" and AnimationCache:getAnimation(animation) or animation
    local actions = {}
    local delay = params["delay"]
    if type(delay) == "number" and delay > 0 then
        self:setVisible(false)
        table.insert(actions, cc.DelayTime:create(delay))
        table.insert(actions, cc.Show:create())
    end
    local anim = cc.Animate:create(animation)
    local times = params["times"] or 1
    if times > 1 then
        table.insert(actions, cc.Repeat:create(anim, times))
    else
        table.insert(actions, anim)
    end
    if params["clean"] then
        table.insert(actions, cc.RemoveSelf:create())
    end
    local callback = params["callback"]
    if callback and type(callback) == "function" then
        table.insert(actions, cc.CallFunc:create(callback))
    end    
    if #actions == 1 then
        self:runAction(actions[1])
    else
        self:runAction(cc.Sequence:create(actions))
    end
end

function cc.Sprite:playAnimationForever(animation)
    local animation = type(animation) == "string" and AnimationCache:getAnimation(animation) or animation
    local action = cc.RepeatForever:create(cc.Animate:create(animation))
    self:runAction(action)
end