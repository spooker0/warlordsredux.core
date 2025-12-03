#include "includes.inc"
if (isDedicated) exitWith {};
["Surrender vote active."] call WL2_fnc_smoothText;
playSoundUI ["air_raid", 3];
uiNamespace setVariable ["WL2_surrenderWarningActive", true];

private _voteEndVar = format ["WL2_voteEnd_%1", BIS_WL_playerSide];

waitUntil {
    uiSleep 0.1;
    private _voteEndTime = missionNamespace getVariable [_voteEndVar, -1];
    _voteEndTime > serverTime;
};

// Wait for the vote end to be fully sent

waitUntil {
    uiSleep 0.1;
    private _voteEndTime = missionNamespace getVariable [_voteEndVar, -1];
    _voteEndTime <= serverTime;
};

uiNamespace setVariable ["WL2_surrenderWarningActive", false];