#include "includes.inc"
params ["_unit", "_reward", ["_customText", ""], ["_customColor", "#de0808"], ["_unitTypeName", ""]];

if (isDedicated) exitWith {};

disableSerialization;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

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

	private _useNewKillfeed = _settingsMap getOrDefault ["useNewKillfeed", true];
	if (_unitType isKindOf "Man") then {
		_displayText = if (_useNewKillfeed) then {
			"Kill"
		} else {
			"Enemy killed"
		};
	} else {
		_displayName = [_unit, _unitType] call WL2_fnc_getAssetTypeName;
		_displayText = if (_useNewKillfeed) then {
			"%1"
		} else {
			"%1 destroyed"
		};
	};
	_displayText = format [_displayText, _displayName];
};

[_customText, _unitType] call WLT_fnc_killRewardTaskHandle;

// map: displayText => [repetition, points, customColor, timestamp]
private _killRewardMap = uiNamespace getVariable ["WL_killRewardMap", createHashMap];
private _killRewardEntry = _killRewardMap getOrDefault [_displayText, [0, 0, "", 0]];
private _repetitions = _killRewardEntry # 0;
private _points = _killRewardEntry # 1;

_repetitions = _repetitions + 1;
_points = _points + _reward;
_killRewardMap set [_displayText, [_repetitions, _points, _customColor, serverTime]];

uiNamespace setVariable ["WL_killRewardMap", _killRewardMap];
[_displayText, _reward, _customColor] call WL2_fnc_updateKillFeed;

if (_customColor == "#de0808") then {
	missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_DURATION_AFKTIME];

	private _rewardHistory = uiNamespace getVariable ["WL2_rewardHistory", createHashMap];
	private _rewardEntry = _rewardHistory getOrDefault [_displayText, [0, 0]];
	_rewardEntry set [0, _rewardEntry # 0 + 1];
	_rewardEntry set [1, _rewardEntry # 1 + _reward];
	_rewardHistory set [_displayText, _rewardEntry];
	uiNamespace setVariable ["WL2_rewardHistory", _rewardHistory];

	private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];

	private _useNewKillSound = _settingsMap getOrDefault ["useNewKillSound", true];
	if (_useNewKillSound) then {
		playSoundUI ["hitmarker", _hitmarkerVolume * 2, 1];
	} else {
		playSoundUI ["AddItemOk", _hitmarkerVolume * 2, 1];
	};

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