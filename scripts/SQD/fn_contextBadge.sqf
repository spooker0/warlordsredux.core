#include "includes.inc"
params ["_control"];

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _player = _control getVariable ["SQD_player", objNull];
if (isNull _player) exitWith {};
if (_player != player) exitWith {};

private _existingMenu = _display getVariable ["SQD_contextMenu", controlNull];
if (!isNull _existingMenu) then {
    ctrlDelete _existingMenu;
};

private _contextMenu = _display ctrlCreate ["SQD_Menu_Contextual", -1];
_display setVariable ["SQD_contextMenu", _contextMenu];

getMousePosition params ["_mouseX", "_mouseY"];
_contextMenu ctrlSetPosition [_mouseX, _mouseY, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_contextMenu ctrlCommit 0;

private _changeBadgeButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
_changeBadgeButton ctrlSetPosition [0, 0, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_changeBadgeButton ctrlSetText "CHANGE MY BADGE";
_changeBadgeButton ctrlCommit 0;

_changeBadgeButton ctrlAddEventHandler ["ButtonClick", {
    params ["_button"];
    private _display = ctrlParent _button;
    _display closeDisplay 0;
    0 spawn RWD_fnc_badgeMenu;
}];

private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
ctrlSetFocus _dummyButton;