#include "includes.inc"
params ["_vehicle", "_mapIconCache"];

if (lifeState _vehicle == "INCAPACITATED") exitWith {
	"a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa";
};

private _iconFromCache = _mapIconCache getOrDefault [typeof _vehicle, ""];
if (_iconFromCache != "") exitWith {
	_iconFromCache;
};

private _vehicleIcon = if ([_vehicle] call WL2_fnc_isScannerMunition) then {
	"\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa";
} else {
	getText (configFile >> 'CfgVehicles' >> typeOf (vehicle _vehicle) >> 'icon');
};

_mapIconCache set [typeof _vehicle, _vehicleIcon];
_vehicleIcon;