#include "includes.inc"
private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (!isNull _display) exitWith {
    "scoreboard" cutText ["", "PLAIN"];
};
"scoreboard" cutRsc ["RscWLScoreboardMenu", "PLAIN", -1, true, true];
_display = uiNamespace getVariable "RscWLScoreboardMenu";

private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["LoadFile", "src\ui\scoreboard.html"];

missionNamespace setVariable ["WL2_scoreboardResults", []];
[] remoteExec ["WL2_fnc_generateScoreboard", 2];

private _startTime = serverTime;
private _scoreboardResults = [];
waitUntil {
    sleep 0.1;
    _scoreboardResults = missionNamespace getVariable ["WL2_scoreboardResults", []];
    !isNull _texture || serverTime - _startTime > 5 || count _scoreboardResults > 0
};

if (count _scoreboardResults > 0) then {
    uiNamespace setVariable ["WL2_scoreboardData", _scoreboardResults];
};

// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _scoreboardDataText = toJSON (uiNamespace getVariable ["WL2_scoreboardData", []]);
_scoreboardDataText = _texture ctrlWebBrowserAction ["ToBase64", _scoreboardDataText];

private _script = format [
    "renderScoreboard(JSON.parse(atob(""%1"")));",
    _scoreboardDataText
];
_texture ctrlWebBrowserAction ["ExecJS", _script];
