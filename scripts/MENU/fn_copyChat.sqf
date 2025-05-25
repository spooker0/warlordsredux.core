#include "constants.inc"

params ["_control", "_limit"];

private _display = ctrlParent _control;
private _chatHistory = uiNamespace getVariable ["WL2_chatHistory", []];
if (_limit != -1 && count _chatHistory > _limit) then {
    _chatHistory = [_chatHistory, -_limit] call BIS_fnc_subSelect;
};
private _chatHistoryText = _chatHistory apply {
    private _name = _x # 1;
    private _text = _x # 2;

    format ["%1: %2", _name, _text]
};
private _textToCopy = _chatHistoryText joinString endl;
uiNamespace setVariable ["display3DENCopy_data", ["Copy Text", _textToCopy]];

private _copyInterface = _display createDisplay "display3denCopy";
private _copyText = "";
waitUntil {
    _copyText = ctrlText (_copyInterface displayCtrl 202);
    _copyText == _textToCopy;
};

private _copyButton = _copyInterface displayCtrl 204;
_copyButton ctrlSetTooltip "Cannot copy text to clipboard in MP.";
_copyButton ctrlEnable false;