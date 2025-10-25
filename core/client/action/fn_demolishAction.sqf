#include "includes.inc"

private _demolishActionId = player addAction [
    "<t color='#ff0000'>Demolish</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId", "_arguments"];

            // start demolish
            private _demolishableTarget = player getVariable ["WL2_demolishableTarget", objNull];
            if (isNull _demolishableTarget) exitWith {};

            private _isStronghold = !isNull (_demolishableTarget getVariable ["WL_strongholdSector", objNull]);
            private _displayText = if (_isStronghold) then {
                "Stronghold"
            } else {
                [_demolishableTarget] call WL2_fnc_getAssetTypeName
            };
            _displayText = format ["Demolishing %1", _displayText];
            player setVariable ["WL2_sabotageTarget", [serverTime + 20, _displayText], true];

            private _isStronghold = !isNull (_demolishableTarget getVariable ["WL_strongholdSector", objNull]);

            private _cameraPlayerModelSpace = if (!_isStronghold) then {
                private _targetDiff = (player worldToModel (_demolishableTarget modelToWorld [0, 0, 0])) vectorMultiply 2;
                private _height = sizeOf (typeof _demolishableTarget);
                _targetDiff set [2, _height * 0.5 + 2];
                _targetDiff
            } else {
                [0, 10, 5]
            };

            [_cameraPlayerModelSpace] call WL2_fnc_actionLockCamera;

            private _playerPosition = player modelToWorld [0, 0, 0];
            private _soundSource = createSoundSource ["WLDemolitionSound", _playerPosition, [], 0];
            [player, ["Acts_TerminalOpen"]] remoteExec ["switchMove", 0];

            private _demolishSuccess = false;
            private _startCheckingUnhold = false;
            private _demolitionStepTime = if (_isStronghold) then {
                WL_DEMOLITION_STRONGHOLD_STEP_TIME
            } else {
                if (typeof _demolishableTarget == "RuggedTerminal_01_communications_hub_F") then {
                    WL_DEMOLITION_FOB_STEP_TIME
                } else {
                    WL_DEMOLITION_STEP_TIME
                }
            };
            private _endTime = serverTime + _demolitionStepTime;
            while { true } do {
                // interrupts
                if (!alive player) then {
                    break;
                };
                if (lifeState player == "INCAPACITATED") then {
                    break;
                };
                if (!alive _demolishableTarget) then {
                    break;
                };

                private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
                if (_startCheckingUnhold && _inputAction > 0) then {
                    break;
                };
                if (_inputAction == 0) then {
                    _startCheckingUnhold = true;
                };

                if (serverTime >= _endTime) then {
                    _demolishSuccess = true;
                    break;
                };
                uiSleep 0.01;
            };

            if (_demolishSuccess) then {
                [_demolishableTarget, 1] call WL2_fnc_demolishStep;
            } else {
                private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
                private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
                playSoundUI ["AddItemFailed", _hitmarkerVolume * 2];
            };

            deleteVehicle _soundSource;
            [player, [""]] remoteExec ["switchMove", 0];

            cameraOn cameraEffect ["Terminate", "BACK"];

            private _demolitionTargetSide = [_demolishableTarget] call WL2_fnc_getAssetSide;
            if (_demolitionTargetSide == BIS_WL_playerSide) then {
                player setVariable ["WL2_sabotageTarget", [serverTime, ""], true];
            } else {
                player setVariable ["WL2_sabotageTarget", [serverTime + WL_DEMOLITION_STEP_TIME, "Saboteur"], true];
            };
        };
    },
    [],
    50,
    false,
    false,
    "",
    "alive (player getVariable ['WL2_demolishableTarget', objNull])",
    0,
    false,
    "",
    ""
];

player setVariable ["WL2_demolishActionId", _demolishActionId];