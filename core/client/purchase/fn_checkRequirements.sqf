#include "..\..\warlords_constants.inc"

params ["_sector", "_requirements"];

private _servicesInSector = _sector getVariable ["WL2_services", []];
if ("H" in _requirements && !("H" in _servicesInSector)) exitWith {
    private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
    private _forwardBases = _potentialBases select {
        player distance2D _x < WL_FOB_RANGE &&
        _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
    };

    if (count _forwardBases > 0) then {
        [true, ""];
    } else {
        [false, "Must be in a sector with a helipad."];
    };
};

private _servicesAvailable = BIS_WL_sectorsArray # 5;
if (_requirements findIf {!(_x in _servicesAvailable)} >= 0) exitWith {
    [false, localize "STR_A3_WL_airdrop_restr1"];
};