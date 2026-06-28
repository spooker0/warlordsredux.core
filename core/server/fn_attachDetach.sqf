#include "includes.inc"
params ["_attach", "_arguments"];

if (_attach) then {
    private _asset = _arguments # 0;
    private _load = _arguments # 1;

    private _loadRotate = WL_UNIT(_load, "loadRotate", 0);
    private _centerOfMass = getCenterOfMass _load;
    if (_centerOfMass # 2 < -1) then {
        _loadRotate = 2;
    };
    if (_loadRotate == -1) then {
        _loadRotate = 0;
    };

    private _assetIsAirWreck = _load isKindOf "Air" && !(_asset isKindOf "Air");
    private _loadBoundingBox = if (_assetIsAirWreck) then {
        boundingBoxReal [_load, "LandContact"];
    } else {
        boundingBoxReal [_load, "Geometry"];
    };
    _loadBoundingBox params ["_loadBoundingBoxMin", "_loadBoundingBoxMax", "_loadBoundingBoxRadius"];
    _loadBoundingBoxMin params ["_loadBoundingBoxMinX", "_loadBoundingBoxMinY", "_loadBoundingBoxMinZ"];
    _loadBoundingBoxMax params ["_loadBoundingBoxMaxX", "_loadBoundingBoxMaxY", "_loadBoundingBoxMaxZ"];

    private _loadableAngle = 0;
    if (_loadRotate == 1) then {
        private _oldMinX = _loadBoundingBoxMinX;
        private _oldMaxX = _loadBoundingBoxMaxX;
        private _oldMinY = _loadBoundingBoxMinY;
        private _oldMaxY = _loadBoundingBoxMaxY;

        _loadBoundingBoxMinX = _oldMinY;
        _loadBoundingBoxMaxX = _oldMaxY;

        _loadBoundingBoxMinY = -_oldMaxX;
        _loadBoundingBoxMaxY = -_oldMinX;

        _loadableAngle = 90;
    };

    if (_loadRotate == 2) then {
        private _oldMinX = _loadBoundingBoxMinX;
        private _oldMaxX = _loadBoundingBoxMaxX;
        private _oldMinY = _loadBoundingBoxMinY;
        private _oldMaxY = _loadBoundingBoxMaxY;

        _loadBoundingBoxMinX = -_oldMaxX;
        _loadBoundingBoxMaxX = -_oldMinX;

        _loadBoundingBoxMinY = -_oldMaxY;
        _loadBoundingBoxMaxY = -_oldMinY;

        _loadableAngle = 180;
    };

    private _offset = [
        _centerOfMass # 0,
        -_loadBoundingBoxMaxY + 1.1,
        -_loadBoundingBoxMinZ - 0.8
    ];

    if (_asset isKindOf "VTOL_01_base_F") then {
        _offset = _offset vectorAdd [0, 4.5, -4.9];
    };
    // if (_asset isKindOf "B_APC_Tracked_01_base_F") then {
    //     _offset = _offset vectorAdd [0, -5.5, 0];
    // };

    _load attachTo [_asset, _offset];

    if (_loadRotate != 0) then {
        _load setDir _loadableAngle;
        _load setPosWorld getPosWorld _load;
    };

    _asset setVariable ["WL2_loadingAsset", false, true];

    [_asset, _load, true] call WL2_fnc_attachVehicle;
} else {
    private _asset = _arguments # 0;
    private _load = _arguments # 1;
    private _offset = _arguments # 2;
    private _position = _arguments # 3;
    private _direction = _arguments # 4;

    _load attachTo [_asset, _offset];
    detach _load;
    _load setVectorDirAndUp _direction;
    _load setVehiclePosition [_position, [], 0, "CAN_COLLIDE"];

    _asset setVariable ["WL2_loadingAsset", false, true];

    [_asset, _load, false] call WL2_fnc_attachVehicle;
};