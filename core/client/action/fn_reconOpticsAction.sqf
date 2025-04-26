#include "..\..\warlords_constants.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _clearReconOptics = {
    "reconOptics" cutText ["", "PLAIN"];
    _display = objNull;
};

private _display = objNull;

private _addReconOptics = {
    if !(isNull _display) exitWith {};
    "reconOptics" cutRsc ["RscWLReconOpticsDisplay", "PLAIN"];
    _display = uiNamespace getVariable ["RscWLReconOpticsDisplay", displayNull];

    private _instructionsDisplay = _display displayCtrl 26001;
    _instructionsDisplay ctrlSetStructuredText parseText format [
        "<t size='1.2'><t align='left'>Scan</t><t align='right'>[%1] or [%2]</t></t>",
        (actionKeysNames ["defaultAction", 1, "Combo"]) regexReplace ["""", ""],
        (actionKeysNames ["lockTarget", 1, "Combo"]) regexReplace ["""", ""]
    ];
    _instructionsDisplay ctrlCommit 0;
};

while { alive _asset } do {
    if (vehicle player != _asset) then {
        call _clearReconOptics;
        sleep 5;
        continue;
    };

    if (cameraView != "GUNNER") then {
        call _clearReconOptics;
        sleep 0.1;
        continue;
    };

    call _addReconOptics;

	if (inputAction "defaultAction" > 0 || inputAction "lockTarget" > 0) then {
        waitUntil {
            inputAction "defaultAction" == 0 && inputAction "lockTarget" == 0
        };

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
            sleep 0.001;
            continue;
        };

        private _targetIntersection = _targetIntersections # 0 # 0;
        private _area = [ASLtoAGL _targetIntersection, 50, 50, 0, false];
        private _unitsInArea = [BIS_WL_playerSide, _area] call WL2_fnc_detectUnits;
        private _remoteTargets = (listRemoteTargets BIS_WL_playerSide) select { _x # 1 > -10 } apply { _x # 0 };

        {
            BIS_WL_playerSide reportRemoteTarget [_x, 20];
        } forEach _unitsInArea;

        _unitsInArea = _unitsInArea select {
            !(_x in _remoteTargets)
        };
        if (count _unitsInArea > 0) then {
            playSoundUI ["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true];
        };

        private _newTargets = _unitsInArea select {
            !(_x getVariable ["WL_scannedByPlayer", false])
        };
        private _targetPoints = 0;
        {
            private _targetScore = if (_x isKindOf "Man") then {
                30;
            } else {
                100;
            };
            private _side = [_x] call WL2_fnc_getAssetSide;
            if (_side == BIS_WL_enemySide) then {
                _targetScore = _targetScore * 1.5;
            };
            _targetPoints = _targetPoints + _targetScore;
        } forEach _newTargets;

        if (_targetPoints > 0) then {
            [player, "spot", _targetPoints] remoteExec ["WL2_fnc_handleClientRequest", 2];
        };
        {
            _x setVariable ["WL_scannedByPlayer", true];
        } forEach _newTargets;
    };

    sleep 0.001;
};

call _clearReconOptics;