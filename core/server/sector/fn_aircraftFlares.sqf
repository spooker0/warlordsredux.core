#include "includes.inc"
if (!isServer) exitWith {};

while { !BIS_WL_missionEnd } do {
    uiSleep 0.5;

    private _aircraftToFlare = BIS_WL_ownedVehicles_server select {
        _x getVariable ["DIS_cmLauncher", ""] != ""
    } select {
        private _incomingMissiles = _x getVariable ["WL_incomingMissiles", []];
        _incomingMissiles = _incomingMissiles select { alive _x };
        count _incomingMissiles > 0 || count (getSensorThreats _x) > 0
    };

    {
        private _aircraft = _x;
        private _aircraftLauncher = _aircraft getVariable ["DIS_cmLauncher", ""];
        (driver _aircraft) forceWeaponFire [_aircraftLauncher, "Burst"];
    } forEach _aircraftToFlare;
};