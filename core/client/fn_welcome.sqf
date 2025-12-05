#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\welcome.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _menuKey = actionKeysNames ["gear", 1, "Combo"];
    private _pingKey = actionKeysNames ["TacticalPing", 1, "Combo"];
    private _pttKey = actionKeysNames ["pushToTalk", 1, "Combo"];
    private _chatKey = actionKeysNames ["chat", 1, "Combo"];
    private _revealKey = actionKeysNames ["revealTarget", 1, "Combo"];

    private _textInfo = [
        [localize "WL2_InfoText_1", "text"],
        [localize "WL2_InfoText_2", "text"],
        [localize "WL2_InfoText_3", "heading"],
        [format [localize "WL2_InfoText_4", _menuKey], "text"],
        [format [localize "WL2_InfoText_5", _menuKey], "text"],
        [format [localize "WL2_InfoText_6", _pingKey], "text"],
        [format [localize "WL2_InfoText_7", _pttKey, _chatKey], "text"],
        [localize "WL2_InfoText_8", "heading"],
        [localize "WL2_InfoText_9", "text"],
        [localize "WL2_InfoText_10", "text"],
        [format [localize "WL2_InfoText_11", _revealKey], "text"]
    ];
    private _textInfoJSON = _texture ctrlWebBrowserAction ["ToBase64", toJSON _textInfo];

    private _script = format ["populateTextInfo(atobr(""%1""));", _textInfoJSON];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };
}];