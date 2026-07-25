#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = createDialog ["WL_WelcomeDisplay", true];
if (isNull _display) exitWith {};

private _textControl = _display displayCtrl 100;

private _infoMarkers = uiNamespace getVariable ["WL2_infoMarkers", []];
private _structuredText = "";
{
	_x params [["_text", ""], ["_icon", ""], ["_color", ""]];
    private _colorText = switch (_color) do {
        case "ColorRed": {"#FF0000"};
        case "ColorYellow": {"#FFFF00"};
        case "ColorGreen": {"#00FF00"};
        default {"#FFFFFF"};
    };
    private _asterisk = if (_color == "ColorYellow") then {"* "} else {""};
	_structuredText = _structuredText + format ["<t color='%1'>%2%3</t><br/>", _colorText, _asterisk, trim _text];
} forEach _infoMarkers;

_textControl ctrlSetStructuredText parseText _structuredText;

private _closeButton = _display displayCtrl 101;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];