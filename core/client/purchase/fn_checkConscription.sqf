#include "includes.inc"
private _canTravelToPriority = [false] call WL2_fnc_travelTeamPriority;
if (!_canTravelToPriority) exitWith {
    [false, "No team priority that can be travelled to designated."] ;
};
[true, ""];