local device = {}
export("device", device)

device.platform    = "unknown"
device.model       = "unknown"

local target = Application:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    device.platform = "windows"
elseif target == cc.PLATFORM_OS_MAC then
    device.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    device.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    device.platform = "ios"
    if target == cc.PLATFORM_OS_IPHONE then
        device.model = "iphone"
    else
        device.model = "ipad"
    end
elseif target == cc.PLATFORM_OS_WINRT then
    device.platform = "winrt"
elseif target == cc.PLATFORM_OS_WP8 then
    device.platform = "wp8"
end

local language_ = Application:getCurrentLanguage()
if language_ == cc.LANGUAGE_CHINESE then
    language_ = "cn"
elseif language_ == cc.LANGUAGE_FRENCH then
    language_ = "fr"
elseif language_ == cc.LANGUAGE_ITALIAN then
    language_ = "it"
elseif language_ == cc.LANGUAGE_GERMAN then
    language_ = "gr"
elseif language_ == cc.LANGUAGE_SPANISH then
    language_ = "sp"
elseif language_ == cc.LANGUAGE_RUSSIAN then
    language_ = "ru"
elseif language_ == cc.LANGUAGE_KOREAN then
    language_ = "kr"
elseif language_ == cc.LANGUAGE_JAPANESE then
    language_ = "jp"
elseif language_ == cc.LANGUAGE_HUNGARIAN then
    language_ = "hu"
elseif language_ == cc.LANGUAGE_PORTUGUESE then
    language_ = "pt"
elseif language_ == cc.LANGUAGE_ARABIC then
    language_ = "ar"
else
    language_ = "en"
end

device.language = language_
device.writablePath = FileUtils:getWritablePath()
device.directorySeparator = "/"
device.pathSeparator = ":"
if device.platform == "windows" then
    device.directorySeparator = "\\"
    device.pathSeparator = ";"
end

printf("[INFO] # device.platform              = " .. device.platform)
printf("[INFO] # device.model                 = " .. device.model)
printf("[INFO] # device.language              = " .. device.language)
printf("[INFO] # device.writablePath          = " .. device.writablePath)
printf("[INFO] # device.directorySeparator    = " .. device.directorySeparator)
printf("[INFO] # device.pathSeparator         = " .. device.pathSeparator)

