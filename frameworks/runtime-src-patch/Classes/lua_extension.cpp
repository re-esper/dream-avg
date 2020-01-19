#include "lua_extension.h"
#include <math.h>

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "lua/luasocket/auxiliar.h"
}

#include "platform/CCFileUtils.h"
#include "scripting/lua-bindings/manual/CCLuaStack.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

USING_NS_CC;

static int lua_loadCode(lua_State *L)
{
	std::string filename(luaL_checkstring(L, 1));	
	Data data = FileUtils::getInstance()->getDataFromFile(filename);
	if (!data.isNull()) {
		LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
		stack->luaLoadBuffer(L, (char*)data.getBytes(), (int)data.getSize(), filename.c_str());
	}
	else {
		CCLOG("Can not load lua file of %s", filename.c_str());
		return 0;
	}
	return 1;
}

#include "base/ccUtils.h"
static int lua_captureNode(lua_State *L)
{	
	int argc = lua_gettop(L);
	bool ok = true;	
	do {
		if (argc < 2)  break;

		cocos2d::Node* node;
		ok &= luaval_to_object<cocos2d::Node>(L, 1, "cc.Node", &node, __FUNCTION__);
		if (!ok) break;

		std::string fileName;
		ok &= luaval_to_std_string(L, 2, &fileName, __FUNCTION__);
		if (!ok) break;

		bool isToRGB = true;		
		if (argc >= 3 && lua_isboolean(L, 3))  {
			isToRGB = lua_toboolean(L, 3) != 0;
		}

		auto image = utils::captureNode(node);
		bool succ = image->saveToFile(fileName, isToRGB);
		lua_pushboolean(L, succ);
		return 1;

	} while (0);

	luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d \n", __FUNCTION__, argc, 2);
	return 0;
}

static const struct luaL_Reg extension_lib[] = {
	{ "loadFile", lua_loadCode },
	{ "captureNode", lua_captureNode },
	{ NULL, NULL},
};


int register_extension_lib(lua_State *L)
{	
	luaL_openlib(L, "util", extension_lib, 0);
	return 1;
}
