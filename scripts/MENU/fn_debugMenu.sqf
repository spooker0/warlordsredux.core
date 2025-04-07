#include "constants.inc"

if !(getPlayerUID player in getArray (missionConfigFile >> "adminIDs")) exitWith {};

private _display = findDisplay DEBUG_DISPLAY;
if (isNull _display) then {
    _display = (findDisplay 46) createDisplay "MENU_DebugConsole";
};

disableSerialization;

private _closeButton = _display displayCtrl DEBUG_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    (ctrlParent _control) closeDisplay 1;
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