params ["_asset", "_draw"];

if (!_draw) exitWith {""};

private _text = "";
private _vehicleDisplayName = [_asset] call WL2_fnc_getAssetTypeName;
private _assetOwnerName = [_asset] call WL2_fnc_getAssetOwnerName;

private _ammo = _asset getVariable ["WLM_ammoCargo", 0];
if (_ammo > 0) exitWith {
	private _ammoDisplay = (_ammo call BIS_fnc_numberText) regexReplace [" ", ","];
	format ["%1 [%2 kg]", _vehicleDisplayName, _ammoDisplay];
};

format ["%1 %2", _vehicleDisplayName, _assetOwnerName];