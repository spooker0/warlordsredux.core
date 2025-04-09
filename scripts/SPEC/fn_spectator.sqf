#include "constants.inc"

WL_IsSpectator = true;

player setVariable ["ShowHeader", false];
player setVariable ["ShowCameraButtons", false];
player setVariable ["ShowControlsHelper", false];
["Initialize", [player, [], true]] call BIS_fnc_EGSpectator;

[SPEC_DISPLAY] spawn GFE_fnc_earplugs;

// hide spectator on land
player setPosASL [2304.97, 9243.11, 11.5];
player allowDamage false;
[player] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

private _osdDisplay = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
_osdDisplay closeDisplay 0;

0 spawn SPEC_fnc_spectatorSetup;
0 spawn SPEC_fnc_spectatorFeedback;
0 spawn SPEC_fnc_spectatorMap;
0 spawn SPEC_fnc_spectatorTarget;
0 spawn SPEC_fnc_spectatorUpdateList;
addMissionEventHandler ["Draw3D", SPEC_fnc_spectatorDraw3d];