#include "constants.inc"

params ["_display", "_selectedOption"];

private _option1Text = _display displayCtrl POLL_OPTION_1;
private _option2Text = _display displayCtrl POLL_OPTION_2;
private _option3Text = _display displayCtrl POLL_OPTION_3;
private _option4Text = _display displayCtrl POLL_OPTION_4;
private _optionsTexts = [
    _option1Text,
    _option2Text,
    _option3Text,
    _option4Text
];

private _pollMap = missionNamespace getVariable ["POLL_PollResults", createHashMap];
private _results = [0, 0, 0, 0];
{
    private _playerId = _x;
    private _optionIndex = _y;
    _results set [_optionIndex, (_results # _optionIndex) + 1];
} forEach _pollMap;

{
    private _optionTextControl = _x;
    private _originalText = _optionTextControl getVariable ["POLL_OptionText", ""];
    private _votes = _results # _forEachIndex;
    if (_forEachIndex == _selectedOption) then {
        _optionTextControl ctrlEnable false;
        _optionTextControl ctrlSetStructuredText parseText format [
            "<t align='left'>%1 (Selected)</t><t align='right'>%2 Votes</t>",
            _originalText,
            _votes
        ];
    } else {
        _optionTextControl ctrlEnable true;
        _optionTextControl ctrlSetStructuredText parseText format [
            "<t align='left'>%1</t><t align='right'>%2 Votes</t>",
            _originalText,
            _votes
        ];
    };
} forEach _optionsTexts;

private _questionText = _display displayCtrl POLL_QUESTION;
ctrlSetFocus _questionText;