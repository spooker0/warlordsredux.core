#include "includes.inc"
params [
	["_text", "", [""]],
	["_maxLines", 3, [0]],
	["_onScreenDuration", 5, [0]],
	["_color", [1, 1, 1, 1], [[]], 4],
	["_shadow", true, [true]]
];

addMissionEventHandler ["Loaded", {
	BIS_onScreenMessageID = 0;
	BIS_onScreenMessagesBuffer = [];
	{
		ctrlDelete ((findDisplay 46) displayCtrl (9990000 + _x));
	} forEach BIS_onScreenMessagesVisible;
	BIS_onScreenMessagesVisible = [];
}];

disableSerialization;

if (isNil "BIS_onScreenMessageID") then {
	BIS_onScreenMessageID = 0;
	BIS_onScreenMessagesVisible = [];
	BIS_onScreenMessagesBuffer = [];
};

waitUntil {!isNull (findDisplay 46)};
_myDisplay = (findDisplay 46);

_box = _myDisplay ctrlCreate ["RscStructuredText", 9990000 + BIS_onScreenMessageID];
_messageID = BIS_onScreenMessageID;
BIS_onScreenMessageID = BIS_onScreenMessageID + 1;

if (BIS_onScreenMessageID > 1000) then {
	BIS_onScreenMessageID = 0;
};

_xDef = safezoneX;
_yDef = safezoneY;
_wDef = safezoneW;
_hDef = safezoneH;

if (count BIS_onScreenMessagesVisible >= _maxLines) then {
	BIS_onScreenMessagesBuffer pushBack _messageID;
	waitUntil {count BIS_onScreenMessagesVisible < _maxLines && (BIS_onScreenMessagesBuffer find _messageID) == 0};
	BIS_onScreenMessagesBuffer = BIS_onScreenMessagesBuffer - [_messageID];
};

BIS_onScreenMessagesVisible pushBack _messageID;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _announcerTextSize = _settingsMap getOrDefault ["announcerTextSize", 1];
_announcerTextSize = linearConversion [0.1, 1, _announcerTextSize, 0.5, 1, true];
private _boxHeight = _hDef * (_announcerTextSize / (25 call WL2_fnc_purchaseMenuGetUIScale));

if (count BIS_onScreenMessagesVisible > 1) then {
	{
		private _ctrlID = 9990000 + _x;
		private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
		waitUntil {
			ctrlCommitted _ctrl || ctrlFade _ctrl > 0
		};

		private _boxPositionY = ((ctrlPosition _ctrl) # 1) + _boxHeight;
		_ctrl ctrlSetPosition [_xDef, _boxPositionY, _wDef, _boxHeight];
		_ctrl ctrlCommit 0.25;
	} forEach (BIS_onScreenMessagesVisible - [_messageID]);
};

private _boxPositionY = _yDef + _boxHeight;

_box ctrlSetPosition [_xDef, _boxPositionY, _wDef, _boxHeight];
_box ctrlSetBackgroundColor [0, 0, 0, 0];
_box ctrlSetTextColor _color;
_box ctrlSetFontHeight _boxHeight;
_box ctrlCommit 0;

_textArr = toArray _text;
_charsCnt = count _text;
_textStructured = "";
_finalAlpha = _color # 3;
_baseColor = [_color # 0, _color # 1, _color # 2, 0];
_baseColorHTML = _baseColor call BIS_fnc_colorRGBAtoHTML;
_colorArr = [];
_popupDelay = 0.025;
_fadeDuration = 0.5;
_shadow = if (_shadow) then {2} else {0};

{
	_textStructured = _textStructured + "<t color = '%" + str (_forEachIndex + 1) + "'>" + toString [_x] + "</t>";
	_colorArr pushBack _baseColorHTML;
} forEach _textArr;

_textStructured = "<t size = '" + str ((1.01 call WL2_fnc_purchaseMenuGetUIScale)) + "' align = 'center' shadow = '" + (str _shadow) + "'>" + _textStructured + "</t>";
_textStructuredFormat = [_textStructured];

_done = false;
_startTime = time;

while {!_done} do {
	_oldTick = time;
	waitUntil {time > _oldTick + 0.04};

	_done = true;
	_newLetterColor = [];

	{
		_letterFadeInStart = _startTime + (_forEachIndex * _popupDelay);
		if (time >= _letterFadeInStart && time <= (_letterFadeInStart + _fadeDuration)) then {
			_done = false;
			_newAlpha = linearConversion [_letterFadeInStart, _letterFadeInStart + _fadeDuration, time, 0, _finalAlpha];
			_newLetterColor = +_baseColor;
			_newLetterColor set [3, _newAlpha];
			_newLetterColor = _newLetterColor call BIS_fnc_colorRGBAtoHTML;
			_colorArr set [_forEachIndex, _newLetterColor];
		} else {
			if (time > (_letterFadeInStart + _fadeDuration)) then {
				_newLetterColor = +_baseColor;
				_newLetterColor set [3, _finalAlpha];
				_newLetterColor = _newLetterColor call BIS_fnc_colorRGBAtoHTML;
				_colorArr set [_forEachIndex, _newLetterColor];
			};
		};
	} forEach _colorArr;

	_textStructuredFormat = [_textStructured];

	{
		_textStructuredFormat pushBack _x;
	} forEach _colorArr;

	_box ctrlSetStructuredText parseText format _textStructuredFormat;
};

sleep _onScreenDuration;

_box ctrlSetFade 1;
_box ctrlCommit 1;

waitUntil {ctrlCommitted _box};

BIS_onScreenMessagesVisible = BIS_onScreenMessagesVisible - [_messageID];
ctrlDelete _box;