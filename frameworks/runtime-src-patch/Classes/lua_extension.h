#ifndef __LUA_EXTENSION_H__
#define __LUA_EXTENSION_H__

extern "C" {
#include "lua.h"
}

int register_extension_lib(lua_State *L);

#endif