#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = createDialog ["RscWLBrowserMenu", true];
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
        [localize "STR_WL_mapInfoText1", "text"],
        [localize "STR_WL_mapInfoText2", "text"],
        [localize "STR_WL_mapInfoText3", "heading"],
        [format [localize "STR_WL_mapInfoText4", _menuKey], "text"],
        [format [localize "STR_WL_mapInfoText5", _menuKey], "text"],
        [format [localize "STR_WL_mapInfoText6", _pingKey], "text"],
        [format [localize "STR_WL_mapInfoText7", _pttKey, _chatKey], "text"],
        [localize "STR_WL_mapInfoText8", "heading"],
        [localize "STR_WL_mapInfoText9", "text"],
        [localize "STR_WL_mapInfoText10", "text"],
        [format [localize "STR_WL_mapInfoText11", _revealKey], "text"]
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