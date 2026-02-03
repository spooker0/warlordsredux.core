#include "includes.inc"
params ["_class", "_cost", "_category", "_requirements", "_offset"];

"RequestMenu_close" call WL2_fnc_setupUI;

if (_category == "Naval") exitWith {
	[_class, _cost] spawn WL2_fnc_orderNaval;
};

private _isPlane = "A" in _requirements;

private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _upgradedForwardBases = _potentialBases select {
    player distance2D _x < WL_FOB_RANGE
} select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
} select {
	private _defenseLevel = _x getVariable ["WL2_forwardBaseDefenseLevel", 0];
	_defenseLevel > 3
};

if (_isPlane && count _upgradedForwardBases == 0) then {
	[_class, _cost, _requirements] spawn WL2_fnc_orderAircraft;
} else {
	[_class, _cost, _offset] spawn WL2_fnc_orderVehicle;
};