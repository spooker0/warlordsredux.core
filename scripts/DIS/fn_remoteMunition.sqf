#include "includes.inc"
params ["_originalProjectile", "_asset", "_bunkerBuster"];

private _assetName = [_asset] call WL2_fnc_getAssetTypeName;
private _controlMunitionRequest = [
    "Control Munition Request",
    format ["Control remote munition for %1 (Pilot: %2)?", _assetName, name driver _asset],
    "Control", "Don't Control"
] call WL2_fnc_prompt;
if (!_controlMunitionRequest) exitWith {};

private _controllingProjectile = player getVariable ["DIS_controllingProjectile", objNull];
triggerAmmo _controllingProjectile;

while { typeof cameraOn == "Camera" } do {
    sleep 0.1;
};

private _camera = "camera" camCreate (position _asset);
_camera switchCamera "INTERNAL";
cameraEffectEnableHUD true;
showHUD [true, true, true, true, true, true, true, true, true, true, true];
player setVariable ["WL_hmdOverride", 2];

private _projectileASL = getPosASL _originalProjectile;
private _projectileVectorDirAndUp = [vectorDir _originalProjectile, vectorUp _originalProjectile];
private _projectileVelocity = velocityModelSpace _originalProjectile;
deleteVehicle _originalProjectile;

private _projectile = createVehicle ["Bomb_04_F", [0, 0, 0], [], 0, "FLY"];
_projectile setPosASL _projectileASL;
_projectile setVectorDirAndUp _projectileVectorDirAndUp;
_projectile setVelocityModelSpace _projectileVelocity;
[_projectile, [player, player]] remoteExec ["setShotParents", 2];
[_projectile, driver _asset] remoteExec ["DIS_fnc_startMissileCamera", _asset];

if (_bunkerBuster) then {
    _projectile addEventHandler ["Explode", {
        _this spawn DIS_fnc_bunkerBuster;
    }];
};

_projectile setVariable ["APS_speedOverride", vectorMagnitude _projectileVelocity];
player setVariable ["DIS_controllingProjectile", _projectile];

_camera setVectorDirAndUp [vectorDir _projectile, vectorUp _projectile];
_camera attachTo [_projectile, [0, -3, 0.4]];

[_projectile, 3] call DIS_fnc_controlMunition;

player setVariable ["WL_hmdOverride", -1];
switchCamera player;
camDestroy _camera;