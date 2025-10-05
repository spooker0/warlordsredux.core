#include "includes.inc"

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    if (_key in actionKeys "networkStats") then {
        closeDialog 0;
    };
}];

private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\scoreboard.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

[] remoteExec ["WL2_fnc_requestScoreboard", 2];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    [_texture] spawn {
        params ["_texture"];
        private _playerUid = getPlayerUID player;
        private _firstRender = true;
        while { !isNull _texture } do {
            private _scoreboardData = missionNamespace getVariable ["WL2_scoreboardResults", []];
            {
                private _entryUid = _x getOrDefault ["uid", ""];
                if (_entryUid == _playerUid) then {
                    _x set ["isPlayer", true];
                    break;
                };
            } forEach _scoreboardData;
            private _scoreboardDataText = toJSON _scoreboardData;
            _scoreboardDataText = _texture ctrlWebBrowserAction ["ToBase64", _scoreboardDataText];

            private _script = format [
                "renderScoreboard(atob(""%1""), %2);",
                _scoreboardDataText,
                str _firstRender
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
            _firstRender = false;
            sleep 0.5;
        };
    };
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };
    true;
}];