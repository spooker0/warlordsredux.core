#include "includes.inc"

if (!isServer) exitWith {};

private _lastNotifyTime = 0;
while { !BIS_WL_missionEnd } do {
    uiSleep 10;

    private _combatPatrolSectors = BIS_WL_allSectors select {
        _x getVariable ["WL2_combatAirActive", false];
    };

    private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
    private _capForwardAirbases = _forwardBases select {
        _x getVariable ["WL2_combatAirActive", false];
    };
    private _combatAirAreas = _combatPatrolSectors + _capForwardAirbases;

    private _independentAircraft = BIS_WL_guerOwnedVehicles select {
        alive _x;
    } select {
        _x isKindOf "Air";
    } select {
        private _posAGL = _x modelToWorld [0, 0, 0];
        _posAGL # 2 > 50;
    };

    {
        private _asset = _x;

        private _combatAreasForAsset = _combatAirAreas select {
            private _startTime = _x getVariable ["WL2_combatAirStart", 0];
            private _areaRadius = (serverTime - _startTime) * WL_COMBAT_AIR_PERSEC;
            _areaRadius = _areaRadius min WL_COMBAT_AIR_RADIUS;
            _asset inArea [
                getPosASL _x,
                _areaRadius,
                _areaRadius,
                0,
                false
            ];
        };
        if (count _combatAreasForAsset == 0) then {
            continue;
        };
        _combatAreasForAsset = [_combatAreasForAsset, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
        private _targeter = _combatAreasForAsset # 0;

        [_x, _targeter, false] spawn DIS_fnc_combatAirPatrol;
    } forEach _independentAircraft;
};
