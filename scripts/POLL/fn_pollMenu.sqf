#include "constants.inc"

private _display = findDisplay POLL_DISPLAY;

if (isNull _display) then {
    _display = createDialog ["POLL_MenuUI", true];
};

disableSerialization;

private _closeButton = _display displayCtrl POLL_CLOSE;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];

private _activePoll = missionNamespace getVariable ["POLL_ActivePoll", []];

private _questionText = _display displayCtrl POLL_QUESTION;
private _option1Text = _display displayCtrl POLL_OPTION_1;
private _option2Text = _display displayCtrl POLL_OPTION_2;
private _option3Text = _display displayCtrl POLL_OPTION_3;
private _option4Text = _display displayCtrl POLL_OPTION_4;

private _questionEdit = _display displayCtrl POLL_OPTION_EDIT_QUESTION;
private _option1Edit = _display displayCtrl POLL_OPTION_EDIT_1;
private _option2Edit = _display displayCtrl POLL_OPTION_EDIT_2;
private _option3Edit = _display displayCtrl POLL_OPTION_EDIT_3;
private _option4Edit = _display displayCtrl POLL_OPTION_EDIT_4;
private _submitPoll = _display displayCtrl POLL_OPTION_EDIT_SUBMIT;

private _optionsTexts = [
    _option1Text,
    _option2Text,
    _option3Text,
    _option4Text
];
{
    _x ctrlSetText "";
    _x ctrlShow false;
} forEach _optionsTexts;

private _optionEdits = [
    _questionEdit,
    _option1Edit,
    _option2Edit,
    _option3Edit,
    _option4Edit
];
{
    _x ctrlShow false;
} forEach _optionEdits;

_submitPoll ctrlShow false;

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
if (count _activePoll == 0) exitWith {
    if (_isAdmin || _isModerator) then {
        _questionEdit ctrlShow true;
        _option1Edit ctrlShow true;
        _option2Edit ctrlShow true;
        _option3Edit ctrlShow true;
        _option4Edit ctrlShow true;

        _questionText ctrlShow false;
        _option1Text ctrlShow false;
        _option2Text ctrlShow false;
        _option3Text ctrlShow false;
        _option4Text ctrlShow false;

        _submitPoll ctrlShow true;
        _submitPoll ctrlSetText "Create Poll";
        _submitPoll ctrlAddEventHandler ["ButtonClick", {
            params ["_control"];
            private _display = ctrlParent _control;

            private _questionEdit = _display displayCtrl POLL_OPTION_EDIT_QUESTION;
            private _option1Edit = _display displayCtrl POLL_OPTION_EDIT_1;
            private _option2Edit = _display displayCtrl POLL_OPTION_EDIT_2;
            private _option3Edit = _display displayCtrl POLL_OPTION_EDIT_3;
            private _option4Edit = _display displayCtrl POLL_OPTION_EDIT_4;

            private _question = ctrlText _questionEdit;
            private _option1 = ctrlText _option1Edit;
            private _option2 = ctrlText _option2Edit;
            private _option3 = ctrlText _option3Edit;
            private _option4 = ctrlText _option4Edit;

            private _options = [_option1, _option2, _option3, _option4];
            _options = _options select { _x != "" };

            missionNamespace setVariable ["POLL_ActivePoll", [_question, _options, -1], true];
            closeDialog 0;
        }];
    } else {
        _questionText ctrlSetText "No active poll.";
    };
};

if (_isAdmin || _isModerator) then {
    _submitPoll ctrlShow true;
    _submitPoll ctrlSetText "Reset Poll";
    _submitPoll ctrlAddEventHandler ["ButtonClick", {
        missionNamespace setVariable ["POLL_PollResults", createHashMap, true];
        missionNamespace setVariable ["POLL_ActivePoll", [], true];
        closeDialog 0;
    }];
};

private _question = _activePoll # 0;
_questionText ctrlSetText _question;

private _options = _activePoll # 1;
private _vote = _activePoll # 2;
{
    private _optionTextControl = _optionsTexts # _forEachIndex;

    if (_vote == _forEachIndex) then {
        _optionTextControl ctrlSetText format ["%1 (Selected)", _x];
        _optionTextControl ctrlEnable false;
    } else {
        _optionTextControl ctrlSetText _x;
        _optionTextControl ctrlEnable true;
    };

    _optionTextControl ctrlShow true;
    _optionTextControl setVariable ["POLL_Option", _forEachIndex];
    _optiontextControl setVariable ["POLL_OptionText", _x];

    _optionTextControl ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        private _optionIndex = _control getVariable ["POLL_Option", -1];
        [_optionIndex, player] remoteExec ["POLL_fnc_selectOption", 2];

        private _activePoll = missionNamespace getVariable ["POLL_ActivePoll", []];
        _activePoll set [2, _optionIndex];

        [ctrlParent _control, _optionIndex] call POLL_fnc_updatePollMenu;
    }];
} forEach _options;

[_display] spawn {
    params ["_display"];
    while { !isNull _display } do {
        private _activePoll = missionNamespace getVariable ["POLL_ActivePoll", []];
        private _selection = _activePoll # 2;
        [_display, _selection] call POLL_fnc_updatePollMenu;
        sleep 0.1;
    };
};