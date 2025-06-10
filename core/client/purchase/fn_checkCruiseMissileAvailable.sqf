#include "includes.inc"

private _timeout = missionNamespace getVariable ["WL2_cruiseMissileTimeout", 0];
if (serverTime < _timeout) exitWith {
    private _timeLeft = [_timeout - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format ["Cruise missiles on cooldown: %1", _timeLeft]];
};

private _hasCarrierSector = (BIS_WL_sectorsArray # 0) select {
    _x getVariable ["WL2_isAircraftCarrier", false]
};
if (count _hasCarrierSector > 0) then {
    [true, ""]
} else {
    [false, "No aircraft carriers available."];
};