#include "includes.inc"
params ["_conscripter"];

private _side = side group player;
if (side group _conscripter != _side) exitWith {};
if (WL_IsSpectator) exitWith {};

private _modifyVehicleMenu = findDisplay 5300;
if (!isNull _modifyVehicleMenu) exitWith {};

uiSleep 0.1;

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
if (WL_ISUP(player) && cameraOn != player) exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _dontConscriptInSector = _settingsMap getOrDefault ["dontConscriptInSector", false];
private _sectorArea = _teamPriority getVariable ["objectAreaComplete", ""];
if (player inArea _sectorArea && _dontConscriptInSector) exitWith {};

private _callText = format [localize "STR_WL_conscriptMessage", name _conscripter];

private _callbackConfirm = {
    private _queue = uiNamespace getVariable "WL2_timedPromptQueue";
    {
        if (_x # 0 == "conscription") then {
            _x set [1, true];
        };
    } forEach _queue;

    if (WL_ISDOWN(player)) then {
        missionNamespace setVariable ["WL2_isBeingConscripted", true];
        setPlayerRespawnTime 0.1;
        forceRespawn player;

        waitUntil {
            uiSleep 0.1;
            WL_ISUP(player);
        };

        missionNamespace setVariable ["WL2_isBeingConscripted", false];
    };

    if (cameraOn != player) exitWith {};

    private _travelResult = [true] call WL2_fnc_travelTeamPriority;
    if (_travelResult) then {
        playSoundUI ["AddItemOk"];
    } else {
        playSoundUI ["AddItemFailed"];
        [localize "STR_WL_conscriptFailed"] call WL2_fnc_smoothText;
    };
};

private _callbackCancel = {};

[
    "conscription",
    _callText,
    "\a3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa",
    localize "STR_WL_goButton", localize "STR_WL_refuseButton",
    _callbackConfirm, _callbackCancel, [],
    10, true
] spawn WL2_fnc_timedPrompt;