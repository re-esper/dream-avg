#include "LuaConsole.h"
#include "cocos2d.h"
#include <thread>

// singleton stuff
static LuaConsole *s_LuaConsole = nullptr;
LuaConsole* LuaConsole::getInstance()
{
	if (!s_LuaConsole) {
		s_LuaConsole = new (std::nothrow) LuaConsole();
		s_LuaConsole->init();
	}
	return s_LuaConsole;
}

void LuaConsole::init()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    AllocConsole();
    freopen("CONIN$", "r", stdin);
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);

	HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
	if (h) {
        SMALL_RECT sr = { 0, 0, 100 - 1, 48 - 1 };
        SetConsoleWindowInfo(h, TRUE, &sr);

        COORD c = { 100, 4096 };
        SetConsoleScreenBufferSize(h, c);

        HWND con = GetConsoleWindow();
        RECT r = { 0 };
        GetWindowRect(con, &r);
        MoveWindow(con, 0, r.top, 1200, 800, TRUE);
    }
#endif
}

bool is_empty_code(std::string &s) 
{
	if (s.empty()) return true;
	s.erase(0,s.find_first_not_of(" "));
	s.erase(s.find_last_not_of(" ") + 1);
	return s.empty();
}

int LuaConsole::proc()
{
	_running = true;
	
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	bool installed = false;
	while (_running && !installed) {
		installed = win32MakeSimulator();
		std::this_thread::sleep_for(std::chrono::milliseconds(200));
	}
#endif
	std::string cmd_buffer;
	char cmdline[1024];
	bool pending = false;
	auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
	auto sched = cocos2d::Director::getInstance()->getScheduler();
	while (_running)
	{
		std::cout << (pending ? ".. " : ">> ");
		std::cin.getline(cmdline, 1024);
		
		int se = strlen(cmdline);
		if (se > 2 && cmdline[se-1] == '\\') {
			cmdline[se-1] = '\n';
			cmd_buffer += cmdline;
			pending = true;
			continue;
		}

		cmd_buffer += cmdline;

		bool is_cmd_done = false;
		if (!is_empty_code(cmd_buffer)) {
			sched->performFunctionInCocosThread([&] {
				auto L = stack->getLuaState();
				lua_pushboolean(L, false);
				lua_setglobal(stack->getLuaState(), "__G__STRICTWARNING__");
				stack->executeString(cmd_buffer.c_str());
				lua_pushboolean(L, true);
				lua_setglobal(stack->getLuaState(), "__G__STRICTWARNING__");
				is_cmd_done = true;
			});
			while (!is_cmd_done) { std::this_thread::sleep_for(std::chrono::milliseconds(0)); }
		}
		pending = false;
		cmd_buffer = "";
	}
	return 0;
}

void LuaConsole::run()
{		
	std::thread([this]{ proc(); }).detach();
}

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

HWND getWin32Window()
{
	auto glview = cocos2d::Director::getInstance()->getOpenGLView();
	if (!glview) return NULL;
	return glview->getWin32Window();	
}

// relaunch the application
void LuaConsole::relaunchApplication()
{
	PROCESS_INFORMATION pi = {0};
	STARTUPINFO si = {0};
	si.cb = sizeof(STARTUPINFO);	
	GetStartupInfo(&si);	
	auto hwnd = getWin32Window();
	if (hwnd) {
		// restore window position
		RECT r = { 0 };
		GetWindowRect(hwnd, &r);
		si.dwFlags |= STARTF_USEPOSITION;
		si.dwX = r.left;
		si.dwY = r.top;
	}
	// use parent's current directory and environment 
	if (CreateProcess(NULL, GetCommandLine(), NULL, NULL, FALSE, 
		DETACHED_PROCESS, NULL, NULL, &si, &pi)) {
		cocos2d::Director::getInstance()->end();
	}
}

WNDPROC LuaConsole::_origWndProc = NULL;
bool LuaConsole::win32MakeSimulator()
{
	auto hwnd = getWin32Window();
	if (!hwnd) return false;
	
	_origWndProc = (WNDPROC)GetWindowLong(hwnd, GWL_WNDPROC);
	SetWindowLong(hwnd, GWL_WNDPROC, (DWORD)LuaConsole::win32HookProc);
	RECT r = { 0 };
	GetWindowRect(hwnd, &r);

    auto sched = cocos2d::Director::getInstance()->getScheduler();
    sched->performFunctionInCocosThread([&] {
        auto L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
        lua_getglobal(L, "CONFIG_SIMULATOR");
        if (!lua_istable(L, -1)) {
            lua_pop(L, 1);
        }
        else {
            lua_getfield(L, -1, "fullscreen");
            bool isFullScreen = lua_isboolean(L, -1) ? lua_toboolean(L, -1) : false;
            lua_pop(L, 1);
            if (!isFullScreen) {
                lua_getfield(L, -1, "offset_x");
                int offset_x = lua_isnumber(L, -1) ? lua_tonumber(L, -1) - r.left : 0;
                lua_getfield(L, -2, "offset_y");
                int offset_y = lua_isnumber(L, -1) ? lua_tonumber(L, -1) - r.top : 0;
                lua_pop(L, 3);
                MoveWindow(hwnd, r.left + offset_x, r.top + offset_y, r.right - r.left, r.bottom - r.top, TRUE);
            }
        }
    });
	return true;
}
LRESULT CALLBACK LuaConsole::win32HookProc(HWND hWnd, UINT wMsg, WPARAM wParam, LPARAM lParam)
{
	switch (wMsg) {
	case WM_KEYDOWN:
		if (wParam == VK_F5) {
            // relaunch the application
            relaunchApplication();
		}
		break;
	}
	return CallWindowProc(_origWndProc, hWnd, wMsg, wParam, lParam);
}
#endif

