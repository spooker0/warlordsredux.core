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
            player switchMove "Acts_carFixingWheel";

            private _demolishSuccess = false;
            private _startCheckingUnhold = false;
            private _endTime = serverTime + WL_DEMOLITION_STEP_TIME;
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

                private _inputAction = inputAction "Action" + inputAction "ActionContext";
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
                sleep 0.01;
            };

            private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
            private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
            if (_demolishSuccess) then {
                [_demolishableTarget, 1] call WL2_fnc_demolishStep;
                playSoundUI ["hitmarker", _hitmarkerVolume * 2];
            } else {
                playSoundUI ["AddItemFailed", _hitmarkerVolume * 2];
            };

            deleteVehicle _soundSource;
            player switchMove "";

            cameraOn cameraEffect ["Terminate", "BACK"];

            player setVariable ["WL2_sabotageTarget", [serverTime + WL_DEMOLITION_STEP_TIME, "Saboteur"], true];
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