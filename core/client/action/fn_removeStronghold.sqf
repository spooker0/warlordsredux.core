params ["_sector", ["_replacing", false]];

playSound "AddItemOK";

private _stronghold = _sector getVariable ["WL_stronghold", objNull];

[_stronghold, false] remoteExec ["WL2_fnc_protectStronghold", 0, true];
deleteMarker (_sector getVariable ["WL_strongholdMarker", ""]);
deleteMarker (_sector getVariable ["WL_strongholdTextMarker", ""]);

if (_replacing) exitWith {};

_sector setVariable ["WL_stronghold", objNull, true];
_sector setVariable ["WL_strongholdMarker", "", true];
_sector setVariable ["WL_strongholdTextMarker", "", true];