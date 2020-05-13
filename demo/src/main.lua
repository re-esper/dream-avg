require "config"
require "cocos.init"
require "framework.init" -- it replaces cocos.framework!!

require "novel.init"
require "const"

FileUtils:setPopupNotify(false)
FileUtils:addSearchPath("res/fgimage")
FileUtils:addSearchPath("res/bgimage")

__G__TRACKBACK__ = function(message)
    release_print(debug.traceback(message, 3))
end

local function main()
    math.randomseed(os.time())
    novel.initialize()
    util.loadScene("sceneLogo")
end

local status = xpcall(main, __G__TRACKBACK__)
