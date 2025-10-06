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
			"KILL"
		} else {
			"Enemy killed"
		};
	} else {
		_displayName = [_unit, _unitType] call WL2_fnc_getAssetTypeName;
		_displayText = if (_useNewKillfeed) then {
			"DESTROYED %1"
		} else {
			"%1 destroyed"
		};
	};
	_displayText = format [_displayText, _displayName];
};

// map: displayText => [repetition, points, customColor, timestamp]
private _killRewardMap = uiNamespace getVariable ["WL_killRewardMap", createHashMap];
private _killRewardEntry = _killRewardMap getOrDefault [_displayText, [0, 0, "", 0]];
private _repetitions = _killRewardEntry # 0;
private _points = _killRewardEntry # 1;

_repetitions = _repetitions + 1;
_points = _points + _reward;
_killRewardMap set [_displayText, [_repetitions, _points, _customColor, serverTime]];

uiNamespace setVariable ["WL_killRewardMap", _killRewardMap];

private _displayIcon = switch (toUpper _displayText) do {
	case "KILL";
	case "PLAYER KILL": { "a3\\Ui_F_Curator\\Data\\CfgMarkers\\kia_ca.paa" };
	case "ATTACKING SECTOR";
	case "DESTROYED STRONGHOLD": { "a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\attack_ca.paa" };
	case "DEFENDING SECTOR": { "a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\defend_ca.paa" };
	case "ACTIVE PROTECTION SYSTEM";
	case "DAZZLER";
	case "PROJECTILE JAMMED";
	case "PROJECTILE DESTROYED": { "A3\\ui_f\\data\\map\\markers\\military\\pickup_CA.paa" };
	case "SECTOR CAPTURED": { "A3\\ui_f\\data\\map\\markers\\handdrawn\\flag_CA.paa" };
	case "REVIVED TEAMMATE": { "a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\Heal_ca.paa" };
	case "RECON";
	case "SPOT ASSIST": { "a3\\ui_f\\data\\gui\\rsc\\rscdisplayarsenal\\binoculars_ca.paa" };
	case "SPAWN REWARD": { "a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\car_ca.paa" };
	case "SQUAD ASSIST": { "a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\meet_ca.paa" };
	default {
		private _unitIcon = getText (configFile >> "CfgVehicles" >> _unitType >> "picture");
		if (_unitIcon in ["pictureThing", "pictureStaticObject"]) then {
			"a3\\ui_f\\data\\map\\vehicleicons\\iconcratesupp_ca.paa";
		} else {
			(_unitIcon regexReplace ["\\", "\\\\"]) regexReplace ["^\\", ""];
		};
	};
};
[_displayText, _reward, _customColor, _displayIcon] call WL2_fnc_updateKillFeed;

[_displayText, _unitType, _reward] call RWD_fnc_handleReward;

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

// Total rewards tracker
private _totalRewards = missionNamespace getVariable ["WL2_totalRewards", 0];
_totalRewards = _totalRewards + _reward;
private _alreadyHasBadge = missionNamespace getVariable ["WL2_hasJohnWarlordsBadge", false];
if (_totalRewards > 100000 && !_alreadyHasBadge) then {
	["John Warlords"] call RWD_fnc_addBadge;
	missionNamespace setVariable ["WL2_hasJohnWarlordsBadge", true];
};
missionNamespace setVariable ["WL2_totalRewards", _totalRewards];