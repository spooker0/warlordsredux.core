#include "constants.inc"

private _laserTargets = uiNamespace getVariable ["WL2_spectatorDrawLasers", []];
private _infantry = uiNamespace getVariable ["WL2_spectatorDrawInfantry", []];
private _vehicles = uiNamespace getVariable ["WL2_spectatorDrawVehicles", []];
private _projectiles = uiNamespace getVariable ["WL2_spectatorDrawProjectiles", []];
private _sectors = uiNamespace getVariable ["WL2_spectatorDrawSectors", []];

{
    private _target = _x # 0;
    private _playerName = _x # 1;
    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\LaserTarget_ca.paa",
        [1, 0, 0, 1],
        _target modelToWorldVisual [0, 0, 0],
        1,
        1,
        45,
        _playerName,
        0,
        0.05,
        "RobotoCondensedBold"
    ];
} forEach _laserTargets;

{
    private _target = _x # 0;
    private _targetColor = _x # 1;
    private _assetName = _x # 2;

    private _lastFiredTime = _target getVariable ["WL2_spectateLastFired", -1];
    private _opacity = linearConversion [0, 0.5, serverTime - _lastFiredTime, 0, 1, true];
    _targetColor set [3, _opacity];

    private _centerOfMass = _target selectionPosition "spine2";
    _centerOfMass set [2, _centerOfMass # 2 + 1];

    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
        _targetColor,
        _target modelToWorldVisual _centerOfMass,
        0.5,
        0.5,
        45,
        _assetName,
        true,
        0.032,
        "RobotoCondensedBold"
    ];
} forEach _infantry;

{
    private _target = _x # 0;
    private _targetIcon = _x # 1;
    private _targetColor = _x # 2;
    private _iconSize = _x # 3;
    private _targetIconRatio = _x # 4;
    private _assetName = _x # 5;
    private _iconTextSize = _x # 6;

    private _lastFiredTime = _target getVariable ["WL2_spectateLastFired", -1];
    private _opacity = linearConversion [0, 0.5, serverTime - _lastFiredTime, 0, 0.6, true];
    _targetColor set [3, _opacity];

    private _centerOfMass = getCenterOfMass _target;
    _centerOfMass set [2, _centerOfMass # 2 + 3];

    drawIcon3D [
        _targetIcon,
        _targetColor,
        _target modelToWorldVisual _centerOfMass,
        _iconSize * _targetIconRatio,
        _iconSize,
        0,
        _assetName,
        true,
        _iconTextSize,
        "RobotoCondensedBold",
        "center",
        true
    ];
} forEach _vehicles;

private _cameraPos = positionCameraToWorld [0, 0, 0];
{
    private _projectilePos = _x modelToWorldVisual [0, 0, 0];
    private _distance = _cameraPos distance _projectilePos;
    private _projectileSize = linearConversion [500, 5000, _distance, 0.8, 0.5, true];

    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missile_ca.paa",
        [1, 0, 0, 1],
        _projectilePos,
        _projectileSize,
        _projectileSize,
        0,
        format ["%1 KM", (_distance / 1000) toFixed 1],
        true,
        0.04 * _projectileSize,
        "RobotoCondensedBold",
        "center",
        true
    ];
} forEach _projectiles;

{
    private _sector = _x # 0;
    private _sectorIcon = _x # 1;
    private _sectorColor = _x # 2;
    private _sectorPos = _x # 3;
    private _sectorName = _x # 4;

    private _distance = _cameraPos distance _sectorPos;
    private _sectorIconSize = linearConversion [200, 5000, _distance, 1.2, 0.3, true];

    drawIcon3D [
        _sectorIcon,
        _sectorColor,
        _sectorPos,
        _sectorIconSize,
        _sectorIconSize,
        0,
        _sectorName,
        true,
        0.04 * _sectorIconSize,
        "RobotoCondensedBold"
    ];
} forEach _sectors;