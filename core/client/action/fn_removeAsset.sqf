#include "includes.inc"
params ["_asset", ["_skipChecks", false]];

private _canRemoveAsset = {
    if (_skipChecks) exitWith {
        "ok";
    };

    if (WL_ISDOWN(player)) exitWith {
        "You are incapacitated!";
    };

    private _access = [_asset, player, "full"] call WL2_fnc_accessControl;
    private _hasFullAccess = _access # 0;
    if (!_hasFullAccess) exitWith {
        format ["Can't remove: %1", _access # 1];
    };

    if (alive _asset && _asset isKindOf "Air" && speed _asset > 5 && !(unitIsUAV _asset)) exitWith {
        "Can't remove flying aircraft!";
    };

    "ok";
};

private _callResult = call _canRemoveAsset;
if (_callResult != "ok") exitWith {
    playSoundUI ["AddItemFailed", 1];
    [_callResult] call WL2_fnc_smoothText;
};

private _isBulkRemoveActive = missionNamespace getVariable ["WL2_bulkRemoveActive", false];
if (_isBulkRemoveActive) then {
    private _assetActualType = WL_ASSET_TYPE(_asset);

    private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
    private _sameTypeVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
    _sameTypeVehicles = _sameTypeVehicles select {
        _assetActualType == WL_ASSET_TYPE(_x);
    };

    private _displayName = [_asset] call WL2_fnc_getAssetTypeName;
    private _result = [
        "Bulk remove assets",
        format ["Are you sure you would like to DELETE ALL %1? This will remove %2 assets!", _displayName, count _sameTypeVehicles],
        "Yes", "Cancel"
    ] call WL2_fnc_prompt;

    if (_result) then {
        {
            [_x, true] spawn WL2_fnc_removeAsset;
        } forEach _sameTypeVehicles;

        private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
        _ownedVehicles = _ownedVehicles select {
            alive _x
        };
        missionNamespace setVariable [_ownedVehiclesVar, _ownedVehicles, true];

        private _texture = _asset getVariable ["WL2_vehicleManagerTexture", controlNull];
        if (!isNull _texture) then {
            [_texture] call WL2_fnc_sendVehicleData;
        };

        playSoundUI ["AddItemOK", 1];
        [format ["All %1 deleted!", _displayName]] call WL2_fnc_smoothText;
    } else {
        playSoundUI ["AddItemFailed", 1];
    };

    missionNamespace setVariable ["WL2_bulkRemoveActive", false];
} else {
    private _displayName = [_asset] call WL2_fnc_getAssetTypeName;

    private _result = if (_skipChecks) then {
        true
    } else {
        ["Delete asset", format ["Are you sure you would like to delete: %1?", _displayName], "Yes", "Cancel"] call WL2_fnc_prompt;
    };

    if (_result) then {
        private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
        private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
        _ownedVehicles = _ownedVehicles select { _x != _asset };
        missionNamespace setVariable [_ownedVehiclesVar, _ownedVehicles, true];

        if (_asset == (getConnectedUAV player)) then {
            player connectTerminalToUAV objNull;
        };

        if (unitIsUAV _asset) then {
            private _grp = group effectiveCommander _asset;
            {_asset deleteVehicleCrew _x} forEach crew _asset;
            deleteGroup _grp;
        };

        deleteVehicle _asset;

        if (!_skipChecks) then {
            private _texture = _asset getVariable ["WL2_vehicleManagerTexture", controlNull];
            if (!isNull _texture) then {
                [_texture] call WL2_fnc_sendVehicleData;
            };

            playSoundUI ["AddItemOK", 1];
            [format [localize "STR_WL_assetDeleted", _displayName]] call WL2_fnc_smoothText;
        };
    } else {
        playSoundUI ["AddItemFailed", 1];
    };
};