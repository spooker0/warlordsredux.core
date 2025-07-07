#include "includes.inc"
params ["_asset", "_controlStation"];

_controlStation setVariable ["DIS_remoteInUseBy", player, true];

private _camera = "camera" camCreate (position _asset);
private _prepareInterface = {
    "controlStation" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
    private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];

    _camera setVectorDirAndUp [vectorDir _asset, vectorUp _asset];
    _camera attachTo [_asset, [0, -5, 3]];

    private _controlParams = ["REMOTE MUNITION", [
        ["Exit", "ActionContext"]
    ]];
    ["Remote", _controlParams] call WL2_fnc_showHint;
};

private _killInterface = {
    "controlStation" cutText ["", "PLAIN"];
    ["Remote"] call WL2_fnc_showHint;
};

call _prepareInterface;

_camera switchCamera "INTERNAL";
cameraEffectEnableHUD true;
showHUD [true, true, true, true, true, true, true, true, true, true, true];
player setVariable ["WL_hmdOverride", 2];

waitUntil {
    sleep 0.001;
    inputAction "ActionContext" == 0
};

while { alive _asset && (_asset getVariable ["DIS_remoteControlStation", objNull]) == _controlStation } do {
    if (inputAction "ActionContext" > 0) then {
        break;
    };

    private _controlledProjectile = _asset getVariable ["APS_remoteControlled", objNull];
    if !(isNull _controlledProjectile) then {
        _asset setVariable ["APS_remoteControlled", objNull, true];
        sleep 1;

        "controlStation" cutText ["", "PLAIN"];
        private _projectileASL = getPosASL _controlledProjectile;
        private _projectileVectorDirAndUp = [vectorDir _controlledProjectile, vectorUp _controlledProjectile];
        private _projectileVelocity = velocityModelSpace _controlledProjectile;
        deleteVehicle _controlledProjectile;

        private _projectile = createVehicle ["ammo_Bomb_SDB", [0, 0, 0], [], 0, "FLY"];
        _projectile setPosASL _projectileASL;
        _projectile setVectorDirAndUp _projectileVectorDirAndUp;
        _projectile setVelocityModelSpace _projectileVelocity;
        [_projectile, [player, player]] remoteExec ["setShotParents", 2];
        [_projectile, driver _asset] remoteExec ["DIS_fnc_startMissileCamera", _asset];

        _projectile setVariable ["APS_speedOverride", vectorMagnitude _projectileVelocity];

        _camera setVectorDirAndUp [vectorDir _projectile, vectorUp _projectile];
        _camera attachTo [_projectile, [0, -3, 0.4]];

        call _killInterface;

        [_projectile, 3] call DIS_fnc_controlMunition;

        call _prepareInterface;
    };

    sleep 0.001;
};

_controlStation setVariable ["DIS_remoteInUseBy", objNull, true];

player setVariable ["WL_hmdOverride", -1];
switchCamera player;
camDestroy _camera;

call _killInterface;