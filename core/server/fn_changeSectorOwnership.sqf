#include "includes.inc"
params ["_sector", "_owner"];

_sector setVariable ["BIS_WL_owner", _owner, true];
[_sector] remoteExec ["WL2_fnc_sectorOwnershipHandleClient", [0, -2] select isDedicated];

private _previousOwners = _sector getVariable "BIS_WL_previousOwners";
private _isNeutralSector = count _previousOwners == 0;
if !(_owner in _previousOwners) then {
	_previousOwners pushBack _owner;
	if (serverTime > 0 && {count _previousOwners == 1}) then {
		private _relevantNeighbors = (synchronizedObjects _sector) select {(_x getVariable "BIS_WL_owner") == _owner};
		private _neighborList = _relevantNeighbors apply {[_x distance2D _sector, _x]};
		_neighborList sort true;
		if (count _neighborList > 0) then {
			private _closestNeighborDistance = (_neighborList # 0) # 0;
			private _reward = ((round (_closestNeighborDistance / 3)) min 1000) max 100;
			{
				private _uid = getPlayerUID _x;
				[_reward, _uid] call WL2_fnc_fundsDatabaseWrite;
				[objNull, _reward, "Sector captured", "#228b22"] remoteExec ["WL2_fnc_killRewardClient", _x];
			} forEach (allPlayers select {
				side group _x == _owner
			});
		};
	};
};

_previousOwners pushBackUnique _owner;
_sector setVariable ["BIS_WL_previousOwners", _previousOwners, true];
_sector setVariable ["WL_fortificationTime", serverTime + WL_FORTIFICATION_TIME, true];
_sector setVariable ["WL_strongholdFortified", false, true];

if (_sector == (missionNamespace getVariable format ["BIS_WL_currentTarget_%1", _owner])) then {
	missionNamespace setVariable [format ["BIS_WL_currentTarget_%1", _owner], objNull, true];
};

["server", true] call WL2_fnc_updateSectorArrays;
call WL2_fnc_calcImbalance;

_side = [west, east];
_side deleteAt (_side find _owner);
private _enemySide = _side # 0;
if (isNull (missionNamespace getVariable format ["BIS_WL_currentTarget_%1", _enemySide]) && !_isNeutralSector) then {
	missionNamespace setVariable [format ["BIS_WL_resetTargetSelection_server_%1", _enemySide], true];
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
	[_gameWinner, false] remoteExec ["WL2_fnc_missionEndHandle", 0];
};