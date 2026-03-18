#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = createDialog ["RscWLBrowserMenu", true];
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\ewar2.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];

    private _friendlySignalVar = format ["WL2_ewarSignal_%1", BIS_WL_playerSide];
    private _friendlySignal = missionNamespace getVariable [_friendlySignalVar, 500];

    private _hostileSignalVar = format ["WL2_ewarSignal_%1", BIS_WL_enemySide];
    private _hostileSignal = missionNamespace getVariable [_hostileSignalVar, 500];

    private _puzzleDifficulty = switch (true) do {
        case (_friendlySignal >= 950): {
            10
        };
        case (_friendlySignal >= 650): {
            5
        };
        case (_friendlySignal >= 350): {
            4
        };
        default { 3 };
    };

    private _script = format ["initScreen('%1', '%2', %3);", _friendlySignal, _hostileSignal, _puzzleDifficulty];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
    _texture setVariable ["WL2_ewarDifficulty", _puzzleDifficulty];

    [_texture] spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            uiSleep 0.5;
            private _friendlySignalVar = format ["WL2_ewarSignal_%1", BIS_WL_playerSide];
            private _friendlySignal = missionNamespace getVariable [_friendlySignalVar, 500];

            private _hostileSignalVar = format ["WL2_ewarSignal_%1", BIS_WL_enemySide];
            private _hostileSignal = missionNamespace getVariable [_hostileSignalVar, 500];

            private _script = format ["updateSignals(%1, %2);", _friendlySignal, _hostileSignal];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
        };
    };
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    if (_message == "done") exitWith {
        playSoundUI ["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1];
        [player, "boost2", _message] remoteExec ["WL2_fnc_handleClientRequest", 2];

        private _difficulty = _texture getVariable ["WL2_ewarDifficulty", 3];
        if (_difficulty >= 10) then {
            ["Time Waster", true] call RWD_fnc_addBadge;
        };

        true;
    };

    if (_message == "click") exitWith {
        playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 1];
        true;
    };

    true;
}];