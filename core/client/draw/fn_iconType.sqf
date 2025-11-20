#include "includes.inc"
params ["_vehicle", "_mapIconCache"];

if (_vehicle isKindOf "Camping_base_F") exitWith {
	"\A3\ui_f\data\map\markers\military\triangle_CA.paa";
};

if (!alive _vehicle) exitWith {
	"\a3\Ui_F_Curator\Data\CfgMarkers\kia_ca.paa";
};

if (lifeState _vehicle == "INCAPACITATED") exitWith {
	"a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa";
};

if (_vehicle getVariable ["WL_ewNetActive", false]) exitWith {
	"\a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa";
};

private _vehicleType = typeOf (vehicle _vehicle);
private _iconFromCache = _mapIconCache getOrDefault [_vehicleType, ""];
if (_iconFromCache != "") exitWith {
	_iconFromCache;
};

private _vehicleIcon = getText (configFile >> "CfgVehicles" >> _vehicleType >> "icon");

_mapIconCache set [_vehicleType, _vehicleIcon];
_vehicleIcon;