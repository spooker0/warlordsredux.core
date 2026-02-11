#include "includes.inc"
params ["_conscripter"];

if (side group _conscripter != side group player) exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _disableConscription = _settingsMap getOrDefault ["disableConscription", false];
if (_disableConscription) exitWith {};

uiSleep 1;

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
        setPlayerRespawnTime 0.5;
        forceRespawn player;
    };
    waitUntil {
        uiSleep 0.2;
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