/*
	Author: MrThomasM

	Description: Updates the slider pos rel to input.
*/

params ["_control", "_slider", "_mode"];

if(isNull _control) exitWith {};
disableSerialization;

private _value = parseNumber (ctrlText _control);
private _varName = format ["MRTM_%1", _slider];

switch (_mode) do {
	case 0: {
		private _maxRange = 4000;
		if (_value <= _maxRange && _value >= 100) then {
			profileNamespace setVariable [_varName, _value];
			0 spawn MRTM_fnc_updateViewDistance;
			0 spawn MRTM_fnc_openMenu;
		};
	};
	case 1: {
		if (_value <= 2 && _value >= 0.05) then {
			profileNamespace setVariable [_varName, _value];
			0 spawn MRTM_fnc_openMenu;
		};
	};
	case 2: {
		if (_value <= 100 && _value >= 2) then {
			profileNamespace setVariable [_varName, _value];
			0 spawn MRTM_fnc_openMenu;
		};
	};
};