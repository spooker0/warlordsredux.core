#include "includes.inc"
params ["_asset", "_caller", "_slingloading", "_actionId"];
if (!alive _asset) exitWith {
    [false, [], [0, 0, 0]];
};

private _isLoading = _asset getVariable ["WL2_loadingAsset", false];
if (_isLoading) exitWith {
    [false, [], [0, 0, 0]];
};

private _isPointing = cursorObject == _asset || _slingloading || (_asset isKindOf "Air");
if (!_isPointing) exitWith {
    [false, [], [0, 0, 0]];
};

private _hasAccess = ([_asset, _caller, "full"] call WL2_fnc_accessControl) # 0;
if (!_hasAccess) exitWith {
    [false, [], [0, 0, 0]];
};

private _callerID = getPlayerID _caller;
private _loadedItem = _asset getVariable ["WL2_loadedItem", objNull];
private _loadedVehicles = getVehicleCargo _asset;
private _slingLoadedVehicle = getSlingLoad _asset;
private _hasLoadedItem = !isNull _loadedItem || count _loadedVehicles > 0 || !isNull _slingLoadedVehicle;

private _nearLoadableEntities = (_asset nearObjects 30) select {
    (isNull attachedTo _x) && (count ropesAttachedTo _x == 0) && _asset != _x;
} select {
    if (_slingloading) then {
        true
    } else {
        alive _x != (_x isKindOf "Air")
    };
};

private _assetData = WL_ASSET_DATA;
private _nearLoadable = _nearLoadableEntities select {
    if (alive _x) then {
        private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
        private _access = [_x, _caller, "full"] call WL2_fnc_accessControl;
        private _loadable = WL_ASSET_FIELD(_assetData, _assetActualType, "loadable", []);
        if (typeof _asset == "I_Heli_Transport_02_F") then {
            private _cost = WL_ASSET_FIELD(_assetData, _assetActualType, "cost", -1);
            _x != _asset && _access # 0 && _cost >= 0 && !(_x isKindOf "Man")
        } else {
            count _loadable > 0 && _access # 0;
        };
    } else {
        !(_x isKindOf "Man");
    };
};
private _hasNearLoadable = count _nearLoadable > 0;

private _sortedNearLoadable = if (_hasNearLoadable) then {
    [_nearLoadable, [_asset], {
        _input0 distance _x;
    }, "ASCEND"] call BIS_fnc_sortBy;
} else {
    [];
};

private _offset = if (_hasNearLoadable) then {
    private _loadable = _sortedNearLoadable # 0;
    private _loadableType = _loadable getVariable ["WL2_orderedClass", typeOf _loadable];
    private _defaultArray = [0, 0, 1];
    WL_ASSET_FIELD(_assetData, _loadableType, "loadable", _defaultArray);
} else {
    [0, 0, 1];
};

private _actionText = if (!isNull _loadedItem) then {
    private _loadableType = [_loadedItem] call WL2_fnc_getAssetTypeName;
    format ["Unload %1", _loadableType];
} else {
    if (count _sortedNearLoadable == 0) then {
        "Load deployable";
    } else {
        private _loadableType = [_sortedNearLoadable # 0] call WL2_fnc_getAssetTypeName;
        format ["Load %1", _loadableType];
    };
};

private _actionIcon = if (!isNull _loadedItem) then {
    '\A3\ui_f\data\map\markers\handdrawn\end_CA.paa'
} else {
    '\A3\ui_f\data\map\markers\handdrawn\start_CA.paa'
};

_asset setUserActionText [_actionId, _actionText, format ["<img size='3' image='%1'/>", _actionIcon]];

// 0: eligible
// 1: near loadables
// 2: offset
[_hasLoadedItem || _hasNearLoadable, _sortedNearLoadable, _offset];