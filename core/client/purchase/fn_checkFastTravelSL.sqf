#include "includes.inc"
private _squadLeader = ["getSquadLeaderForPlayer", [getPlayerID player]] call SQD_fnc_query;

if (_squadLeader == player) exitWith {
    [false, localize "STR_SQUADS_fastTravelSquadLeaderInvalid"];
};

if (!alive _squadLeader || lifeState _squadLeader == "INCAPACITATED") exitWith {
    [false, localize "STR_SQUADS_fastTravelSquadLeaderUnavailable"];
};

private _position = getPosASL _squadLeader;
if (surfaceIsWater _position && _position # 2 < 5) exitWith {
    [false, localize "STR_SQUADS_fastTravelSquadLeaderUnavailable"];
};

[true, ""];