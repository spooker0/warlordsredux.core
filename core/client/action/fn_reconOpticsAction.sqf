#include "includes.inc"
params ["_asset", "_playerUID"];

if (isDedicated) exitWith {};

if (_playerUID == getPlayerUID player) then {
    ["Recon", ["RECON CONTROLS", [
        ["Scan", "lockTarget"]
    ]], 10] call WL2_fnc_showHint;
};

while { alive _asset } do {
    if (cameraOn != _asset) then {
        sleep 5;
        continue;
    };

    _asset setVariable ["WL2_reconOpticsReady", true];

	if (inputAction "lockTarget" > 0) then {
        waitUntil {
            inputAction "lockTarget" == 0
        };

        _asset setVariable ["WL2_reconOpticsReady", false];
        playSoundUI ["a3\sounds_f\arsenal\weapons\launchers\titan\dry_titan.wss", 1, 1, true];

        private _targetIntersections = lineIntersectsSurfaces [
            AGLToASL positionCameraToWorld [0, 0, 10],
            AGLToASL positionCameraToWorld [0, 0, 4000],
            objNull,
            objNull,
            true,
            1,
            "FIRE",
            "",
            true
        ];

        if (count _targetIntersections == 0) then {
            sleep 1;
            continue;
        };

        private _targetIntersection = _targetIntersections # 0 # 0;
        private _area = [ASLtoAGL _targetIntersection, 125, 125, 0, false];
        private _unitsInArea = [BIS_WL_playerSide, _area] call WL2_fnc_detectUnits;

        [_unitsInArea, 20] remoteExec ["WL2_fnc_reportTargets", BIS_WL_playerSide];

        private _enemiesSpotted = [_unitsInArea] call WL2_fnc_reconReward;
        if (_enemiesSpotted) then {
            playSoundUI ["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true];
        };

        sleep 2;
    };

    sleep 0.001;
};