#include "includes.inc"
private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (!isNull _display) exitWith {
    "scoreboard" cutText ["", "PLAIN"];
};
"scoreboard" cutRsc ["RscWLScoreboardMenu", "PLAIN", -1, true, true];
_display = uiNamespace getVariable "RscWLScoreboardMenu";

private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["LoadFile", "src\ui\scoreboard.html"];

[] remoteExec ["WL2_fnc_generateScoreboard", 2];

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
                "renderScoreboard(JSON.parse(atob(""%1"")), %2);",
                _scoreboardDataText,
                str _firstRender
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
            _firstRender = false;
            sleep 1;
        };
    };
}];