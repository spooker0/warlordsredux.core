#include "includes.inc"
"RequestMenu_close" call WL2_fnc_setupUI;

private _display = createDialog ["RscWLBrowserMenu", true];
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\ewar.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

uiNamespace setVariable ["WL2_ewarDisplay", _display];
player setVariable ["WL2_isUsingEW", true, [2, clientOwner]];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];

    private _puzzleVar = format ["WL2_ewarCurrentPuzzle_%1", BIS_WL_playerSide];
    private _puzzle = missionNamespace getVariable [_puzzleVar, ""];
    private _solution = missionNamespace getVariable ["WL2_ewarCurrentSolution", ""];
    private _key = missionNamespace getVariable ["WL2_ewarCurrentKey", "123456789"];

    private _friendlySignalVar = format ["WL2_ewarSignal_%1", BIS_WL_playerSide];
    private _friendlySignal = missionNamespace getVariable [_friendlySignalVar, 500];

    private _hostileSignalVar = format ["WL2_ewarSignal_%1", BIS_WL_enemySide];
    private _hostileSignal = missionNamespace getVariable [_hostileSignalVar, 500];

    private _script = format ["initScreen('%1', '%2', '%3', %4, %5);", _puzzle, _solution, _key, _friendlySignal, _hostileSignal];
    _texture ctrlWebBrowserAction ["ExecJS", _script];

    [_texture] spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            uiSleep 1;
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

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    if (_message == "wrong") exitWith {
        playSoundUI ["a3\sounds_f\vehicles\air\CAS_01\noise.wss", 1, 1, false, 4];
        player setVariable ["WL2_canAccessEW", false];
        closeDialog 0;
    };

    [player, "boost", _message] remoteExec ["WL2_fnc_handleClientRequest", 2];

    true;
}];