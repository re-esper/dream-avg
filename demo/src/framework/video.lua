local video = {}
export("video", video)

-- check device screen size
local glview = Director:getOpenGLView()
if nil == glview then
    -- Win32 branch
    local title = CONFIG_TITLE or "Cocos2d-Lua"
    if CONFIG_SIMULATOR and CONFIG_SIMULATOR.fullscreen then
        glview = cc.GLViewImpl:createWithFullScreen(title)
    else
        local w, h = 960, 640
        if CONFIG_SIMULATOR and CONFIG_SIMULATOR.width then
            w = CONFIG_SIMULATOR.width
        elseif CONFIG_DESIGN and CONFIG_DESIGN.width then
            w = CONFIG_DESIGN.width
        end
        if CONFIG_SIMULATOR and CONFIG_SIMULATOR.height then
            h = CONFIG_SIMULATOR.height
        elseif CONFIG_DESIGN and CONFIG_DESIGN.height then
            h = CONFIG_DESIGN.height
        end
        glview = cc.GLViewImpl:createWithRect(title, cc.rect(0, 0, w, h))
    end
    Director:setOpenGLView(glview)
end

local framesize = glview:getFrameSize()
video.sizeInPixels = { width = framesize.width, height = framesize.height }

function util.setResolutionPolicy(config)
    if type(config) == "table" then
        if type(config.callback) == "function" then
            local c = config.callback(framesize)
            for k, v in pairs(c or {}) do
                config[k] = v
            end
        end
        if config.policy and cc.ResolutionPolicy[config.policy] then
            glview:setDesignResolutionSize(config.width, config.height, cc.ResolutionPolicy[config.policy])
            local visibleSize = Director:getVisibleSize()
            video.widthDesigned = config.width
            video.heightDesigned = config.height
            video.widthVisible = visibleSize.width
            video.heightVisible = visibleSize.height

            local winSize = Director:getWinSize()
            video.size = { width = winSize.width, height = winSize.height }
            video.width = video.size.width
            video.height = video.size.height
            video.center = { x = video.width * 0.5, y = video.height * 0.5 }

            printf("[INFO] # design resolution policy     = %s", config.policy)
            printf("[INFO] # design resolution size       = { width = %0.2f, height = %0.2f }", video.widthDesigned, video.heightDesigned)
            printf("[INFO] # visible size                 = { width = %0.2f, height = %0.2f }", video.widthVisible, video.heightVisible)
            printf("[INFO] # video.width                  = %0.2f", video.width)
            printf("[INFO] # video.height                 = %0.2f", video.height)
            printf("[INFO] # video.center                 = { x = %0.2f, y = %0.2f }", video.center.x, video.center.y)
            if glview:getScaleX() == glview:getScaleY() then
                video.viewScale = glview:getScaleX()
                printf("[INFO] # video.viewScale              = %0.2f", video.viewScale)
            else
                video.viewScale = { x = glview:getScaleX(), y = glview:getScaleY() }
                printf("[INFO] # video.viewScale              = { x = %0.2f, y = %0.2f }", video.viewScale.x, video.viewScale.y)
            end
        end
    end
end

util.setResolutionPolicy(CONFIG_DESIGN)

video.widthInPixels      = video.sizeInPixels.width
video.heightInPixels     = video.sizeInPixels.height

printf("[INFO] # video.widthInPixels          = %0.2f", video.widthInPixels)
printf("[INFO] # video.heightInPixels         = %0.2f", video.heightInPixels)
