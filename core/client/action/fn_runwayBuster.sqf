#include "includes.inc"
params ["_asset"];
if (isDedicated) exitWith {};

private _enterViewProcessed = false;
while { alive _asset } do {
    uiSleep 0.01;

    if (cameraOn != _asset) then {
        _enterViewProcessed = false;
        uiSleep 0.1;
        continue;
    };

    if (WL_ISDOWN(player)) then {
        switchCamera player;
        continue;
    };

    if (!_enterViewProcessed) then {
        _enterViewProcessed = true;

        ["Initiate", ["ARM BOMB CONTROLS", [
            ["ARM BOMB", "defaultAction"],
            ["Cancel", "Action"],
            ["", "ActionContext"],
            ["", "navigateMenu"]
        ]], 10] spawn WL2_fnc_showHint;

        waitUntil {
            private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
            _inputAction == 0
        };
    };

    private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
    if (_inputAction > 0) then {
        switchCamera player;
        continue;
    };

    if (inputAction "defaultAction" > 0) then {
        switchCamera player;

        [_asset] spawn {
            params ["_asset"];

            private _assetLocation = _asset modelToWorld [0, 0, 0];
            private _soundSource = createSoundSource ["WLRapidBeepSound", _assetLocation, [], 0];
            _soundSource attachTo [_asset, [0, 0, 0]];

            private _startTime = serverTime;
            while { serverTime - _startTime < 5 } do {
                uiSleep 1;
                if (!alive _asset) then {
                    deleteVehicle _soundSource;
                    deleteVehicle _asset;
                    break;
                };
            };

            if (!alive _asset) exitWith {};

            _assetLocation = _asset modelToWorld [0, 0, 0];

            private _explosion = createVehicle ["Bo_Mk82", _assetLocation, [], 0, "NONE"];
            _explosion enableSimulation false;

            [_explosion, [player, player]] remoteExec ["setShotParents", 2];

            private _startTime = serverTime;
            waitUntil {
                uiSleep 0.001;
                private _shotParents = getShotParents _explosion;
                !isNull (_shotParents # 0) || serverTime - _startTime > 5
            };

            _explosion enableSimulation true;
            triggerAmmo _explosion;

            private _craterTypes = [
                "Land_ShellCrater_02_large_F",
                "Land_ShellCrater_02_small_F",
                "SpaceshipCapsule_01_debris_F",
                "CraterLong",
                "CraterLong_02_F"
            ];
            for "_i" from 1 to 8 do {
                private _craterType = selectRandom _craterTypes;

                private _angle = random 360;
                private _distance = random 15;
                private _position = _asset getPos [_distance, _angle];

                private _inCarrierSector = {
                    _position inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
                } count BIS_WL_allSectors > 0;
                if (_inCarrierSector) then {
                    _position set [2, 24];
                    [player, "orderAsset", "vehicle", _position, _craterType, random 360, true, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
                } else {
                    [player, "orderAsset", "vehicle", _position, _craterType, random 360, false, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
                };
            };

            deleteVehicle _soundSource;
            deleteVehicle _asset;
        };

        break;
    };
};

while { alive _asset } do {
    uiSleep 0.01;
    if (cameraOn == _asset) then {
        switchCamera player;
        continue;
    };
};