#include "includes.inc"

private _canTravelToPriority = [false] call WL2_fnc_travelTeamPriority;
if (!_canTravelToPriority) exitWith {
    [false, localize "STR_WL_conscriptionNoPriority"] ;
};

[true, ""];
