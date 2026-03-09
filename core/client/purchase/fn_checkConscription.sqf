#include "includes.inc"
private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
if (!_isSquadLeader) exitWith {
    [false, "Only squad leaders can conscript."] ;
};

private _canTravelToPriority = [false] call WL2_fnc_travelTeamPriority;
if (!_canTravelToPriority) exitWith {
    [false, "No team priority that can be travelled to designated."] ;
};

[true, ""];