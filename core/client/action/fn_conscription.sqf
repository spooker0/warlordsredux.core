#include "includes.inc"
params ["_conscripter"];

private _side = side group player;
if (side group _conscripter != _side) exitWith {};
if (WL_IsSpectator) exitWith {};

private _canBuy = uiNamespace getVariable ["WL2_canBuy", true];
if (!_canBuy) exitWith {};

private _modifyVehicleMenu = findDisplay 5300;
if (!isNull _modifyVehicleMenu) exitWith {};

uiSleep 0.1;

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
if (WL_ISUP(player) && cameraOn != player) exitWith {};

private _lastPriorityConscriptedTo = player getVariable ["WL2_lastPriorityConscriptedTo", objNull];
private _sectorArea = _teamPriority getVariable ["objectAreaComplete", ""];
private _defaultSelection = _lastPriorityConscriptedTo != _teamPriority && !(player inArea _sectorArea);

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _hideConscriptionNotices = _settingsMap getOrDefault ["hideConscriptionNotices", false];
if (_hideConscriptionNotices && !_defaultSelection) exitWith {};

private _teamPriorityTypeVar = format ["WL2_teamPriorityType_%1", _side];
private _teamPriorityType = missionNamespace getVariable [_teamPriorityTypeVar, ""];

private _travelPriorityText = switch (_teamPriorityType) do {
    case "asset": {
        [_teamPriority] call WL2_fnc_getAssetTypeName
    };
    case "fob": {
        "Forward Base"
    };
    case "stronghold": {
        "Stronghold"
    };
    case "sector": {
        _teamPriority getVariable ["WL2_name", "Unknown"]
    };
    default {
        "???"
    };
};
private _callText = format [localize "STR_WL_conscriptMessage", name _conscripter, _travelPriorityText];

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

        private _teamPriorityVar = format ["WL2_teamPriority_%1", BIS_WL_playerSide];
        private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
        player setVariable ["WL2_lastPriorityConscriptedTo", _teamPriority];
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
    10, _defaultSelection
] spawn WL2_fnc_timedPrompt;