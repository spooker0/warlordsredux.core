#include "constants.inc"

params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

if (!WL_IsSpectator) exitWith {};

private _projectiles = uiNamespace getVariable ["WL2_projectiles", []];
_unit setVariable ["WL2_spectateLastFired", serverTime];
if ([_projectile] call WL2_fnc_isScannerMunition) then {
    _projectiles pushBack _projectile;
    _projectiles = _projectiles select { alive _x };

    private _maxDistance = uiNamespace getVariable ["WL_SpectatorHudMaxDistance", 10000];
    private _cameraPos = positionCameraToWorld [0, 0, 0];
    [_cameraPos, _maxDistance] call SPEC_fnc_spectatorUpdateProjectiles;

    private _spectatorFocus = uiNamespace getVariable [SPEC_VAR_FOCUS, objNull];
    if (vehicle _spectatorFocus != _unit) exitWith {};

    if (uiNamespace getVariable ["SPEC_spectateProjectile", false]) then {
        uiNamespace setVariable ["SPEC_spectateProjectile", false];
        [false] call SPEC_fnc_spectatorUpdateBinocularIcon;

        [_projectile, _spectatorFocus] spawn {
            params ["_projectile", "_spectatorFocus"];
            ["SetCameraMode", ["free"]] call SPEC_VAR_FUN_CAMERA;
            [] call SPEC_VAR_FUN_RESET_TARGET;
            uiNamespace setVariable [SPEC_VAR_FOCUS, objNull];

            private _camera = missionNamespace getVariable [SPEC_VAR_CAM, objNull];
            if (!isNull _camera) then {
                _camera attachTo [_projectile, [0, 2, 1]];
                _camera camSetTarget _projectile;
                _camera camCommit 0;
            };

            while { alive _projectile } do {
                if (uiNamespace getVariable ["SPEC_spectateProjectile", true]) then {
                    break;
                };
                sleep 0.1;
            };

            detach _camera;
            [_spectatorFocus] call SPEC_VAR_FUN_PREPARE_TARGET;
            [] call SPEC_VAR_FUN_RESET_TARGET;

            uiNamespace setVariable [SPEC_VAR_FOCUS, _spectatorFocus];
            ["SetCameraMode", ["follow"]] call SPEC_VAR_FUN_CAMERA;

            uiNamespace setVariable ["SPEC_spectateProjectile", false];
            [false] call SPEC_fnc_spectatorUpdateBinocularIcon;
        };
    };
};