#include "includes.inc"
params ["_conscripter"];

private _side = side group player;
if (side group _conscripter != _side) exitWith {};
if (WL_IsSpectator) exitWith {};

uiSleep 1;

playSoundUI ["a3\missions_f_oldman\data\sound\phone_sms\chime\phone_sms_chime_07.wss", 1];

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
if (WL_ISUP(player) && player distance2D _teamPriority < 50) exitWith {};
if (WL_ISUP(player) && vehicle player != player) exitWith {};

private _callText = format [localize "STR_WL_conscriptMessage", name _conscripter];

private _callbackConfirm = {
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

private _callbackCancel = {
    playSoundUI ["AddItemFailed"];
};

[
    _callText,
    localize "STR_WL_goButton", localize "STR_WL_refuseButton",
    _callbackConfirm, _callbackCancel, [],
    10, true
] spawn WL2_fnc_timedPrompt;