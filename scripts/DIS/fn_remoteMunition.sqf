#include "includes.inc"
params ["_originalProjectile", "_asset", "_bunkerBuster"];

private _assetName = [_asset] call WL2_fnc_getAssetTypeName;
private _controlMunitionRequest = [
    "Control Munition Request",
    format ["Control remote munition for %1 (Pilot: %2)?", _assetName, name driver _asset],
    "Control", "Don't Control"
] call WL2_fnc_prompt;
if (!_controlMunitionRequest) exitWith {};

waitUntil {
    uiSleep 0.001;
    inputAction "defaultAction" <= 0;
};

private _controllingProjectile = player getVariable ["DIS_controllingProjectile", objNull];
triggerAmmo _controllingProjectile;

while { typeof cameraOn == "Camera" } do {
    uiSleep 0.1;
};

uiNamespace setVariable ["WL_waypointPosition", customWaypointPosition];

private _camera = "camera" camCreate (position _asset);
_camera switchCamera "INTERNAL";
cameraEffectEnableHUD true;
showHUD [true, true, true, true, true, true, true, true, true, true, true];
player setVariable ["WL_hmdOverride", 2];

private _waypointDrawer = addMissionEventHandler ["Draw3D", {
    private _waypointPosition = uiNamespace getVariable ["WL_waypointPosition", []];
    if (count _waypointPosition == 0) exitWith {};
    private _distance = _waypointPosition distance cameraOn;
    _waypointPosition set [2, 0];
    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscIngameUI\RscOptics\square.paa",
        [1, 1, 1, 1],
        _waypointPosition,
        0.3,
        0.3,
        0,
        format ["WAYPOINT %1KM", (_distance / 1000) toFixed 1],
        0,
        0.02,
        "TahomaB",
        "center",
        true,
        0,
        0.01
    ];
}];

private _projectileASL = getPosASL _originalProjectile;
private _projectileVectorDirAndUp = [vectorDir _originalProjectile, vectorUp _originalProjectile];
private _projectileVelocity = velocityModelSpace _originalProjectile;
deleteVehicle _originalProjectile;

_projectileVelocity = _projectileVelocity vectorMultiply 2;

private _projectile = createVehicle ["Missile_AGM_02_F", [0, 0, 0], [], 0, "FLY"];
_projectile setPosASL _projectileASL;
_projectile setVectorDirAndUp _projectileVectorDirAndUp;
_projectile setVelocityModelSpace _projectileVelocity;
private _playerVehicle = vehicle player;
[_projectile, [_asset, _asset]] remoteExec ["setShotParents", 2];
[_projectile, driver _asset] remoteExec ["DIS_fnc_startMissileCamera", _asset];

if (_bunkerBuster > 0) then {
    _projectile setVariable ["DIS_bunkerBusterSteps", _bunkerBuster];
    _projectile addEventHandler ["Explode", {
        params ["_projectile", "_position"];
        private _bunkerBusterSteps = _projectile getVariable ["DIS_bunkerBusterSteps", 7];
        [typeOf _projectile, _position, [vectorDir _projectile, vectorUp _projectile], _bunkerBusterSteps] spawn DIS_fnc_bunkerBuster;
    }];
};

_projectile setVariable ["APS_speedOverride", vectorMagnitude _projectileVelocity];
_projectile setVariable ["APS_ammoOverride", "Missile_AGM_02_TV_F"];
player setVariable ["DIS_controllingProjectile", _projectile];

_camera setVectorDirAndUp [vectorDir _projectile, vectorUp _projectile];
_camera attachTo [_projectile, [0, -3, 0.4]];

[_projectile, 3] call DIS_fnc_controlMunition;

player setVariable ["WL_hmdOverride", -1];
removeMissionEventHandler ["Draw3D", _waypointDrawer];
switchCamera player;
camDestroy _camera;