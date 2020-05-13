#include "lua_extension.h"
#include <math.h>

extern "C" {
#include "lauxlib.h"
#include "lua.h"
#include "lua/luasocket/auxiliar.h"
#include "lualib.h"
}

#include "platform/CCFileUtils.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/CCLuaStack.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

#include "xxhash/xxhash.h"
#include "ActionShake.h"

USING_NS_CC;

#include "base/ccUtils.h"
static int lua_captureNode(lua_State* L)
{
    int argc = lua_gettop(L);
    bool ok = true;
    do {
        if (argc < 2) break;

        cocos2d::Node* node;
        ok &= luaval_to_object<cocos2d::Node>(L, 1, "cc.Node", &node, __FUNCTION__);
        if (!ok) break;

        std::string fileName;
        ok &= luaval_to_std_string(L, 2, &fileName, __FUNCTION__);
        if (!ok) break;

        double scale = 1.0f;
        if (argc >= 3) {
            ok &= luaval_to_number(L, 3, &scale, __FUNCTION__);
            if (!ok) break;
        }
        bool isToRGB = true;
        if (argc >= 4 && lua_isboolean(L, 4)) {
            isToRGB = lua_toboolean(L, 4) != 0;
        }

        auto image = utils::captureNode(node, scale);
        bool succ = image->saveToFile(fileName, isToRGB);
        lua_pushboolean(L, succ);
        return 1;

    } while (0);

    luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d \n", __FUNCTION__, argc, 2);
    return 0;
}

int lua_messageBox(lua_State* L)
{
    int argc = lua_gettop(L);
    if (argc > 0) {
        const char* msg = luaL_checkstring(L, 1);
        const char* title = argc > 1 ? luaL_checkstring(L, 2) : "";
        cocos2d::MessageBox(msg, title);
    }
    return 0;
}

std::string bin2hex(unsigned char* bin, size_t l)
{
    static const char* hextable = "0123456789abcdef";
    std::string hex;
    hex.resize(l * 2);
    int ci = 0;
    for (int i = 0; i < l; ++i) {
        unsigned char c = bin[i];
        hex[ci++] = hextable[(c >> 4) & 0x0f];
        hex[ci++] = hextable[c & 0x0f];
    }
    return hex;
}
int lua_xxhash(lua_State* L)
{
    int argc = lua_gettop(L);
    if (argc > 0) {
        size_t input_l = 0;
        const char* input = luaL_checklstring(L, 1, &input_l);
        auto output = XXH32(input, input_l, 0);
        std::string hex = bin2hex((unsigned char*)&output, sizeof(output));
        lua_pushlstring(L, hex.c_str(), hex.length());
        return 1;
    }
    return 0;
}

#define SHAKE_SCREEN_TAG 0x1001
int lua_shakeScreen(lua_State *L)
{
    int l = lua_gettop(L);
    float duration = luaL_checknumber(L, 1);
    float speed = luaL_checknumber(L, 2);
    float magnitude = luaL_checknumber(L, 3);
    auto scene = Director::getInstance()->getRunningScene();
    scene->stopAllActionsByTag(SHAKE_SCREEN_TAG);
    auto action = ActionShake::create(duration, speed, magnitude);
    action->setTag(SHAKE_SCREEN_TAG);
    scene->runAction(action);
    return 0;
}

static const struct luaL_Reg extension_lib[] = {
    { "captureNode", lua_captureNode },
    { "messageBox", lua_messageBox },
    { "hash", lua_xxhash },
    { "shakeScreen", lua_shakeScreen },
    { NULL, NULL },
};

int register_extension_lib(lua_State* L)
{
    luaL_openlib(L, "util", extension_lib, 0);
    return 1;
}
