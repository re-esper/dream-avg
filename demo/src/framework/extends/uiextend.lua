-----------------------------------------------------------------------------------------
-- ccui.Text extends
-----------------------------------------------------------------------------------------
function ccui.Text:fitToScreen()
    local viewScale = video.viewScale
    if type(viewScale) == "number" and viewScale > 1.0 then
        self:setFontSize(self:getFontSize() * viewScale)
        self:setScale(self:getScale() / viewScale)
    end
end

-----------------------------------------------------------------------------------------
-- ccui.Button extends
-----------------------------------------------------------------------------------------
function ccui.Button:enableMouseHover(hoverSound)
    if not self._mouseHoverEnabled then
        self._mouseHoverEnabled = true
        local _mouseHovered = false
        local _mouseListener = cc.EventListenerMouse:create()
        _mouseListener:registerScriptHandler(function(event)
            local loc = event:getLocation()
            loc.y = video.height - loc.y
            local p = self:convertToNodeSpace(loc)
            local cs = self:getContentSize()
            if cc.rectContainsPoint(cc.rect(0, 0, cs.width, cs.height), p) then
                if not _mouseHovered then
                    _mouseHovered = true
                    self:setBrightStyle(ccui.BrightStyle.highlight)
                    if hoverSound then audio:playEffect(hoverSound) end
                end
            elseif _mouseHovered then
                _mouseHovered = false
                self:setBrightStyle(ccui.BrightStyle.normal)
            end
        end, cc.Handler.EVENT_MOUSE_MOVE)
        _mouseListener:registerScriptHandler(function(event)
            local loc = event:getLocation()
            loc.y = video.height - loc.y
            local p = self:convertToNodeSpace(loc)
            local cs = self:getContentSize()
            if cc.rectContainsPoint(cc.rect(0, 0, cs.width, cs.height), p) then
                self:setBrightStyle(ccui.BrightStyle.highlight)
            end
        end, cc.Handler.EVENT_MOUSE_UP)
        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(_mouseListener, self)
        self:registerScriptHandler(function(state)
            if state == "cleanup" then
                self:getEventDispatcher():removeEventListener(_mouseListener)                       
            end
        end)
    end
end

-----------------------------------------------------------------------------------------
-- ccui.ScrollView extends
-----------------------------------------------------------------------------------------
function ccui.ScrollView:arrangeChildren()
    if not self._childs then return end
    local direction = self:getDirection()
    local cs = self:getInnerContainerSize()
    local length = math.max(self._contentLength, (direction == ccui.ScrollViewDir.vertical and cs.height or cs.width))        
    for _, node in ipairs(self._childs) do
        if direction == ccui.ScrollViewDir.vertical then
            node:setPosition(cs.width * 0.5, length - node._contentLength * 0.5)
        else
            node:setPosition(length - node._contentLength * 0.5, sc.height * 0.5)
        end
        length = length - node._contentLength
    end    
end

function ccui.ScrollView:appendChild(node, length, manualUpdate)
    local direction = self:getDirection()
    if direction ~= ccui.ScrollViewDir.vertical and direction ~= ccui.ScrollViewDir.horizontal then return end
    if not self._childs then self._childs = {} end
    node._contentLength = length
    self._contentLength = (self._contentLength or 0) + length
    local cs = self:getInnerContainerSize()    
    if direction == ccui.ScrollViewDir.vertical then
        self:setInnerContainerSize(cc.size(cs.width, math.max(self._contentLength, cs.height)))
    else
        self:setInnerContainerSize(cc.size(math.max(self._contentLength, cs.width), cs.height))
    end    
    table.insert(self._childs, node)
    self:addChild(node, 1)
    if not manualUpdate then self:arrangeChildren() end
end

function ccui.ScrollView:deleteChild(node, manualUpdate)
    if not self._childs then return end
    for n, child in ipairs(self._childs) do
        if child == node then
            table.remove(self._childs, n)
            node:removeFromParent()
            if not manualUpdate then self:arrangeChildren() end
            break
        end
    end
end

-----------------------------------------------------------------------------------------
-- load root csb file
-----------------------------------------------------------------------------------------
function util.loadRootCSBFile(file)
    local root = cc.CSLoader:createNode(file)
    root:size(video.width, video.height)
    ccui.Helper:doLayout(root)    
    return root
end
