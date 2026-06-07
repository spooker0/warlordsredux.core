#include "includes.inc"
params ["_control"];

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _existingMenu = _display getVariable ["SQD_contextMenu", controlNull];
if (!isNull _existingMenu) then {
    ctrlDelete _existingMenu;
};

private _playerId = getPlayerID player;

private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
if (count _squad == 0) exitWith {};

private _squadLocked = _squad getOrDefault ["locked", false];
private _isSquadLeader = ["isSquadLeader", [_playerId]] call SQD_fnc_query;
if (!_isSquadLeader && _squadLocked) exitWith {
    playSoundUI ["AddItemFailed", 1];
    ["Only squad leader can invite to a locked squad."] call WL2_fnc_smoothText;
};

private _contextMenu = _display ctrlCreate ["SQD_Menu_Contextual", -1];
_display setVariable ["SQD_contextMenu", _contextMenu];

private _unassignedPlayers = ["getUnsquaddedPlayers", [side group player]] call SQD_fnc_query;

getMousePosition params ["_mouseX", "_mouseY"];
_contextMenu ctrlSetPosition [_mouseX, _mouseY, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H * count _unassignedPlayers];
_contextMenu ctrlCommit 0;

{
    private _player = _x;

    private _inviteButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
    _inviteButton ctrlSetPosition [0, SQD_LAYOUT_CONTEXT_H * _forEachIndex, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];

    _inviteButton ctrlSetText format ["INVITE %1", name _player];
    _inviteButton ctrlCommit 0;

    _inviteButton setVariable ["SQD_member", getPlayerID _player];
    _inviteButton ctrlAddEventHandler ["ButtonClick", {
        params ["_button"];
        private _display = ctrlParent _button;
        private _player = _button getVariable ["SQD_member", objNull];

        ["invite", [_player]] spawn SQD_fnc_client;
    }];
} forEach _unassignedPlayers;

private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
ctrlSetFocus _dummyButton;