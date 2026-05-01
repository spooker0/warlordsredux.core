#include "includes.inc"

private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (!isNull _display) exitWith {
    _display closeDisplay 1;
};

"scoreboard" cutRsc ["RscWLScoreboardMenu", "PLAIN", -1, true, true];
_display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];

private _texture = _display displayCtrl 5502;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\scoreboard.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

[] remoteExec ["WL2_fnc_requestScoreboard", 2];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    [_texture] spawn {
        params ["_texture"];
        private _playerUid = getPlayerUID player;
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

            private _bluforRating = 0;
            private _opforRating = 0;
            private _bluforPlayers = 0;
            private _opforPlayers = 0;
            {
                private _rating = _x getVariable ["WL2_playerRating", WL_RATING_STARTER];
                if (side group _x == west) then {
                    _bluforRating = _bluforRating + _rating;
                    _bluforPlayers = _bluforPlayers + 1;
                };
                if (side group _x == east) then {
                    _opforRating = _opforRating + _rating;
                    _opforPlayers = _opforPlayers + 1;
                };
            } forEach allPlayers;

            private _bluforAverage = if (_bluforPlayers > 0) then {
                _bluforRating / _bluforPlayers
            } else {
                WL_RATING_STARTER
            };
            private _opforAverage = if (_opforPlayers > 0) then {
                _opforRating / _opforPlayers
            } else {
                WL_RATING_STARTER
            };

            private _script = format [
                "renderScoreboard(atobr(""%1""), %2, %3);",
                _scoreboardDataText,
                _bluforAverage,
                _opforAverage
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
            uiSleep 0.5;
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