#include "includes.inc"
params ["_conscripter"];

private _side = side group player;
if (side group _conscripter != _side) exitWith {};
if (WL_IsSpectator) exitWith {};

uiSleep 1;

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
if (player distance2D _teamPriority < 500) exitWith {};

if (WL_ISUP(player) && vehicle player != player) exitWith {};

private _callText = format [localize "STR_WL_conscriptMessage", name _conscripter];
private _result = [
	localize "STR_WL_conscriptTitle",
	_callText,
	localize "STR_WL_goButton",
    localize "STR_WL_refuseButton"
] call WL2_fnc_prompt;

if (_result) then {
    if (WL_ISDOWN(player)) then {
        setPlayerRespawnTime 0.1;
        forceRespawn player;
    };
    waitUntil {
        uiSleep 0.1;
        WL_ISUP(player);
    };
    private _travelResult = [true] call WL2_fnc_travelTeamPriority;
    if (_travelResult) then {
        playSoundUI ["AddItemOk"];
    } else {
        playSoundUI ["AddItemFailed"];
        [localize "STR_WL_conscriptFailed"] call WL2_fnc_smoothText;
    };
};