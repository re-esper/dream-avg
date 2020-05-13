#include "base/ccConfig.h"

#ifndef LUA_COCOS2DX_EXTEND_MANUAL_H
#define LUA_COCOS2DX_EXTEND_MANUAL_H

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

TOLUA_API int register_cocos2dx_extend_manual(lua_State* L);

#endif //#ifndef LUA_COCOS2DX_EXTEND_MANUAL_H
