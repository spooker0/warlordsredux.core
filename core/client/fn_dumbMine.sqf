#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _dumbMines = WL_ASSET(_assetActualType, "dumbMine", 0);
_asset setVariable ["WL2_isMinefield", true, true];

private _assetData = WL_ASSET_DATA;
private _side = [_asset] call WL2_fnc_getAssetSide;

_asset allowDamage false;

while { alive _asset && _dumbMines > 0} do {
    uiSleep 0.5;

    if (_dumbMines <= 0) then {
        break;
    };

    private _area = [getPosASL _asset, 35, 5, getDir _asset, true];

    private _enemyUnits = switch (_side) do {
        case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
        default { [] };
    };
    _enemyUnits = _enemyUnits inAreaArray _area;

    private _enemyVehicles = _enemyUnits select {
        WL_ISUP(_x)
    } select {
        !(_x isKindOf "Man")
    } select {
        private _unitActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
        WL_ASSET_FIELD(_assetData, _unitActualType, "demolishable", 0) == 0
    } select {
        !(_x isKindOf "ParachuteBase") && !(vehicle _x isKindOf "ParachuteBase")
    } select {
        _x getVariable ["WL2_alreadyMined", 0] < 3
    } select {
        isEngineOn _x
    } select {
        speed _x > 1
    };

    private _altitude = 0.3 + (getPosASL _asset) # 2;
    {
        private _vehicle = _x;

        if (_dumbMines <= 0) then {
            break;
        };
        _dumbMines = _dumbMines - 1;

        private _alreadyMined = _vehicle getVariable ["WL2_alreadyMined", 0];
        _vehicle setVariable ["WL2_alreadyMined", _alreadyMined + 1];

        private _mine = createMine ["SLAMDirectionalMine", getPosASL _vehicle, [], 3];
        [_mine, [player, player]] remoteExec ["setShotParents", 2];

        private _startTime = serverTime;
        waitUntil {
            uiSleep 0.001;
            private _shotParents = getShotParents _mine;
            !isNull (_shotParents # 0) || serverTime - _startTime > 5
        };

        private _vehiclePosition = _vehicle modelToWorld [0, 1, 0];
        _vehiclePosition set [2, _altitude];
        _mine setPosASL _vehiclePosition;
        triggerAmmo _mine;
    } forEach _enemyVehicles;
};

deleteVehicle _asset;