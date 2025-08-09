#include "includes.inc"
params ["_control", "_textToCopy"];

private _display = ctrlParent _control;
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