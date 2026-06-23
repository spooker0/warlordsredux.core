#include "includes.inc"
params ["_asset"];
if (isDedicated) exitWith {};

_asset setVariable ["WL2_autoSamMode", 0];

_asset addAction [
    "<t color='#4bff58'>Auto SAM: Default</t>",
    {
        params ["_asset", "_caller", "_actionId", "_arguments"];

        private _mode = _asset getVariable ["WL2_autoSamMode", 0];
        _mode = (_mode + 1) % 8;
        _asset setVariable ["WL2_autoSamMode", _mode];

        private _modeText = switch (_mode) do {
            case 0: {"Default"};
            case 1: {"7 KM"};
            case 2: {"6 KM"};
            case 3: {"5 KM"};
            case 4: {"4 KM"};
            case 5: {"3 KM"};
            case 6: {"2 KM"};
            case 7: {"1 KM"};
            default {""};
        };

        _asset setUserActionText [
            _actionId,
            format ["<t color='#4bff58'>Auto SAM: %1</t>", _modeText]
        ];

        playSoundUI ["a3\sounds_f\sfx\zoomout.wss"];
    },
    [],
    200,
    false,
    false,
    "",
    "cameraOn == _target",
    50
];

private _ignoredTargets = [];

while { alive _asset } do {
    uiSleep 0.5;

    private _mode = _asset getVariable ["WL2_autoSamMode", 0];
    if (_mode == 0) then {
        continue;
    };

    private _gunner = gunner _asset;
    if (cameraOn == _asset) then {
        {
            _gunner ignoreTarget [_x, false];
        } forEach _ignoredTargets;
        _ignoredTargets = [];
        continue;
    };

    private _side = BIS_WL_playerSide;

    private _targetsOnDatalink = (listRemoteTargets _side) select {
        WL_ISUP(_x # 0)
    } select {
        (_x # 1) >= -10
    } select {
        private _targetSide = [_x # 0] call WL2_fnc_getAssetSide;
        _targetSide != _side
    } select {
        !(_x # 0 isKindOf "LaserTarget")
    } apply { _x # 0 };

    private _detectRadius = switch (_mode) do {
        case 1: { 7000 };
        case 2: { 6000 };
        case 3: { 5000 };
        case 4: { 4000 };
        case 5: { 3000 };
        case 6: { 2000 };
        case 7: { 1000 };
        default { 0 };
    };

    private _airTargetsInRange = _targetsOnDatalink select {
        _x isKindOf "Air" && !(_x isKindOf "Steerable_Parachute_F");
    } select {
        _x distance _asset < _detectRadius
    };

    if (count _airTargetsInRange == 0) then {
        if (isAutonomous _asset) then {
            [_asset, false] remoteExec ["setAutonomous", 0];
        };
        continue;
    };

    if (!isAutonomous _asset) then {
        [_asset, true] remoteExec ["setAutonomous", 0];
    };

    private _autoAttackTarget = getAttackTarget _asset;

    if (_autoAttackTarget in _airTargetsInRange) then {
        if (_autoAttackTarget in _ignoredTargets) then {
            _gunner ignoreTarget [_autoAttackTarget, false];
            _ignoredTargets = _ignoredTargets select {
                _x != _autoAttackTarget
            };
        };
    } else {
        if !(_autoAttackTarget in _ignoredTargets) then {
            _gunner ignoreTarget [_autoAttackTarget, true];
            _ignoredTargets pushBackUnique _autoAttackTarget;
        };
    };
};