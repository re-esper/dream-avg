#include "lua_cocos2dx_extend_manual.hpp"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "ui/CocosGUI.h"

int lua_cocos2dx_ui_RichText_clear(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::ui::RichText* cobj = nullptr;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "ccui.RichText", 0, &tolua_err))
        goto tolua_lerror;
#endif

    cobj = (cocos2d::ui::RichText*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_ui_RichText_clear'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 0) {
        cobj->clear();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "ccui.RichText:clear", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_ui_RichText_clear'.", &tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_ui_RichText_startSpawn(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::ui::RichText* cobj = nullptr;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "ccui.RichText", 0, &tolua_err))
        goto tolua_lerror;
#endif

    cobj = (cocos2d::ui::RichText*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_ui_RichText_startSpawn'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S) - 1;
    if (2 == argc) {
#if COCOS2D_DEBUG >= 1
        if (!toluafix_isfunction(tolua_S, 3, "LUA_FUNCTION", 0, &tolua_err) || !toluafix_isfunction(tolua_S, 2, "LUA_FUNCTION", 0, &tolua_err))
            goto tolua_lerror;
#endif
        LUA_FUNCTION stephandler = toluafix_ref_function(tolua_S, 3, 0);
        LUA_FUNCTION finalhandler = toluafix_ref_function(tolua_S, 2, 0);
        cobj->startSpawn([=]() {
            LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(finalhandler, 0);
            LuaEngine::getInstance()->removeScriptHandler(finalhandler); }, [=](int current, int max) {
            tolua_pushnumber(tolua_S, current);
            tolua_pushnumber(tolua_S, max);
            LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(stephandler, 2);
            LuaEngine::getInstance()->removeScriptHandler(finalhandler); });
    } else if (1 == argc) {
#if COCOS2D_DEBUG >= 1
        if (!toluafix_isfunction(tolua_S, 2, "LUA_FUNCTION", 0, &tolua_err))
            goto tolua_lerror;
#endif
        LUA_FUNCTION finalhandler = toluafix_ref_function(tolua_S, 2, 0);
        cobj->startSpawn([=]() {
            LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(finalhandler, 0);
            LuaEngine::getInstance()->removeScriptHandler(finalhandler);
        });
    } else if (0 == argc) {
        cobj->startSpawn();
    }
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_ui_RichText_startSpawn'.", &tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_ui_RichText_stopSpawn(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::ui::RichText* cobj = nullptr;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "ccui.RichText", 0, &tolua_err))
        goto tolua_lerror;
#endif

    cobj = (cocos2d::ui::RichText*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_ui_RichText_stopSpawn'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 0) {
        cobj->stopSpawn();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "ccui.RichText:stopSpawn", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_ui_RichText_stopSpawn'.", &tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_ui_RichText_resumeSpawn(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::ui::RichText* cobj = nullptr;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "ccui.RichText", 0, &tolua_err))
        goto tolua_lerror;
#endif

    cobj = (cocos2d::ui::RichText*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_ui_RichText_resumeSpawn'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 0) {
        cobj->resumeSpawn();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "ccui.RichText:resumeSpawn", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_ui_RichText_resumeSpawn'.", &tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_ui_RichText_getSpawnSpeed(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::ui::RichText* cobj = nullptr;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "ccui.RichText", 0, &tolua_err))
        goto tolua_lerror;
#endif
    cobj = (cocos2d::ui::RichText*)tolua_tousertype(tolua_S, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (!cobj) {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_ui_RichText_getSpawnSpeed'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 0) {
        if (!ok) {
            tolua_error(tolua_S, "invalid arguments in function 'lua_cocos2dx_ui_RichText_getSpawnSpeed'", nullptr);
            return 0;
        }
        double ret = cobj->getSpawnSpeed();
        tolua_pushnumber(tolua_S, (lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "ccui.RichText:getSpawnSpeed", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_ui_RichText_getSpawnSpeed'.", &tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_ui_RichText_setSpawnSpeed(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::ui::RichText* cobj = nullptr;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "ccui.RichText", 0, &tolua_err))
        goto tolua_lerror;
#endif
    cobj = (cocos2d::ui::RichText*)tolua_tousertype(tolua_S, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (!cobj) {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_ui_RichText_setSpawnSpeed'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 1) {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2, &arg0, "ccui.RichText:setSpawnSpeed");
        if (!ok) {
            tolua_error(tolua_S, "invalid arguments in function 'lua_cocos2dx_ui_RichText_setSpawnSpeed'", nullptr);
            return 0;
        }
        cobj->setSpawnSpeed(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "ccui.RichText:setSpawnSpeed", argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_ui_RichText_setSpawnSpeed'.", &tolua_err);
#endif
    return 0;
}

static void extendRichText(lua_State* L)
{
    lua_pushstring(L, "ccui.RichText");
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (lua_istable(L, -1)) {
        tolua_function(L, "clear", lua_cocos2dx_ui_RichText_clear);
        tolua_function(L, "startSpawn", lua_cocos2dx_ui_RichText_startSpawn);
        tolua_function(L, "stopSpawn", lua_cocos2dx_ui_RichText_stopSpawn);
        tolua_function(L, "resumeSpawn", lua_cocos2dx_ui_RichText_resumeSpawn);
        tolua_function(L, "getSpawnSpeed", lua_cocos2dx_ui_RichText_getSpawnSpeed);
        tolua_function(L, "setSpawnSpeed", lua_cocos2dx_ui_RichText_setSpawnSpeed);
    }
    lua_pop(L, 1);
}

int register_cocos2dx_extend_manual(lua_State* L)
{
    if (nullptr == L)
        return 0;

    extendRichText(L);

    return 0;
}
