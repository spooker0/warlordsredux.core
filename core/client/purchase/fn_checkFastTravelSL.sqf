#include "includes.inc"
private _squadLeader = ["getSquadLeaderForPlayer", [getPlayerID player]] call SQD_fnc_query;

if (_squadLeader == player) exitWith {
    [false, localize "STR_WL_ftSquadLeaderInvalid"];
};

if (WL_ISDOWN(_squadLeader)) exitWith {
    [false, localize "STR_WL_ftSquadLeaderUnavailable"];
};

private _position = getPosASL _squadLeader;
if (surfaceIsWater _position && _position # 2 < 5) exitWith {
    [false, localize "STR_WL_ftSquadLeaderUnavailable"];
};

[true, ""];