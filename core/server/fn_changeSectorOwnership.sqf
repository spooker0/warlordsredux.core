#include "includes.inc"
params ["_sector", "_owner"];

private _sectorPreviousOwner = _sector getVariable ["BIS_WL_owner", independent];

_sector setVariable ["BIS_WL_owner", _owner, true];
[_sector] remoteExec ["WL2_fnc_sectorOwnershipHandleClient", [0, -2] select isDedicated];

private _capturableBySides = _sector getVariable ["WL2_capturableBySides", []];
_capturableBySides pushBackUnique _owner;

private _reward = 0;
private _facesData = missionNamespace getVariable ["WL2_sectorFaces", []];
{
	_x params ["_sectorsInFace", "_area"];
	if (_sector in _sectorsInFace) then {
		private _ownsFace = true;
		{
			private _sectorInFace = _x;
			private _sectorOwner = _sectorInFace getVariable ["BIS_WL_owner", civilian];
			if (_sectorOwner != _owner) then {
				_ownsFace = false;
				break;
			};
		} forEach _sectorsInFace;
		if (_ownsFace) then {
			private _baseIncome = round (_area * WL_INCOME_M2);
			private _faceVertices = count _sectorsInFace;
			_reward = _reward + (_baseIncome * _faceVertices * WL_INCOME_CAPBONUS);
		};
	};
} forEach _facesData;

if (_reward > 0) then {
	private _recipients = allPlayers select {
		!(_x getVariable ["WL2_afk", false])
	} select {
		side group _x == _owner
	};

	{
		private _uid = getPlayerUID _x;
		[_reward, _uid, false, "Region captured"] call WL2_fnc_fundsDatabaseWrite;
		[objNull, _reward, "Region captured", WL_COLOR_SUPPORT] remoteExec ["WL2_fnc_killRewardClient", _x];
	} forEach _recipients;
};

_sector setVariable ["WL2_capturableBySides", _capturableBySides, true];
_sector setVariable ["WL_fortificationTime", serverTime + WL_FORTIFICATION_TIME, true];

private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
_sectorStronghold setVariable ["WL2_doorsLocked", _owner, true];

if (_sector == (missionNamespace getVariable format ["BIS_WL_currentTarget_%1", _owner])) then {
	missionNamespace setVariable [format ["BIS_WL_currentTarget_%1", _owner], objNull, true];
};

call WL2_fnc_updateSectorsData;

private _enemySide = if (_owner == west) then { east } else { west };
if (_enemySide == _sectorPreviousOwner) then {
	private _enemyTarget = missionNamespace getVariable [format ["BIS_WL_currentTarget_%1", _enemySide], objNull];

	private _enemySectorsData = WL_SECTORS_DATA(_enemySide);
	private _enemyVoteableSectors = _enemySectorsData getOrDefault ["voteable", []];

	if !(_enemyTarget in _enemyVoteableSectors) then {
		private _enemyResetVar = format ["WL_targetReset_%1", _enemySide];
		missionNamespace setVariable [_enemyResetVar, true, true];
	};
};

waitUntil {
	uiSleep 0.01;
	(_sector getVariable ["BIS_WL_owner", civilian]) == _owner
};

private _base1 = missionNamespace getVariable ["WL2_base1", objNull];
private _base2 = missionNamespace getVariable ["WL2_base2", objNull];
private _base1Owner = _base1 getVariable ["BIS_WL_owner", civilian];
private _base2Owner = _base2 getVariable ["BIS_WL_owner", independent];
if (_base1Owner == _base2Owner) then {
	private _gameWinner = _base1Owner;
	[_gameWinner] spawn WL2_fnc_calculateEndResults;

	[_gameWinner, false, true] remoteExec ["WL2_fnc_missionEndHandle", 0];
	[_gameWinner, false, false] spawn WL2_fnc_missionEndHandle;
};