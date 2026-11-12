#include "includes.inc"

private _timeout = missionNamespace getVariable [format["WL2_cruiseMissileTimeout_%1", getPlayerUID player], 0];
if (serverTime < _timeout) exitWith {
    private _timeLeft = [_timeout - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format [localize "STR_WL_cruiseMissileCooldown", _timeLeft]];
};

private _teamSectorsData = WL_SECTORS_DATA(BIS_WL_playerSide);
private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];

private _hasCarrierSector = _linkedSectors select {
    _x getVariable ["WL2_isAircraftCarrier", false]
};

if (count _hasCarrierSector > 0) then {
    [true, ""]
} else {
    [false, localize "STR_WL_cruiseMissileNoCarrier"];
};
