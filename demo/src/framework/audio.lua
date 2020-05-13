local audio = ccexp.AudioEngine
export("audio", audio)

local _volumeMusic = 1.0
local _volumeEffect = 1.0
-- "music" for music channel
-- 1, 2, 3, ... for sound effect channels
local _audioChannels = {} 

function audio:getMusicVolume()
    return _volumeMusic
end
function audio:setMusicVolume(volume)
    _volumeMusic = math.clamp(volume, 0.0, 1.0)
    if _audioChannels["music"] then
        self:setVolume(_audioChannels["music"], _volumeMusic)
    end
end
function audio:getEffectVolume()
    return _volumeEffect
end
function audio:setEffectVolume(volume)
    volume = math.clamp(volume, 0.0, 1.0)
    if _volumeEffect ~= volume then
        for k, id in pairs(_audioChannels) do
            if k ~= "music" then
                self:setVolume(id, volume)
            end
        end
        _volumeEffect = volume
    end
end

local function audioFade(audioId, duration, from, to, callback)
    local time = 0
    local handle
    handle = Scheduler:scheduleScriptFunc(function(dt)
        time = time + dt
        if time >= duration then
            audio:setVolume(audioId, to)
            Scheduler:unscheduleScriptEntry(handle)
            if callback and type(callback) == "function" then callback() end
        else
            audio:setVolume(audioId, math.lerp(from, to, time / duration))
        end
    end, 0, false)
end

function audio:playMusic(filename, isloop, fadeIn)
    local musicId = _audioChannels["music"]
    if musicId then audio:stop(musicId) end
    if fadeIn then
        musicId = audio:play2d(filename, isloop, _volumeMusic)
        audioFade(musicId, fadeIn, 0, _volumeMusic)
    else
        musicId = audio:play2d(filename, isloop, _volumeMusic)
    end
    _audioChannels["music"] = musicId
    return musicId
end
function audio:stopMusic(fadeOut)
    local musicId = _audioChannels["music"]
    if musicId then
        if fadeOut then
            audioFade(musicId, fadeOut, _volumeMusic, 0, function()
                audio:stop(musicId)
            end)
        else
            audio:stop(musicId)
        end
        _audioChannels["music"] = nil        
    end
end
function audio:playEffect(filename, channel, isloop, fadeIn)    
    local audioId
    if channel then
        audioId = _audioChannels[channel]
        if audioId then audio:stop(audioId) end
    end
    if fadeIn then
        audioId = audio:play2d(filename, isloop, 0)
        audioFade(audioId, fadeIn, 0, _volumeEffect)
    else
        audioId = audio:play2d(filename, isloop, _volumeEffect)
    end
    if channel then        
        _audioChannels[channel] = audioId
    end
    return audioId
end
function audio:stopEffect(channel, fadeOut)
    local audioId = _audioChannels[channel]
    if audioId then
        if fadeOut then
            audioFade(audioId, fadeOut, audio:getVolume(audioId), 0, function()
                audio:stop(audioId)
            end)
        else
            audio:stop(audioId)
        end
        _audioChannels[channel] = nil
    end
end

function audio:reset()
    for k, id in pairs(_audioChannels) do
        audio:stop(id)
    end
    _audioChannels = {}
end