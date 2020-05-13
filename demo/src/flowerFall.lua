local m = {}

local DEFAULT_GRAVITY = 0.4
local POW_GRAVITY = 0.05
local DEFAULT_WIND = 1
local POW_WIND = 1.5
local FLOWER_MAX_HEIGHT_HALF = 48 * 1.5 * 0.5

local flowers = {}
function m.initFlowers()
    util.loadSpriteFrame("flower_anime.png", "flower1", 1, 10)
    util.loadSpriteFrame("flower_anime2.png", "flower2", 1, 18)

    AnimationCache:addAnimation(cc.Animation:build("flower1_%d", 1, 10, 1 / 24, true), "flower_s")
    AnimationCache:addAnimation(cc.Animation:build("flower2_%d", 1, 18, 1 / 20, true), "flower_m")
    AnimationCache:addAnimation(cc.Animation:build("flower1_%d", 1, 10, 1 / 16, true), "flower_b")

    local defs = {
        { "flower_s", 1 },
        { "flower_m", 1.25 },
        { "flower_b", 1.5 }
    }
    local function _initFlowerNode(type, radius, angle, moveY)
        local spr = cc.Sprite:create():addTo(math.random(1, 3))
        spr:playAnimationForever(defs[type][1])
        spr:setScale(defs[type][2])

        spr.moveY = moveY
        spr.moveA = math.random() * angle + 0.35
        spr.angle = 0
        spr.r = radius

		spr.gravity = DEFAULT_GRAVITY
		spr.wind = DEFAULT_WIND

        spr.offsetx = -math.random() * 0.4 * video.width
        spr.y = (1 + math.random()) * video.height - 150
        spr:setRotation(math.random() * 90 - 45)
        return spr
    end

    for i = 1, 10 do
        table.insert(flowers, _initFlowerNode(1, 290, 0.2, 2))
        table.insert(flowers, _initFlowerNode(2, 270, 0.18, 1.8))
        table.insert(flowers, _initFlowerNode(3, 250, 0.16, 1.6))
    end
end

function m.updateFlowers()
    for i = 1, #flowers do
        local spr = flowers[i]

        spr.gravity = spr.gravity - POW_GRAVITY
        if spr.gravity < 0.1 then spr.gravity = 0.1 end

        spr.wind = spr.wind + POW_WIND

        local moveX = spr.r * math.sin(spr.angle / 180 * math.pi)
        local y = spr.y - spr.moveY - spr.gravity
        spr.angle = (spr.angle + spr.moveA) % 360

        local x = spr.y + moveX + spr.wind + spr.offsetx
        if y < -FLOWER_MAX_HEIGHT_HALF then
            -- reset
            spr.offsetx = -math.random() * 0.4 * video.width
            spr.y = math.random(1, 1.5) * video.height + FLOWER_MAX_HEIGHT_HALF
            spr.wind = DEFAULT_WIND
        else
            spr.y = y
        end
        spr:setPosition(x, spr.y)
    end
end

function m.stop()
    for i = 1, #flowers do
        flowers[i]:removeFromParent()
    end
    flowers = {}
end

return m