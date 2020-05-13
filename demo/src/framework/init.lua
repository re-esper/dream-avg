------------------------------------------------------------------------------
--
-- My-style cocos2d-lua framework
-- It replaces cocos2d-x official src/cocos/framework, with different apis
-- and more features.
--
------------------------------------------------------------------------------

require "framework.common"
require "framework.utils"
require "framework.audio"
require "framework.video"
require "framework.device"
require "framework.routine"

require "framework.extends.extend"
require "framework.extends.uiextend"
require "framework.extends.scene"
require "framework.extends.action"

if type(DEBUG) ~= "number" then DEBUG = 0 end
if type(DEBUG_FPS) ~= "boolean" then DEBUG_FPS = false end
if type(DEBUG_MEM) ~= "boolean" then DEBUG_MEM = false end

Director:setDisplayStats(DEBUG_FPS)

if DEBUG_MEM then    
    local function showMemoryUsage()
        printf("[INFO] LUA VM MEMORY USED: %0.2f KB", collectgarbage("count"))
        printf("[INFO] " .. TextureCache:getCachedTextureInfo())
        printf("[INFO] ---------------------------------------------------")
    end
    Scheduler:scheduleScriptFunc(showMemoryUsage, DEBUG_MEM_INTERVAL or 10.0, false)
end