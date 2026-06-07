#include "includes.inc"
params ["_control"];

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _existingMenu = _display getVariable ["SQD_contextMenu", controlNull];
if (!isNull _existingMenu) then {
    ctrlDelete _existingMenu;
};

private _contextMenu = _display ctrlCreate ["SQD_Menu_Contextual", 100];
_display setVariable ["SQD_contextMenu", _contextMenu];

getMousePosition params ["_mouseX", "_mouseY"];
_contextMenu ctrlSetPosition [_mouseX, _mouseY, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H * 3];
_contextMenu ctrlCommit 0;

private _mySquad = ["getSquadForPlayer", [getPlayerID player]] call SQD_fnc_query;
private _isLocked = _mySquad getOrDefault ["locked", false];
private _lockText = if (_isLocked) then {
    "UNLOCK SQUAD"
} else {
    "LOCK SQUAD"
};

private _lockButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
_lockButton ctrlSetPosition [0, 0, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_lockButton ctrlSetText _lockText;
_lockButton ctrlCommit 0;

_lockButton setVariable ["SQD_squadControl", _control];
_lockButton ctrlAddEventHandler ["ButtonClick", {
    params ["_button"];
    ["lock"] spawn SQD_fnc_client;

    private _display = ctrlParent _button;
    private _contextMenu = _display getVariable ["SQD_contextMenu", controlNull];
    if (!isNull _contextMenu) then {
        ctrlDelete _contextMenu;
    };
}];

private _renameButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
_renameButton ctrlSetPosition [0, SQD_LAYOUT_CONTEXT_H, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_renameButton ctrlSetText "RENAME SQUAD";
_renameButton ctrlCommit 0;

_renameButton setVariable ["SQD_squadControl", _control];
_renameButton ctrlAddEventHandler ["ButtonClick", {
    params ["_button"];
    private _display = ctrlParent _button;

    private _contextMenu = _display getVariable ["SQD_contextMenu", controlNull];
    if (!isNull _contextMenu) then {
        ctrlDelete _contextMenu;
    };

    private _squadControl = _button getVariable ["SQD_squadControl", controlNull];
    if (isNull _squadControl) exitWith {};

    private _originalSquadName = ctrlText _squadControl;
    _originalSquadName = trim _originalSquadName;
    _squadControl ctrlShow false;

    private _squadBar = ctrlParentControlsGroup _squadControl;
    private _squadNameEdit = _squadBar controlsGroupCtrl SQD_NAME_EDIT_IDC;
    _squadNameEdit ctrlSetText _originalSquadName;
    _squadNameEdit ctrlSetTextSelection [0, count _originalSquadName];
    _squadNameEdit ctrlShow true;
    ctrlSetFocus _squadNameEdit;

    _display setVariable ["SQD_squadNameEdit", _squadNameEdit];

    _squadNameEdit setVariable ["SQD_originalSquadName", _originalSquadName];
    _squadNameEdit ctrlAddEventHandler ["KeyDown", {
        params ["_edit", "_key", "_shift", "_ctrl", "_alt"];
        if !(_key in [28, 156]) exitWith {};

        private _newSquadName = ctrlText _edit;
        private _originalSquadName = _edit getVariable ["SQD_originalSquadName", ""];
        if (_newSquadName != _originalSquadName) then {
            ["renamed", [_newSquadName]] spawn SQD_fnc_client;
        };

        private _display = ctrlParent _edit;
        _display setVariable ["SQD_squadNameEdit", controlNull];

        true;
    }];

    _squadNameEdit ctrlAddEventHandler ["KillFocus", {
        params ["_edit"];
        private _display = ctrlParent _edit;
        _display setVariable ["SQD_squadNameEdit", controlNull];
    }];
}];

private _disbandButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
_disbandButton ctrlSetPosition [0, SQD_LAYOUT_CONTEXT_H * 2, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
_disbandButton ctrlSetText "DISBAND SQUAD";
_disbandButton ctrlCommit 0;

_disbandButton ctrlAddEventHandler ["ButtonClick", {
    params ["_button"];
    private _display = ctrlParent _button;

    private _alreadyWarned = _button getVariable ["SQD_disbanding", false];
    if (_alreadyWarned) exitWith {
        private _contextMenu = _display getVariable ["SQD_contextMenu", controlNull];
        if (!isNull _contextMenu) then {
            ctrlDelete _contextMenu;
        };

        ["disband"] spawn SQD_fnc_client;
    };

    _button setVariable ["SQD_disbanding", true];
    _button ctrlSetText "CONFIRM: DISBAND SQUAD";
}];

private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
ctrlSetFocus _dummyButton;