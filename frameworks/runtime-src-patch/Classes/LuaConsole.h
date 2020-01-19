#ifndef __LUACONSOLE_H__
#define __LUACONSOLE_H__

#include <iostream>
#include <sstream>
#include <map>
#include "scripting/lua-bindings/manual/CCLuaEngine.h"

class LuaConsole
{	
public:
	static LuaConsole* getInstance();

	LuaConsole() : _running(false) {}
	~LuaConsole() {}
	void run();
	int stop() { _running = false; }
protected:
	void init();	
	virtual int proc();	

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
private:
	bool win32MakeSimulator();
	static void relaunchApplication();
	static LRESULT CALLBACK win32HookProc(HWND hWnd, UINT wMsg, WPARAM wParam, LPARAM lParam);	 
	static WNDPROC _origWndProc;
#endif

protected:
	bool	_running;	
};

#endif // __LUACONSOLE_H__
