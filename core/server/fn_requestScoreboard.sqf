#include "includes.inc"
private _scoreboardResults = missionNamespace getVariable ["WL2_scoreboardResults", []];
missionNamespace setVariable ["WL2_scoreboardResults", _scoreboardResults, [2, remoteExecutedOwner]];