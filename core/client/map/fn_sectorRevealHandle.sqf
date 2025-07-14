#include "includes.inc"
params ["_sector", ["_side", sideUnknown]];

if (isDedicated) exitWith {};

if (isNull _sector) exitWith {};

private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];
if (_side in _revealedBy || _side == sideUnknown) then {
	[_sector, _sector getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
};