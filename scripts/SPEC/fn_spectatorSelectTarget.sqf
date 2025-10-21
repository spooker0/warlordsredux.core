#include "includes.inc"
params ["_target"];

private _display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
private _texture = _display displayCtrl 5502;

if (isNull _target) exitWith {
    uiNamespace setVariable ["SPEC_CameraTarget", objNull];
    uiNamespace setVariable ["SPEC_CameraTargetName", "Free Camera"];
    _texture ctrlWebBrowserAction ["ExecJS", "updateTargetName('Free Camera');"];
    player setVariable ["SPEC_CameraTargetUid", "", true];
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
_texture ctrlWebBrowserAction ["ExecJS", format ["updateTargetName('%1');", _typeName]];

private _currentTargetUid = _target getVariable ["BIS_WL_ownerAsset", "123"];
player setVariable ["SPEC_CameraTargetUid", _currentTargetUid, true];