#include "includes.inc"
params ["_display"];
if (isNull _display) exitWith {};

private _targetData = [];

{
    private _vehicle = _x;
    if (isNull _vehicle) then {
        continue;
    };

    private _hideMap = _vehicle getVariable ["WL2_hideMap", 0];
    if (_hideMap > 0) then {
        continue;
    };

    private _vehicleName = [_vehicle] call WL2_fnc_getAssetTypeShortName;
    private _ownerUid = _vehicle getVariable ["BIS_WL_ownerAsset", ""];
    private _owner = _ownerUid call BIS_fnc_getUnitByUid;
    private _ownerName = if (isNull _owner) then { "???" } else { name _owner };

    _targetData pushBack ["BLUFOR", _vehicleName, _ownerName, _vehicle, getObjectID _vehicle];
} forEach BIS_WL_westOwnedVehicles;

{
    private _vehicle = _x;
    if (isNull _vehicle) then {
        continue;
    };

    private _hideMap = _vehicle getVariable ["WL2_hideMap", 0];
    if (_hideMap > 0) then {
        continue;
    };

    private _vehicleName = [_vehicle] call WL2_fnc_getAssetTypeShortName;
    private _ownerUid = _vehicle getVariable ["BIS_WL_ownerAsset", ""];
    private _owner = _ownerUid call BIS_fnc_getUnitByUid;
    private _ownerName = if (isNull _owner) then { "???" } else { name _owner };

    _targetData pushBack ["OPFOR", _vehicleName, _ownerName, _vehicle, getObjectID _vehicle];
} forEach BIS_WL_eastOwnedVehicles;

{
    private _vehicle = _x;
    if (isNull _vehicle) then {
        continue;
    };

    private _hideMap = _vehicle getVariable ["WL2_hideMap", 0];
    if (_hideMap > 0) then {
        continue;
    };

    private _vehicleName = [_vehicle] call WL2_fnc_getAssetTypeShortName;
    _targetData pushBack ["INDFOR", _vehicleName, "AI", _vehicle, getObjectID _vehicle];
} forEach BIS_WL_guerOwnedVehicles;

private _munitionBaseClasses = ["MissileCore", "RocketCore", "BombCore", "ShellCore", "SubmunitionCore"];
private _munitions = (8 allObjects 2) select {
    private _munition = _x;
    _munitionBaseClasses findIf { _munition isKindOf _x } != -1
};

{
    private _munition = _x;
    if (isNull _munition) then {
        continue;
    };

    private _munitionType = typeOf _munition;
    private _shotParents = getShotParents _munition;
    private _launchVehicle = _shotParents # 0;
    private _instigator = _shotParents call WL2_fnc_handleInstigator;

    private _launchVehicleName = if (isNull _launchVehicle) then {
        "Unknown launcher"
    } else {
        [_launchVehicle] call WL2_fnc_getAssetTypeShortName
    };

    private _ownerName = if (isNull _instigator) then { "Unknown" } else { name _instigator };
    private _launchDescription = format ["%1 (%2)", _launchVehicleName, _ownerName];
    _targetData pushBack ["MUNITION", _munitionType, _launchDescription, _munition, getObjectID _munition];
} forEach _munitions;

_targetData = [_targetData, [], {
    private _categoryOrder = switch (_x # 0) do {
        case "BLUFOR": { 0 };
        case "OPFOR": { 1 };
        case "INDFOR": { 2 };
        case "MUNITION": { 3 };
        default { 4 };
    };
    format ["%1_%2_%3", _categoryOrder, toLower (_x # 1), toLower (_x # 2)]
}, "ASCEND"] call BIS_fnc_sortBy;

private _signatureData = [];

{
    _x params ["_category", "_primaryText", "_secondaryText", "_tertiaryText", "_objectId"];
    _signatureData pushBack [_category, _primaryText, _secondaryText, _objectId];
} forEach _targetData;

private _newSignature = str _signatureData;
private _oldSignature = _display getVariable ["SPEC_targetDataSignature", ""];
if (_newSignature == _oldSignature) exitWith {};

_display setVariable ["SPEC_targetDataSignature", _newSignature];
_display setVariable ["SPEC_targetData", _targetData];

[_display] call SPEC_fnc_spectatorTargetMenuRebuild;