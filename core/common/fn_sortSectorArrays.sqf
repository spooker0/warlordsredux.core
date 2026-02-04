#include "includes.inc"
params ["_side", ["_fullRecalc", false]];

private _base = objNull;
private _pool = BIS_WL_allSectors;
private _owned = _pool select {
	(_x getVariable ["BIS_WL_owner", sideUnknown]) == _side
};

private _available = [];
private _services = [];
private _curTarget = missionNamespace getVariable [format ["BIS_WL_currentTarget_%1", _side], objNull];
private _unlocked = _pool select {_x == _curTarget || {_side in (_x getVariable ["BIS_WL_previousOwners", []])}};
private _baseArr = WL_BASES select {(_x getVariable ["BIS_WL_owner", sideUnknown]) == _side};

{
	private _sector = _x;
	{
		_services pushBackUnique _x;
	} forEach (_sector getVariable ["WL2_services", []]);
} forEach _owned;

if (_side == independent) exitWith {
	[_owned, _owned, _owned, _owned, 200, _services, [], []];
};

if (count _baseArr == 0) exitWith {
	[_owned, [], [], _unlocked, 50, _services, [], []]
};

private _base = _baseArr # 0;
private _lastLinkCount = 0;
private _linked = [_base];
while { _lastLinkCount < count _linked } do {
	_lastLinkCount = count _linked;
	{
		{
			private _link = _x;
			if (_link in _owned) then {
				_linked pushBackUnique _link;
			};
		} forEach (_x getVariable ["WL2_connectedSectors", []]);
	} forEach _linked;
};

{
	private _sector = _x;
	private _wasLinkOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
	if (_wasLinkOwner != _side) then {
		_sector setVariable ["WL2_linkedOwner", _side, true];
	};
} forEach _linked;

// private _available = _pool select {
// 	_x getVariable ["BIS_WL_owner", sideUnknown] != _side
// } select {
// 	private _connections = _x getVariable ["WL2_connectedSectors", []];
// 	private _connectedToLinks = _connections arrayIntersect _linked;
// 	count _connectedToLinks > 0
// };

{
	private _sector = _x;
	if (_sector getVariable ["BIS_WL_owner", sideUnknown] == _side) then {
		continue;
	};

	private _connections = _sector getVariable ["WL2_connectedSectors", []];
	private _connectedToLinks = _connections arrayIntersect _linked;
	if (count _connectedToLinks > 0) then {
		_available pushBack _sector;
		continue;
	};

	private _sectorName = _sector getVariable ["WL2_name", "Sector"];
	if (_sectorName == "Wait") then {
		_available pushBack _sector;
	};

	if (_sectorName == "Surrender") then {
		private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
		if (_timeSinceStart > WL_SURRENDER_TIME) then {
			_available pushBack _sector;
		};
	};
} forEach _pool;

private _facesData = missionNamespace getVariable ["WL2_sectorFaces", []];
private _income = 50;
{
	_x params ["_sectorsInFace", "_area"];
	private _ownsFace = true;
	{
		private _sector = _x;
		private _sectorOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
		if (_sectorOwner != _side) then {
			_ownsFace = false;
			break;
		};
	} forEach _sectorsInFace;
	if (_ownsFace) then {
		_income = _income + _area * WL_INCOME_M2;
	};
} forEach _facesData;
_income = round _income;

[_owned, _available, _linked, _unlocked, _income, _services, _owned - _linked, (_unlocked - _owned) - _available];