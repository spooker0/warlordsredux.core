#include "..\warlords_constants.inc"

params ["_side", ["_fullRecalc", false]];

private _base = objNull;
private _pool = BIS_WL_allSectors;
private _owned = _pool select {
	(_x getVariable ["BIS_WL_owner", sideUnknown]) == _side
};

private _available = [];
private _income = 0;
private _services = [];
private _curTarget = missionNamespace getVariable [format ["BIS_WL_currentTarget_%1", _side], objNull];
private _unlocked = _pool select {_x == _curTarget || {_side in (_x getVariable ["BIS_WL_previousOwners", []])}};
private _baseArr = WL_BASES select {(_x getVariable ["BIS_WL_owner", sideUnknown]) == _side};

{
	private _sector = _x;
	_income = _income + (_sector getVariable ["BIS_WL_value", 0]);
	{
		_services pushBackUnique _x;
	} forEach (_sector getVariable ["WL2_services", []]);
} forEach _owned;

if (_side == independent) exitWith {
	[_owned, _owned, _owned, _owned, _income, _services, [], []];
};

if (count _baseArr == 0) exitWith {
	[_owned, [], [], _unlocked, _income, _services, [], []]
};

private _base = _baseArr # 0;
private _knots = [_base];
private _linked = _knots;

while {count _knots > 0} do {
	private _knotsCurrent = _knots;
	_knots = [];
	{
		{
			private _link = _x;
			if (!(_link in _linked) && (_link in _owned)) then {
				_linked pushBack _link;
				_knots pushBack _link;
			};
		} forEach (_x getVariable ["WL2_connectedSectors", []]);
	} forEach _knotsCurrent;
	sleep 0.0001;
};

{
	private _sector = _x;
	if ((_sector getVariable ["BIS_WL_owner", sideUnknown]) != _side && _linked findIf {_sector in (_x getVariable ["WL2_connectedSectors", []])} >= 0) then {
		_available pushBack _sector;
	};
	if (_sector getVariable ["WL2_name", "Sector"] == "Wait") then {
		_available pushBack _sector;
	};
} forEach (_pool - _owned);

[_owned, _available, _linked, _unlocked, _income, _services, _owned - _linked, (_unlocked - _owned) - _available];