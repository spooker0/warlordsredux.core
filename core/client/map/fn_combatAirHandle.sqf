#include "includes.inc"
params ["_sector", "_side"];

private _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
waitUntil {
    uiSleep 0.001;
    _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
    _combatAirActive
};

if (isDedicated) exitWith {
    while { _combatAirActive } do {
        uiSleep 20;

        _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
        if (!_combatAirActive) then {
            break;
        };

        private _independentAircraft = vehicles select {
            independent == [_x] call WL2_fnc_getAssetSide;
        };
        {
            [_x, _sector] spawn DIS_fnc_combatAirPatrol;
        } forEach _independentAircraft;
    };
};

if (BIS_WL_playerSide == _side) exitWith {};

private _responseTimeEstimate = -1;
private _warned = false;

private _endEffect = {
    _responseTimeEstimate = -1;
    "CapWarning" cutText ["", "PLAIN"];
    uiSleep 1;
};

private _sectorArea = [
    getPosASL _sector,
    WL_RADIUS_COMBAT_AIR,
    WL_RADIUS_COMBAT_AIR,
    0,
    false
];

while { _combatAirActive } do {
    uiSleep 0.5;

    _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
    if (!_combatAirActive) then {
        call _endEffect;
        break;
    };

    private _asset = cameraOn;
    if (!alive _asset || lifeState _asset == "INCAPACITATED") then {
        call _endEffect;
        continue;
    };
    if !(_asset isKindOf "Air") then {
        call _endEffect;
        continue;
    };

    private _assetPos = _asset modelToWorld [0, 0, 0];
    if !(_assetPos inArea _sectorArea) then {
        call _endEffect;
        continue;
    };

    private _altitude = _assetPos # 2;
    if (_altitude < 250) then {
        call _endEffect;
        continue;
    };

    if (_responseTimeEstimate < 0) then {
        private _responseTime = if (_warned) then {
            10
        } else {
            25
        };
        _responseTimeEstimate = serverTime + _responseTime;
    };

    if (!_warned) then {
        ["Enemy combat air detected"] call WL2_fnc_smoothText;
        _warned = true;
    };

    private _timeRemaining = _responseTimeEstimate - serverTime;

    private _warningTextDisplay = uiNamespace getVariable ["RscWLExtendedSamWarningDisplay", displayNull];
    if (isNull _warningTextDisplay) then {
        "CapWarning" cutRsc ["RscWLExtendedSamWarningDisplay", "PLAIN", -1, true, true];
    };
    private _warningTimer = _warningTextDisplay displayCtrl 14300;
    _warningTimer ctrlSetText format ["%1", round _timeRemaining];

    if (_timeRemaining <= 0) then {
        [_asset, _sector] spawn DIS_fnc_combatAirPatrol;
        _responseTimeEstimate = -1;
    };
};