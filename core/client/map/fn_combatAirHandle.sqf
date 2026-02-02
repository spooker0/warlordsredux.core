#include "includes.inc"
params ["_sector", "_side"];

private _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
waitUntil {
    uiSleep 0.001;
    _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
    _combatAirActive
};

private _startTime = serverTime;
if (isServer) then {
    [_sector, _side] spawn {
        params ["_sector", "_side"];

        private _combatAirActive = true;
        private _sectorArea = [
            getPosASL _sector,
            WL_COMBAT_AIR_RADIUS,
            WL_COMBAT_AIR_RADIUS,
            0,
            false
        ];

        private _lastNotifyTime = 0;
        while { _combatAirActive } do {
            uiSleep 10;

            _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
            if (!_combatAirActive) then {
                break;
            };

            private _independentAircraft = vehicles select {
                independent == [_x] call WL2_fnc_getAssetSide
            } select {
                alive _x;
            } select {
                _x isKindOf "Air";
            } select {
                _x inArea _sectorArea
            };

            {
                [_x, _sector, false] spawn DIS_fnc_combatAirPatrol;
            } forEach _independentAircraft;

            if (count _independentAircraft == 0) then {
                continue;
            };

            if (serverTime - _lastNotifyTime > 30) then {
                [_independentAircraft, 30] remoteExec ["WL2_fnc_reportTargets", _side];
                _lastNotifyTime = serverTime;
            };
        };
    };
};

if (isDedicated) exitWith {};
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
    WL_COMBAT_AIR_RADIUS,
    WL_COMBAT_AIR_RADIUS,
    0,
    false
];

private _lastNotifyTime = 0;
while { _combatAirActive } do {
    uiSleep 0.5;

    _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
    if (!_combatAirActive) then {
        call _endEffect;
        break;
    };

    private _asset = cameraOn;
    if (WL_ISDOWN(_asset)) then {
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

    if (serverTime - _lastNotifyTime > 30) then {
        [[_asset], 30] remoteExec ["WL2_fnc_reportTargets", _side];
        _lastNotifyTime = serverTime;
    };

    private _altitude = _assetPos # 2;
    if (_altitude < WL_COMBAT_AIR_MINALT) then {
        call _endEffect;
        continue;
    };

    if (_responseTimeEstimate < 0) then {
        private _responseTime = if (_warned) then {
            5
        } else {
            private _timeSinceStart = serverTime - _startTime;
            45 min ((45 - _timeSinceStart) max 5)
        };
        _responseTimeEstimate = serverTime + _responseTime;
    };

    if (!_warned) then {
        ["Enemy combat air detected."] call WL2_fnc_smoothText;
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
        [_asset, _sector, true] spawn DIS_fnc_combatAirPatrol;
        _responseTimeEstimate = -1;
    };
};