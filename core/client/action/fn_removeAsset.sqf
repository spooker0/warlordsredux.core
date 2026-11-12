#include "includes.inc"
params ["_asset"];

private _canRemoveAsset = {
    if (WL_ISDOWN(player)) exitWith {
        localize "STR_WL_youAreIncapacitated";
    };

    private _ownerUid = _asset getVariable ["BIS_WL_ownerAsset", "123"];
    if (getPlayerUID player != _ownerUid) exitWith {
        localize "STR_WL_cannotRemoveNotOwner";
    };

    if (alive _asset && _asset isKindOf "Air" && speed _asset > 5 && !(unitIsUAV _asset)) exitWith {
        localize "STR_WL_cannotRemoveFlying";
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
        localize "STR_WL_bulkRemoveAssets",
        format [localize "STR_WL_deleteAllConfirm", _displayName, count _sameTypeVehicles],
        localize "STR_WL_yes", localize "STR_WL_cancel"
    ] call WL2_fnc_prompt;

    if (_result) then {
        {
            deleteVehicle _x;
            uiSleep 0.5;
        } forEach _sameTypeVehicles;

        private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
        _ownedVehicles = _ownedVehicles select {
            alive _x
        };
        missionNamespace setVariable [_ownedVehiclesVar, _ownedVehicles, true];

        playSoundUI ["AddItemOK", 1];
        [format [localize "STR_WL_allAssetsDeleted", _displayName]] call WL2_fnc_smoothText;
    } else {
        playSoundUI ["AddItemFailed", 1];
    };

    missionNamespace setVariable ["WL2_bulkRemoveActive", false];
} else {
    private _displayName = [_asset] call WL2_fnc_getAssetTypeName;

    private _result = [localize "STR_WL_deleteAsset", format [localize "STR_WL_deleteAssetConfirm", _displayName], localize "STR_WL_yes", localize "STR_WL_cancel"] call WL2_fnc_prompt;

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

        playSoundUI ["AddItemOK", 1];
        [format [localize "STR_WL_assetDeleted", _displayName]] call WL2_fnc_smoothText;
    } else {
        playSoundUI ["AddItemFailed", 1];
    };
};