var keyboard = (function() {

	var KeyEvent = {
		DOM_VK_CANCEL              : 3,
		DOM_VK_HELP                : 6,
		DOM_VK_BACK_SPACE          : 8,
		DOM_VK_TAB                 : 9,
		DOM_VK_CLEAR               : 12,
		DOM_VK_RETURN              : 13,
		DOM_VK_SHIFT               : 16,
		DOM_VK_CONTROL             : 17,
		DOM_VK_ALT                 : 18,
		DOM_VK_PAUSE               : 19,
		DOM_VK_CAPS_LOCK           : 20,
		DOM_VK_KANA                : 21,
		DOM_VK_HANGUL              : 21,
		DOM_VK_EISU                : 22,
		DOM_VK_JUNJA               : 23,
		DOM_VK_FINAL               : 24,
		DOM_VK_HANJA               : 25,
		DOM_VK_KANJI               : 25,
		DOM_VK_ESCAPE              : 27,
		DOM_VK_CONVERT             : 28,
		DOM_VK_NONCONVERT          : 29,
		DOM_VK_ACCEPT              : 30,
		DOM_VK_MODECHANGE          : 31,
		DOM_VK_SPACE               : 32,
		DOM_VK_PAGE_UP             : 33,
		DOM_VK_PAGE_DOWN           : 34,
		DOM_VK_END                 : 35,
		DOM_VK_HOME                : 36,
		DOM_VK_LEFT                : 37,
		DOM_VK_UP                  : 38,
		DOM_VK_RIGHT               : 39,
		DOM_VK_DOWN                : 40,
		DOM_VK_SELECT              : 41,
		DOM_VK_PRINT               : 42,
		DOM_VK_EXECUTE             : 43,
		DOM_VK_PRINTSCREEN         : 44,
		DOM_VK_INSERT              : 45,
		DOM_VK_DELETE              : 46,
		DOM_VK_0                   : 48,
		DOM_VK_1                   : 49,
		DOM_VK_2                   : 50,
		DOM_VK_3                   : 51,
		DOM_VK_4                   : 52,
		DOM_VK_5                   : 53,
		DOM_VK_6                   : 54,
		DOM_VK_7                   : 55,
		DOM_VK_8                   : 56,
		DOM_VK_9                   : 57,
		DOM_VK_COLON               : 58,
		DOM_VK_SEMICOLON           : 59,
		DOM_VK_LESS_THAN           : 60,
		DOM_VK_EQUALS              : 61,
		DOM_VK_GREATER_THAN        : 62,
		DOM_VK_QUESTION_MARK       : 63,
		DOM_VK_AT                  : 64,
		DOM_VK_A                   : 65,
		DOM_VK_B                   : 66,
		DOM_VK_C                   : 67,
		DOM_VK_D                   : 68,
		DOM_VK_E                   : 69,
		DOM_VK_F                   : 70,
		DOM_VK_G                   : 71,
		DOM_VK_H                   : 72,
		DOM_VK_I                   : 73,
		DOM_VK_J                   : 74,
		DOM_VK_K                   : 75,
		DOM_VK_L                   : 76,
		DOM_VK_M                   : 77,
		DOM_VK_N                   : 78,
		DOM_VK_O                   : 79,
		DOM_VK_P                   : 80,
		DOM_VK_Q                   : 81,
		DOM_VK_R                   : 82,
		DOM_VK_S                   : 83,
		DOM_VK_T                   : 84,
		DOM_VK_U                   : 85,
		DOM_VK_V                   : 86,
		DOM_VK_W                   : 87,
		DOM_VK_X                   : 88,
		DOM_VK_Y                   : 89,
		DOM_VK_Z                   : 90,
		DOM_VK_WIN                 : 91,
		DOM_VK_CONTEXT_MENU        : 93,
		DOM_VK_SLEEP               : 95,
		DOM_VK_NUMPAD0             : 96,
		DOM_VK_NUMPAD1             : 97,
		DOM_VK_NUMPAD2             : 98,
		DOM_VK_NUMPAD3             : 99,
		DOM_VK_NUMPAD4             : 100,
		DOM_VK_NUMPAD5             : 101,
		DOM_VK_NUMPAD6             : 102,
		DOM_VK_NUMPAD7             : 103,
		DOM_VK_NUMPAD8             : 104,
		DOM_VK_NUMPAD9             : 105,
		DOM_VK_MULTIPLY            : 106,
		DOM_VK_ADD                 : 107,
		DOM_VK_SEPARATOR           : 108,
		DOM_VK_SUBTRACT            : 109,
		DOM_VK_DECIMAL             : 110,
		DOM_VK_DIVIDE              : 111,
		DOM_VK_F1                  : 112,
		DOM_VK_F2                  : 113,
		DOM_VK_F3                  : 114,
		DOM_VK_F4                  : 115,
		DOM_VK_F5                  : 116,
		DOM_VK_F6                  : 117,
		DOM_VK_F7                  : 118,
		DOM_VK_F8                  : 119,
		DOM_VK_F9                  : 120,
		DOM_VK_F10                 : 121,
		DOM_VK_F11                 : 122,
		DOM_VK_F12                 : 123,
		DOM_VK_F13                 : 124,
		DOM_VK_F14                 : 125,
		DOM_VK_F15                 : 126,
		DOM_VK_F16                 : 127,
		DOM_VK_F17                 : 128,
		DOM_VK_F18                 : 129,
		DOM_VK_F19                 : 130,
		DOM_VK_F20                 : 131,
		DOM_VK_F21                 : 132,
		DOM_VK_F22                 : 133,
		DOM_VK_F23                 : 134,
		DOM_VK_F24                 : 135,
		DOM_VK_NUM_LOCK            : 144,
		DOM_VK_SCROLL_LOCK         : 145,
		DOM_VK_WIN_OEM_FJ_JISHO    : 146,
		DOM_VK_WIN_OEM_FJ_MASSHOU  : 147,
		DOM_VK_WIN_OEM_FJ_TOUROKU  : 148,
		DOM_VK_WIN_OEM_FJ_LOYA     : 149,
		DOM_VK_WIN_OEM_FJ_ROYA     : 150,
		DOM_VK_CIRCUMFLEX          : 160,
		DOM_VK_EXCLAMATION         : 161,
		DOM_VK_DOUBLE_QUOTE        : 162,
		DOM_VK_HASH                : 163,
		DOM_VK_DOLLAR              : 164,
		DOM_VK_PERCENT             : 165,
		DOM_VK_AMPERSAND           : 166,
		DOM_VK_UNDERSCORE          : 167,
		DOM_VK_OPEN_PAREN          : 168,
		DOM_VK_CLOSE_PAREN         : 169,
		DOM_VK_ASTERISK            : 170,
		DOM_VK_PLUS                : 171,
		DOM_VK_PIPE                : 172,
		DOM_VK_HYPHEN_MINUS        : 173,
		DOM_VK_OPEN_CURLY_BRACKET  : 174,
		DOM_VK_CLOSE_CURLY_BRACKET : 175,
		DOM_VK_TILDE               : 176,
		DOM_VK_VOLUME_MUTE         : 181,
		DOM_VK_VOLUME_DOWN         : 182,
		DOM_VK_VOLUME_UP           : 183,
		DOM_VK_COMMA               : 188,
		DOM_VK_PERIOD              : 190,
		DOM_VK_SLASH               : 191,
		DOM_VK_BACK_QUOTE          : 192,
		DOM_VK_OPEN_BRACKET        : 219,
		DOM_VK_BACK_SLASH          : 220,
		DOM_VK_CLOSE_BRACKET       : 221,
		DOM_VK_QUOTE               : 222,
		DOM_VK_META                : 224,
		DOM_VK_ALTGR               : 225,
		DOM_VK_WIN_ICO_HELP        : 227,
		DOM_VK_WIN_ICO_00          : 228,
		DOM_VK_WIN_ICO_CLEAR       : 230,
		DOM_VK_WIN_OEM_RESET       : 233,
		DOM_VK_WIN_OEM_JUMP        : 234,
		DOM_VK_WIN_OEM_PA1         : 235,
		DOM_VK_WIN_OEM_PA2         : 236,
		DOM_VK_WIN_OEM_PA3         : 237,
		DOM_VK_WIN_OEM_WSCTRL      : 238,
		DOM_VK_WIN_OEM_CUSEL       : 239,
		DOM_VK_WIN_OEM_ATTN        : 240,
		DOM_VK_WIN_OEM_FINISH      : 241,
		DOM_VK_WIN_OEM_COPY        : 242,
		DOM_VK_WIN_OEM_AUTO        : 243,
		DOM_VK_WIN_OEM_ENLW        : 244,
		DOM_VK_WIN_OEM_BACKTAB     : 245,
		DOM_VK_ATTN                : 246,
		DOM_VK_CRSEL               : 247,
		DOM_VK_EXSEL               : 248,
		DOM_VK_EREOF               : 249,
		DOM_VK_PLAY                : 250,
		DOM_VK_ZOOM                : 251,
		DOM_VK_PA1                 : 253,
		DOM_VK_WIN_OEM_CLEAR       : 254
	};

	var KeyEventNames = [];
	var keyStatus = [];

	var handleKeyPress = function(key) {

		if (keyStatus[key.which] === "released") {

			console.log("keyboard.handleKeyPress " + KeyEventNames[key.which]);
			keyStatus[key.which] = "pressed";

			callback(
				"sender keyboard "
				+ "receiver game_presentation_keyboard "
				+ "summary {key pressed} "
				+ "details {name " + KeyEventNames[key.which] + " {}}"
			);
		}
	};

	var handleKeyRelease = function(key) {

		if (keyStatus[key.which] === "pressed") {

			console.log("keyboard.handleKeyRelease " + KeyEventNames[key.which]);
			keyStatus[key.which] = "released";

			callback(
				"sender keyboard "
				+ "receiver game_presentation_keyboard "
				+ "summary {key released} "
				+ "details {name " + KeyEventNames[key.which] + " {}}"
			);
		}
	};

	(function initialize() {

		console.log("keyboard.initialize");

		Object.getOwnPropertyNames(KeyEvent).forEach(
			function(keyName){
				keyStatus[KeyEvent[keyName]] = "released";
				KeyEventNames[KeyEvent[keyName]] = keyName;
			}
		);

		window.addEventListener('keydown', handleKeyPress);
		window.addEventListener('keyup', handleKeyRelease);

	}());

	var callback;

	var keyboard_module = {};

	keyboard_module.registerCallback = function(_callback) {

		callback = _callback;
	};

	keyboard_module.keyNames = function() {

		return Object.getOwnPropertyNames(KeyEvent);
	};

	return keyboard_module;

}());

/*
For propagating the Keyboard Events to the top level container
if(window.top == window.self) {
    // Top level window
} else {
    // Not top level. An iframe, popup or something
}
*/
