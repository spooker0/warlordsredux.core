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

        private _flareConfig = WL_UNIT(_aircraft, "flares", []);
        if (count _flareConfig == 0) then {
            continue;
        };

        private _flareCapacity = _flareConfig # 0;
        if (_flareCapacity <= 0) then {
            continue;
        };

        private _bursts = _aircraft getVariable ["DIS_flareBursts", 0];
        private _readyAt = _aircraft getVariable ["DIS_flareReadyAt", 0];
        if (_bursts <= 0 || serverTime < _readyAt) then {
            continue;
        };

        private _incomingMissiles = _aircraft getVariable ["WL_incomingMissiles", []];
        _incomingMissiles = _incomingMissiles select {
            private _missileDefeated = _x getVariable ["DIS_missileDefeated", false];
            alive _x && !_missileDefeated && isNull attachedTo _x;
        };

        if (count _incomingMissiles == 0) then {
            private _sensorThreats = getSensorThreats _aircraft;
            if (count _sensorThreats > 0) then {
                _aircraft setVariable ["DIS_flareSinglesMode", true];
                [_aircraft, _pilot] call DIS_fnc_useFlareBurst;
            };

            continue;
        };

        {
            private _window = [_aircraft, _x] call DIS_fnc_getFlareWindow;
            if (count _window == 0) then {
                _aircraft setVariable ["DIS_flareSinglesMode", true];
                [_aircraft, _pilot] call DIS_fnc_useFlareBurst;
                break;
            };

            _window params ["_windowMin", "_windowMid", "_windowMax", "_windowDistance", "_windowInRange"];

            if (_windowInRange) then {
                _aircraft setVariable ["DIS_flareSinglesMode", false];
                [_aircraft, _pilot] call DIS_fnc_useFlareBurst;
                break;
            };
        } forEach _incomingMissiles;
    } forEach _aircraftToFlare;
};