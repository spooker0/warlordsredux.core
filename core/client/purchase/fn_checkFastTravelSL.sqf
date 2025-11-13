#include "includes.inc"
private _squadLeader = ["getSquadLeaderForPlayer", [getPlayerID player]] call SQD_fnc_query;

if (_squadLeader == player) exitWith {
    [false, localize "STR_SQUADS_fastTravelSquadLeaderInvalid"];
};

if (!alive _squadLeader || lifeState _squadLeader == "INCAPACITATED" || (vehicle _squadLeader == _squadLeader && !(isTouchingGround _squadLeader))) exitWith {
    [false, localize "STR_SQUADS_fastTravelSquadLeaderUnavailable"];
};

[true, ""];