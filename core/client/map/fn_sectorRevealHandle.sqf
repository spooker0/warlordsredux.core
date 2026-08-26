#include "includes.inc"
params ["_sector", ["_side", sideUnknown]];

if (isDedicated) exitWith {};
if (isNull _sector) exitWith {};

private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];
if (_side in _revealedBy || _side == sideUnknown) then {
	[_sector, _sector getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;

	private _sectorMarkerVar = format ["WL2_MapMarker_%1", _side];
	private _sectorMarker = _sector getVariable [_sectorMarkerVar, "unknown"];
	if !(_sectorMarker in ["camped", "unknown"]) then {
		_sector setVariable [_sectorMarkerVar, "unknown", true];
	};
};