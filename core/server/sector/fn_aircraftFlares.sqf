#include "includes.inc"
if (!isServer) exitWith {};

while { !BIS_WL_missionEnd } do {
    uiSleep 0.01;

    private _aircraftToFlare = BIS_WL_ownedVehicles_server select {
        alive _x
    } select {
        local _x
    } select {
        _x isKindOf "Air"
    };

    if (count _aircraftToFlare == 0) then {
        uiSleep 2;
        continue;
    };

    {
        private _aircraft = _x;
        private _pilot = driver _aircraft;
        if (!alive _pilot || isPlayer _pilot) then {
            continue;
        };

        private _flareCapacity = WL_UNIT(_aircraft, "flareBursts", 0);
        if (_flareCapacity <= 0) then {
            continue;
        };

        private _bursts = _aircraft getVariable ["DIS_flareBursts", 0];
        private _readyAt = _aircraft getVariable ["DIS_flareReadyAt", 0];
        if (_bursts <= 0 || serverTime < _readyAt) then {
            continue;
        };

        private _incomingMissiles = _aircraft getVariable ["WL_incomingMissiles", []];
        {
            private _window = [_aircraft, _x] call DIS_fnc_getFlareWindow;
            if (count _window == 0) then {
                continue;
            };

            _window params ["_windowMin", "_windowMid", "_windowMax", "_windowDistance", "_windowInRange"];

            if (_windowInRange) then {
                [_aircraft, _pilot] call DIS_fnc_useFlareBurst;
                break;
            };
        } forEach _incomingMissiles;
    } forEach _aircraftToFlare;
};