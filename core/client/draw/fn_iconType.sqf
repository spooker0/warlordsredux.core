#include "includes.inc"
params ["_vehicle", "_mapIconCache"];

if (!alive _vehicle) exitWith {
	"\a3\Ui_F_Curator\Data\CfgMarkers\kia_ca.paa";
};

if (lifeState _vehicle == "INCAPACITATED") exitWith {
	"a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa";
};

if (_vehicle getVariable ["WL_ewNetActive", false]) exitWith {
	"\a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa";
};

private _iconFromCache = _mapIconCache getOrDefault [typeof _vehicle, ""];
if (_iconFromCache != "") exitWith {
	_iconFromCache;
};

private _vehicleIcon = getText (configFile >> 'CfgVehicles' >> typeOf (vehicle _vehicle) >> 'icon');

_mapIconCache set [typeof _vehicle, _vehicleIcon];
_vehicleIcon;