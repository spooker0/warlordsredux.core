#include "..\..\warlords_constants.inc"

params ["_unit", "_reward", ["_customText", ""], ["_customColor", "#de0808"], ["_unitTypeName", ""]];

if (isDedicated) exitWith {};

disableSerialization;

private _displayText = "";
private _displayName = "";

private _side = BIS_WL_playerSide;

private _unitType = typeOf _unit;
if (_customText != "") then {
	_displayText = format ["%1", _customText];
} else {
	if (_unitType == "") then {
		_unitType = _unitTypeName;
	};

	if (_unitType isKindOf "Man") then {
		_displayText = "Enemy killed";
	} else {
		_displayName = [_unit, _unitType] call WL2_fnc_getAssetTypeName;
		_displayText = "%1 destroyed";
	};
	_displayText = format [_displayText, _displayName];
};

[_customText, _unitType] call WLT_fnc_killRewardTaskHandle;

// map: displayText => [repetition, points, customColor, timestamp]
private _killRewardMap = uiNamespace getVariable ["WL_killRewardMap", createHashMap];
private _killRewardEntry = _killRewardMap getOrDefault [_displayText, [0, 0, "", 0]];
private _repetitions = _killRewardEntry # 0;
private _points = _killRewardEntry # 1;
_killRewardMap set [_displayText, [_repetitions + 1, _points + _reward, _customColor, serverTime]];

uiNamespace setVariable ["WL_killRewardMap", _killRewardMap];
[_killRewardMap] call WL2_fnc_updateKillFeed;

if (_customColor == "#de0808") then {
	missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_AFK_TIMER];

	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
	playSoundUI ["hitmarker", _hitmarkerVolume * 2, 1];

	if (missionNamespace getVariable ["WL_easterEggOverride", false]) then {
		private _killsInRow = missionNamespace getVariable ["WL_killsInRow", 0];
		_killsInRow = _killsInRow + 1;
		[_killsInRow] call KST_fnc_actions;
		missionNamespace setVariable ["WL_killsInRow", _killsInRow];
	};
};

// WLC
private _newScore = (["getScore"] call WLC_fnc_getLevelInfo) + _reward;
[_newScore] call WLC_fnc_setScore;