#include "includes.inc"
// Is squad leader
private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
if (!_isSquadLeader) exitWith {
    [false, "You must be the squad leader."];
};

[true, ""];