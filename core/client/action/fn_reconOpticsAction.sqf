#include "..\..\warlords_constants.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _clearReconOptics = {
    "reconOptics" cutText ["", "PLAIN"];
    _display = objNull;
};

private _display = objNull;
private _instructionsDisplay = controlNull;
private _reconOpticsLabel = controlNull;

private _addReconOptics = {
    if !(isNull _display) exitWith {};
    "reconOptics" cutRsc ["RscWLReconOpticsDisplay", "PLAIN"];
    _display = uiNamespace getVariable ["RscWLReconOpticsDisplay", displayNull];

    _reconOpticsLabel = _display displayCtrl 26000;

    _instructionsDisplay = _display displayCtrl 26001;
    _instructionsDisplay ctrlSetStructuredText parseText format [
        "<t size='1.2'><t align='left'>Scan</t><t align='right'>[%1]</t></t>",
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
    _reconOpticsLabel ctrlSetStructuredText parseText "<t color='#33ff33' align='center'>RECON OPTICS READY</t>";

	if (inputAction "lockTarget" > 0) then {
        waitUntil {
            inputAction "lockTarget" == 0
        };

        _reconOpticsLabel ctrlSetStructuredText parseText "<t color='#ff3333' align='center'>RECON OPTICS WAIT</t>";
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
        private _remoteTargets = (listRemoteTargets BIS_WL_playerSide) select { _x # 1 > -10 } apply { _x # 0 };

        [_unitsInArea, 20] remoteExec ["WL2_fnc_reportTargets", BIS_WL_playerSide];

        _unitsInArea = _unitsInArea select {
            !(_x in _remoteTargets)
        };
        if (count _unitsInArea > 0) then {
            playSoundUI ["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true];
            _instructionsDisplay ctrlShow false;
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

        sleep 1;
    };

    sleep 0.001;
};

call _clearReconOptics;