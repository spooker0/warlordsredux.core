#include "includes.inc"
private _endEffect = {
    "CapWarning" cutText ["", "PLAIN"];
    uiSleep 2;
};

private _lastNotifyTime = 0;
private _responseTimeEstimate = -1;
while { !BIS_WL_missionEnd } do {
    uiSleep 0.5;
    private _side = BIS_WL_playerSide;
    private _asset = cameraOn;

    if (WL_ISDOWN(_asset)) exitWith {
        call _endEffect;
        continue;
    };

    if !(_asset isKindOf "Air") then {
        call _endEffect;
        continue;
    };

    private _assetPos = _asset modelToWorld [0, 0, 0];

    private _combatPatrolSectors = BIS_WL_allSectors select {
        _x getVariable ["WL2_combatAirActive", false];
    } select {
        _x getVariable ["BIS_WL_owner", independent] != _side;
    };

    private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
    private _capForwardAirbases = _forwardBases select {
        _x getVariable ["WL2_combatAirActive", false];
    } select {
        _x getVariable ["WL2_forwardBaseOwner", independent] != _side;
    };
    private _combatAirAreas = _combatPatrolSectors + _capForwardAirbases;

    private _assetInCombatAirArea = _combatAirAreas select {
        _assetPos inArea [
            getPosASL _x,
            WL_COMBAT_AIR_RADIUS,
            WL_COMBAT_AIR_RADIUS,
            0,
            false
        ];
    };

    if (count _assetInCombatAirArea == 0) then {
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
        private _minTimeToShoot = 45;
        {
            private _combatAirArea = _x;
            private _startTime = _combatAirArea getVariable ["WL2_combatAirStart", 0];
            if (serverTime < _startTime) then {
                _minTimeToShoot = _minTimeToShoot min (_startTime - serverTime);
            } else {
                _minTimeToShoot = 5;
            };
        } forEach _assetInCombatAirArea;
        _responseTimeEstimate = serverTime + _minTimeToShoot;
    };

    private _timeRemaining = _responseTimeEstimate - serverTime;

    private _warningTextDisplay = uiNamespace getVariable ["RscWLExtendedSamWarningDisplay", displayNull];
    if (isNull _warningTextDisplay) then {
        "CapWarning" cutRsc ["RscWLExtendedSamWarningDisplay", "PLAIN", -1, true, true];
    };
    private _warningTimer = _warningTextDisplay displayCtrl 14300;
    _warningTimer ctrlSetText format ["%1", round _timeRemaining];

    if (_timeRemaining <= 0) then {
        _assetInCombatAirArea = [_assetInCombatAirArea, [], { cameraOn distance _x }, "ASCEND"] call BIS_fnc_sortBy;

        private _target = _assetInCombatAirArea # 0;
        [_asset, _target, true] spawn DIS_fnc_combatAirPatrol;
        _responseTimeEstimate = -1;
    };
};