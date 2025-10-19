#include "includes.inc"
params ["_side", "_sector"];

if (isNull _sector) exitWith {};

private _sectorsInPlay = missionNamespace getVariable ["WL2_sectorsInPlay", []];
_sectorsInPlay pushBackUnique _sector;
missionNamespace setVariable ["WL2_sectorsInPlay", _sectorsInPlay];

private _prevSector = missionNamespace getVariable format ["BIS_WL_currentTarget_%1", _side];
missionNamespace setVariable [format ["BIS_WL_currentTarget_%1", _side], _sector, true];

private _isHomeBase = _sector in WL_BASES;
if (!_isHomeBase) then {
	private _owner = _sector getVariable ["BIS_WL_owner", sideUnknown];
	private _enemySector = missionNamespace getVariable format ["BIS_WL_currentTarget_%1", ([west, east] select {_x != _side}) # 0];
	if (_owner == resistance && _sector != _enemySector && _prevSector != _sector) then {
		private _isCarrierSector = _sector getVariable ["WL2_isAircraftCarrier", false];
		if (_isCarrierSector) then {
			[_sector] spawn WL2_fnc_populateCarrierSector;
		} else {
			[_sector, _owner] spawn WL2_fnc_populateSector;
		};
	};
};