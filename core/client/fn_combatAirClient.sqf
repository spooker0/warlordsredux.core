#include "includes.inc"

private _lastNotifyTime = 0;
private _side = BIS_WL_playerSide;
private _enemySide = BIS_WL_enemySide;

while { !BIS_WL_missionEnd } do {
    uiSleep 0.5;
    private _asset = cameraOn;

    if (WL_ISDOWN(_asset)) exitWith {
        continue;
    };

    if !(_asset isKindOf "Air") then {
        continue;
    };

    private _assetPos = _asset modelToWorld [0, 0, 0];

    private _combatPatrolSectors = BIS_WL_allSectors select {
        _x getVariable ["WL2_combatAirActive", false];
#if WL_CAP_DEBUG == 0
    } select {
        _x getVariable ["BIS_WL_owner", independent] != _side;
#endif
    };

    private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
    private _capForwardAirbases = _forwardBases select {
        _x getVariable ["WL2_combatAirActive", false];
#if WL_CAP_DEBUG == 0
    } select {
        _x getVariable ["WL2_forwardBaseOwner", independent] != _side;
#endif
    };
    private _combatAirAreas = _combatPatrolSectors + _capForwardAirbases;

    private _assetInCombatAirArea = _combatAirAreas select {
        private _startTime = _x getVariable ["WL2_combatAirStart", 0];
        private _timeElapsed = serverTime - _startTime;
        private _timeStepsElapsed = 5 * ceil (_timeElapsed / 5);
        private _areaRadius = _timeStepsElapsed * WL_COMBAT_AIR_PERSEC;

        private _combatAreaMax = if (_x in [WL2_base1, WL2_base2]) then {
            WL_COMBAT_AIR_RADIUS_BASE
        } else {
            WL_COMBAT_AIR_RADIUS
        };
        _areaRadius = _areaRadius min _combatAreaMax;
        _assetPos inArea [
            getPosASL _x,
            _areaRadius,
            _areaRadius,
            0,
            false
        ];
    };

    if (count _assetInCombatAirArea == 0) then {
        continue;
    };

    if (serverTime - _lastNotifyTime > 30) then {
        [[_asset], 45] remoteExec ["WL2_fnc_reportTargets", _enemySide];
        _lastNotifyTime = serverTime;
    };

    private _altitude = _assetPos # 2;
    if (_altitude < WL_COMBAT_AIR_MINALT) then {
        continue;
    };

    _assetInCombatAirArea = [_assetInCombatAirArea, [], { cameraOn distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    private _combatAirArea = _assetInCombatAirArea # 0;

    [_asset, _combatAirArea, true] spawn DIS_fnc_combatAirPatrol;
    uiSleep 5;
};