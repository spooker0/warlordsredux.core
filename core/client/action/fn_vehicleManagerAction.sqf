#include "includes.inc"

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _hideVehicleManager = _settingsMap getOrDefault ["hideVehicleManager", false];
if (_hideVehicleManager) exitWith {};

player addAction [
	"<t color='#FFFF00'>Vehicles</t>",
	{
        0 spawn WL2_fnc_vehicleManager;
	},
	[],
	-98,
	false,
	false,
	"",
	"alive player && lifeState player != 'INCAPACITATED' && _target == player",
	50,
	true
];