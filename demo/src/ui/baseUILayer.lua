local UILayer = class("UILayer", cc.Layer)

function UILayer:ctor()
end

function UILayer:show()
    util.enumerateChildrenWithCondition(self:getParent(), function(node)
        return node ~= self
    end, function(node)
        node:pause()
    end)    
    self:stopAllActions()
    self:fadeIn(0.5)
end

function UILayer:hide()
    util.enumerateChildrenWithCondition(self:getParent(), function(node)
        return node ~= self
    end, function(node)
        node:resume()
    end)
    self:stopAllActions()
    self:fadeOut(0.5)
end

return UILayer