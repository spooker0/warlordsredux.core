#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
_asset setVariable ["WL2_smartMines", WL_ASSET(_assetActualType, "smartMine", 0), true];

private _dispenseSounds = [
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_01.wss",
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_02.wss",
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_03.wss",
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_04.wss"
];
private _detonateSounds = [
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_01.wss",
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_02.wss",
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_03.wss",
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_04.wss"
];

private _assetPos = getPosASL _asset;

private _assetData = WL_ASSET_DATA;

while { alive _asset } do {
    uiSleep 1;

    private _side = [_asset] call WL2_fnc_getAssetSide;

    if (!isNull attachedTo _asset) then {
        continue;
    };

    private _smartMines = _asset getVariable ["WL2_smartMines", 0];
    if (_smartMines == 0) then {
        continue;
    };

    private _smartMineDistanceIndex = _asset getVariable ["WL2_smartMineDistance", 0];
    private _detonationDistance = WL_SMART_MINE_DISTANCES # _smartMineDistanceIndex;
    if (_detonationDistance == 0) then {
        continue;
    };

    private _enemyUnits = switch (_side) do {
        case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
        default { [] };
    };

    _assetPos = getPosASL _asset;
    private _assetDir = getDir _asset;

    private _angle = WL_SMART_MINE_ANGLES # _smartMineDistanceIndex;
    private _smartMineType = _asset getVariable ["WL2_smartMineType", 0];

    private _enemyVehicles = _enemyUnits select { alive _x } select {
        _x distance _asset < _detonationDistance
    } select {
        private _unitActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
        WL_ASSET_FIELD(_assetData, _unitActualType, "demolishable", 0) == 0
    } select {
        [_assetPos, _assetDir, _angle, getPosASL _x] call WL2_fnc_inAngleCheck
    };

    _enemyVehicles = _enemyVehicles select {
        switch (_smartMineType) do {
            case 0: { true };
            case 1: { !(_x isKindOf "Man") };
            case 2: { _x isKindOf "Man" && vehicle _x == _x };
            default { true };
        };
    };

    if (count _enemyVehicles == 0) then {
        continue;
    };

    private _assetPosAGL = _asset modelToWorld [0, 0, 0];
    private _startPos = _asset modelToWorld [0, 0, 100];
    private _obstructionsAbove = lineIntersects [_assetPos, AGLtoASL _startPos, _asset];
    if (_obstructionsAbove) then {
        playSound3D ["a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_mine_trigger_01.wss", _asset];
        ["No clear line of sight above to deploy mine."] call WL2_fnc_smoothText;
        uiSleep 10;
        continue;
    };

    _enemyVehicles = [_enemyVehicles, [_assetData], {
        private _assetData = _input0;
        private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
        WL_ASSET_FIELD(_assetData, _assetActualType, "cost", 0);
    }, "DESCEND"] call BIS_fnc_sortBy;
    private _selectedTarget = _enemyVehicles # 0;
    private _targetName = [_selectedTarget] call WL2_fnc_getAssetTypeName;  // leave here in case asset dies

    _smartMines = _smartMines - 1;
    _asset setVariable ["WL2_smartMines", _smartMines, true];

    [_assetPosAGL, [
		["DeminingExplosiveCircleDust", 0.3],
		["ATMineExplosionParticles", 0.1]
	]] remoteExec ["WL2_fnc_particleEffect", 0];
    playSound3D [selectRandom _dispenseSounds, _asset];

    private _projectileType = if (_selectedTarget isKindOf "Man") then {
        "M_Titan_AP"
    } else {
        "M_Titan_AT"
    };

    private _projectile = createVehicle [_projectileType, _asset modelToWorld [0, 0, 1], [], 0, "FLY"];

    private _initialVectorDirAndUp = [getPosASL _projectile, AGLtoASL _startPos] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _initialVectorDirAndUp;
    _projectile setVelocityModelSpace [0, 200, 0];

    [_projectile, [_asset, _asset]] remoteExec ["setShotParents", 2];

    private _enemySide = [_selectedTarget] call WL2_fnc_getAssetSide;
    [[_asset], 10] remoteExec ["WL2_fnc_reportTargets", _enemySide];

    uiSleep 0.5;
    _projectile setVelocity [0, 0, 0];
    _projectile setPosASL (AGLtoASL _startPos);
    _projectile setMissileTarget [_selectedTarget, true];
    [_assetPosAGL, [
		["FX_MissileTrail_SAM", _projectile]
	]] remoteExec ["WL2_fnc_particleEffect", 0];

    private _munitionList = cameraOn getVariable ["DIS_munitionList", []];
    _munitionList pushBack _projectile;
    _munitionList = _munitionList select { alive _x };
    cameraOn setVariable ["DIS_munitionList", _munitionList];
    _projectile setVariable ["DIS_ultimateTarget", _selectedTarget];

    private _mineTypeName = if (_projectileType == "M_Titan_AP") then {
        "SMART MINE (AP)"
    } else {
        "SMART MINE (AT)"
    };
    _projectile setVariable ["WL2_missileType", _mineTypeName];

    [_startPos, [
		["ImpactSparksSabot1", 0.1],
		["ClusterExpFire", 0.5],
		["CloudBigDark", 0.5],
        ["CannonFired2", 0.5],
		["SecondaryExp", 0.5],
		["SecondarySmoke", 1]
    ]] remoteExec ["WL2_fnc_particleEffect", 0];
    playSound3D [selectRandom _detonateSounds, objNull, false, AGLtoASL _startPos];

    uiSleep 0.3;

    private _projectilePos = getPosASL _projectile;
    private _targetPos = getPosASL _selectedTarget;

    private _targetVectorDirAndUp = [_projectilePos, _targetPos] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _targetVectorDirAndUp;
    _projectile setVelocityModelSpace [0, 250, 0];

    // [format ["Smart mine system engaged hostile %1. Charges remaining: %2", _targetName, _smartMines]] call WL2_fnc_smoothText;

    uiSleep 5;
};

[ASLtoAGL _assetPos, [
    ["DeminingExplosiveCircleDust", 0.3],
    ["SecondaryExp", 0.2],
    ["SecondarySmoke", 0.2]
]] remoteExec ["WL2_fnc_particleEffect", 0];
playSound3D [selectRandom _detonateSounds, objNull, false, _assetPos];
deleteVehicle _asset;