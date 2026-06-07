#include "includes.inc"
params ["_control"];

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _player = _control getVariable ["SQD_member", objNull];
if (isNull _player) exitWith {};
if (_player == player) exitWith {};

private _existingMenu = _display getVariable ["SQD_contextMenu", controlNull];
if (!isNull _existingMenu) then {
    ctrlDelete _existingMenu;
};

private _contextMenu = _display ctrlCreate ["SQD_Menu_Contextual", -1];
_display setVariable ["SQD_contextMenu", _contextMenu];

getMousePosition params ["_mouseX", "_mouseY"];
_contextMenu ctrlSetPosition [_mouseX, _mouseY, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H * 2];
_contextMenu ctrlCommit 0;

private _kickButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
_kickButton ctrlSetPosition [0, 0, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_kickButton ctrlSetText "KICK PLAYER";
_kickButton ctrlCommit 0;

_kickButton setVariable ["SQD_member", _player];
_kickButton ctrlAddEventHandler ["ButtonClick", {
    params ["_button"];
    private _display = ctrlParent _button;
    private _player = _button getVariable ["SQD_member", objNull];

    private _alreadyWarned = _button getVariable ["SQD_kicking", false];
    if (_alreadyWarned) exitWith {
        if (!isNull _player) then {
            ["kick", [getPlayerID _player]] spawn SQD_fnc_client;
        };

        private _contextMenu = _display getVariable ["SQD_contextMenu", controlNull];
        if (!isNull _contextMenu) then {
            ctrlDelete _contextMenu;
        };
    };

    _button setVariable ["SQD_kicking", true];
    _button ctrlSetText format ["CONFIRM: KICK %1", name _player];
}];

private _promoteButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
_promoteButton ctrlSetPosition [0, SQD_LAYOUT_CONTEXT_H, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_promoteButton ctrlSetText "PROMOTE TO LEADER";
_promoteButton ctrlCommit 0;

_promoteButton setVariable ["SQD_member", _player];
_promoteButton ctrlAddEventHandler ["ButtonClick", {
    params ["_button"];
    private _display = ctrlParent _button;
    private _player = _button getVariable ["SQD_member", objNull];

    private _alreadyWarned = _button getVariable ["SQD_promoting", false];
    if (_alreadyWarned) exitWith {
        if (!isNull _player) then {
            ["promote", [getPlayerID _player]] spawn SQD_fnc_client;
        };

        private _contextMenu = _display getVariable ["SQD_contextMenu", controlNull];
        if (!isNull _contextMenu) then {
            ctrlDelete _contextMenu;
        };
    };

    _button setVariable ["SQD_promoting", true];
    _button ctrlSetText format ["CONFIRM: PROMOTE %1", name _player];
}];

private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
ctrlSetFocus _dummyButton;