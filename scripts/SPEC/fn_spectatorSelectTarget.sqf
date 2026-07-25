#include "includes.inc"
params ["_target"];

private _spectatorInfo = uiNamespace getVariable ["RscWLSpectatorInfo", displayNull];
private _spectatorTarget = _spectatorInfo displayCtrl 103;

if (isNull _target) exitWith {
    uiNamespace setVariable ["SPEC_CameraTarget", objNull];
    uiNamespace setVariable ["SPEC_CameraTargetName", "Free Camera"];
    player setVariable ["SPEC_CameraTargetUid", "", true];
    uiNamespace setVariable ["SPEC_TargetCameraMode", 0];

    _spectatorTarget ctrlSetStructuredText parseText format ["<t shadow='2'>Target: %1</t>", "Free Camera"];
};

private _getName = {
    params ["_target"];
    private _sectorName = _target getVariable ["WL2_name", ""];
    if (_sectorName != "") exitWith {
        _sectorName;
    };

    if (_target isKindOf "Man") exitWith {
        name _target;
    };

    private _assetName = [_target] call WL2_fnc_getAssetTypeName;
    if (_assetName != "") exitWith {
        _assetName;
    };

    private _typeName = typeOf _target;
    if (_typeName != "") exitWith {
        _typeName;
    };

    getModelInfo _target # 0;
};

private _typeName = [_target] call _getName;
uiNamespace setVariable ["SPEC_CameraTarget", _target];
uiNamespace setVariable ["SPEC_CameraTargetName", _typeName];
_spectatorTarget ctrlSetStructuredText parseText format ["<t shadow='2'>Target: %1</t>", _typeName];

private _isProjectile = {
    params ["_projectile"];
    if (_projectile isKindOf "MissileCore") exitWith { true; };
    if (_projectile isKindOf "RocketCore") exitWith { true; };
    if (_projectile isKindOf "BombCore") exitWith { true; };
    if (_projectile isKindOf "ShellCore") exitWith { true; };
    if (_projectile isKindOf "SubmunitionCore") exitWith { true; };
    false;
};
if !([_target] call _isProjectile) then {
    private _currentTargetUid = _target getVariable ["BIS_WL_ownerAsset", "123"];
    player setVariable ["SPEC_CameraTargetUid", _currentTargetUid, true];
};