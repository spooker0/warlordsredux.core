#include "includes.inc"
params ["_action"];

if (WL_ISUP(player)) exitWith {};

private _deadActions = [
    true,
    { 0 spawn WL2_fnc_vehicleManager; },
    { 0 spawn RWD_fnc_badgeMenu; },
    { 0 spawn MENU_fnc_reportMenu; },
    { 0 spawn MENU_fnc_settingsMenuInit; },
    { 0 spawn SQD_fnc_menu; }
];

private _currentActionId = uiNamespace getVariable ["WL2_deadActionId", 0];
private _actionCount = count _deadActions;

private _idHasChanged = false;
if (_action == "Next") then {
    private _previousId = _currentActionId;
    _currentActionId = (_currentActionId + 1) min (_actionCount - 1);
    _idHasChanged = _previousId != _currentActionId;
};
if (_action == "Previous") then {
    private _previousId = _currentActionId;
    _currentActionId = (_currentActionId - 1) max 0;
    _idHasChanged = _previousId != _currentActionId;
};

private _currentAction = _deadActions select _currentActionId;
private _actionIsHold = _currentAction isEqualType true;
if (_action == "Select") then {
    if (!_actionIsHold) then {
        call _currentAction;
    };
};

uiNamespace setVariable ["WL2_deadActionId", _currentActionId];

private _display = uiNamespace getVariable ["RscWLDeathInfoMenu", displayNull];
if (isNull _display) exitWith {};
private _texture = _display displayCtrl 5502;

if (_idHasChanged) then {
    playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
    private _script = format ["updateSelectedItem(""%1"");", _currentActionId];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
};

if (!alive player) exitWith {
    _texture ctrlWebBrowserAction ["ExecJS", "cancelHold();"];
};

if (_actionIsHold) then {
    if (_action == "Select") then {
        _texture ctrlWebBrowserAction ["ExecJS", "startHold();"];
    };
    if (_action == "Unselect") then {
        _texture ctrlWebBrowserAction ["ExecJS", "cancelHold();"];
    };
};