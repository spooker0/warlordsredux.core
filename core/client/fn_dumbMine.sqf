#include "includes.inc"
params ["_asset"];

private _dumbMines = WL_UNIT(_asset, "dumbMine", 0);
_asset setVariable ["WL2_isMinefield", true, true];

private _assetData = WL_ASSET_DATA;
private _side = [_asset] call WL2_fnc_getAssetSide;

_asset allowDamage false;

private _mineOwner = if (isServer) then {
    objNull
} else {
    player
};

while { alive _asset && _dumbMines > 0} do {
    uiSleep 0.5;

    if (_dumbMines <= 0) then {
        break;
    };

    if (!isNull attachedTo _asset) then {
        continue;
    };

    private _area = [getPosASL _asset, 50, 10, getDir _asset, true];

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
        private _unitActualType = WL_ASSET_TYPE(_x);
        WL_ASSET_FIELD(_assetData, _unitActualType, "demolishable", 0) == 0
    } select {
        !(_x isKindOf "ParachuteBase") && !(vehicle _x isKindOf "ParachuteBase")
    } select {
        private _posAGL = _x modelToWorld [0, 0, 0];
        _posAGL # 2 < 10;
    } select {
        isEngineOn _x
    } select {
        abs (speed _x) > 1
    };

    private _altitude = 0.3 + (getPosASL _asset) # 2;
    {
        private _vehicle = _x;

        if (_dumbMines <= 0) then {
            break;
        };
        _dumbMines = _dumbMines - 1;

        private _mine = createMine ["SLAMDirectionalMine", getPosASL _vehicle, [], 3];
        [_mine, [_mineOwner, _mineOwner]] remoteExec ["setShotParents", 2];

        private _startTime = serverTime;
        waitUntil {
            uiSleep 0.001;
            private _shotParents = getShotParents _mine;
            (_shotParents # 0) isEqualTo _mineOwner || serverTime - _startTime > 5
        };

        private _vehiclePosition = _vehicle modelToWorld [0, 1, 0];
        _vehiclePosition set [2, _altitude];
        _mine setPosASL _vehiclePosition;
        triggerAmmo _mine;
    } forEach _enemyVehicles;
};

deleteVehicle _asset;