-- 0 - no debug, 1 - debug mode with less info, 2 - debug mode full
DEBUG = 0

-- diplay FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- design resolution
local WIDTH = 1680
local HEIGHT = 1080
CONFIG_DESIGN = {
    width       = WIDTH,
    height      = HEIGHT,
    policy      = "FIXED_HEIGHT",
    --[[callback    = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio < WIDTH / HEIGHT then
            return { policy = "FIXED_WIDTH" }
        end
    end]]
}

CONFIG_TITLE = "桜花恋舞"