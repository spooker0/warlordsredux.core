#include "includes.inc"
params ["_asset", "_playerUID", "_reconType"];

if (isDedicated) exitWith {};

if (_playerUID == getPlayerUID player) then {
    ["Recon", ["RECON CONTROLS", [
        ["Scan", "lockTarget"]
    ]], 10] spawn WL2_fnc_showHint;
};

while { alive _asset } do {
    if (cameraOn != _asset) then {
        uiSleep 5;
        continue;
    };

    _asset setVariable ["WL2_reconOpticsReady", true];

	if (inputAction "lockTarget" > 0) then {
        waitUntil {
            inputAction "lockTarget" == 0
        };

        private _side = BIS_WL_playerSide;

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
            uiSleep 1;
            continue;
        };

        private _targetIntersection = _targetIntersections # 0 # 0;
        private _area = [ASLtoAGL _targetIntersection, 125, 125, 0, false];
        private _unitsInArea = [_side, _area] call WL2_fnc_detectUnits;

        if (_reconType == 2) then {
            private _airArea = [ASLtoAGL _targetIntersection, 3000, 3000, 0, false];
            private _airUnitsInArea = [_side, _airArea] call WL2_fnc_detectUnits;
            _airUnitsInArea = _airUnitsInArea select { _x isKindOf "Air" } select {
                private _posAGL = _x modelToWorld [0, 0, 0];
                _posAGL # 2 > 50
            };
            _unitsInArea insert [-1, _airUnitsInArea, true];
        };

        private _minesInScanArea = allMines inAreaArray _area;
        {
            _side revealMine _x;
        } forEach _minesInScanArea;

        [_unitsInArea, 20] remoteExec ["WL2_fnc_reportTargets", _side];

        private _enemiesSpotted = [_unitsInArea] call WL2_fnc_reconReward;
        if (_enemiesSpotted) then {
            playSoundUI ["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true];
        };

        uiSleep 2;
    };

    uiSleep 0.001;
};