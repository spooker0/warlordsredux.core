#include "includes.inc"
params ["_target", ["_texture", controlNull]];

private _displayName = [_target] call WL2_fnc_getAssetTypeName;
private _assetSector = BIS_WL_allSectors select { _target inArea (_x getVariable "objectAreaComplete") };
private _assetLocation = if (count _assetSector > 0) then {
	(_assetSector # 0) getVariable ["WL2_name", str (mapGridPosition _target)];
} else {
	mapGridPosition _target;
};

private _isBulkRemoveActive = missionNamespace getVariable ["WL2_bulkRemoveActive", false];
private _result = if (_isBulkRemoveActive) then {
	true
} else {
	["Delete asset", format ["Are you sure you would like to delete: %1 @ %2", _displayName, _assetLocation], "Yes", "Cancel"] call WL2_fnc_prompt;
};

if (_result) then {
	private _access = [_target, player, "full"] call WL2_fnc_accessControl;
	if !(_access # 0) exitWith {
		[format ["Cannot remove: %1", _access # 1]] call WL2_fnc_smoothText;
		playSound "AddItemFailed";
	};

	if (WL_ISDOWN(player)) exitWith {
		["You are dead!"] call WL2_fnc_smoothText;
		playSound "AddItemFailed";
	};

	if (alive _target && _target isKindOf "Air" && speed _target > 5 && !(unitIsUAV _target)) exitWith {
		["Can't remove flying aircraft!"] call WL2_fnc_smoothText;
		playSound "AddItemFailed";
	};

	playSound "AddItemOK";
	[format [localize "STR_WL_assetDeleted", _displayName]] call WL2_fnc_smoothText;
	_vehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
	_vehicles deleteAt (_vehicles find _target);
	missionNamespace setVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], _vehicles, true];

	if (_target == (getConnectedUAV player)) then {
		player connectTerminalToUAV objNull;
	};

	if (unitIsUAV _target) then {
		private _grp = group effectiveCommander _target;
		{_target deleteVehicleCrew _x} forEach crew _target;
		deleteGroup _grp;
	};

	deleteVehicle _target;

	if (!isNull _texture) then {
		[_texture] call WL2_fnc_sendVehicleData;
	};
} else {
	playSound "AddItemFailed";
};