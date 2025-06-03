params ["_vehicle"];

if (lifeState _vehicle == "INCAPACITATED") exitWith {
	"a3\ui_f\data\igui\cfg\revive\overlayIcons\u100_ca.paa";
};

private _cachedIconType = _vehicle getVariable ["WL2_iconType", ""];
if (_cachedIconType != "") exitWith {
	_cachedIconType;
};

private _icon = if ([_vehicle] call WL2_fnc_isScannerMunition) then {
	"\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa";
} else {
	getText (configFile >> 'CfgVehicles' >> typeOf (vehicle _vehicle) >> 'icon');
};
_vehicle setVariable ["WL2_iconType", _icon];
_icon;