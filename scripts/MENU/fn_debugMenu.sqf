#include "constants.inc"

params ["_text"];

if !(getPlayerUID player in getArray (missionConfigFile >> "adminIDs")) exitWith {};

private _display = findDisplay DEBUG_DISPLAY;
if (isNull _display) then {
    _display = createDialog ["MENU_DebugConsole", true];
};

disableSerialization;

private _closeButton = _display displayCtrl DEBUG_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];

private _execServerButton = _display displayCtrl DEBUG_SERVER_EXEC_BUTTON;
private _execClientButton = _display displayCtrl DEBUG_LOCAL_EXEC_BUTTON;

_execServerButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _display = ctrlParent _control;

    private _execEdit = _display displayCtrl DEBUG_EXEC_EDIT;
    private _executionText = ctrlText _execEdit;

    [player, _executionText] remoteExec ['MENU_fnc_execCode', 2];
}];

_execClientButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _display = ctrlParent _control;

    private _execEdit = _display displayCtrl DEBUG_EXEC_EDIT;
    private _executionText = ctrlText _execEdit;

    [player, _executionText] spawn MENU_fnc_execCode;
}];

if (_text != "") then {
    private _execEdit = _display displayCtrl DEBUG_EXEC_EDIT;
    _execEdit ctrlSetText _text;
};