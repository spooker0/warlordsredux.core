#include "includes.inc"
private _reviveActionId = player addAction [
    "<t color='#00ff00'>Revive</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId", "_arguments"];

            // start revive
            private _reviveTarget = player getVariable ["WL2_reviveTarget", objNull];
            if (isNull _reviveTarget) exitWith {};

            private _isRevive = side group _reviveTarget == BIS_WL_playerSide;

            private _displayText = if (_isRevive) then {
                "REVIVE"
            } else {
                "SECURE"
            };
            private _duration = if (_isRevive) then {
                WL_DURATION_REVIVE
            } else {
                WL_DURATION_SECURE
            };
            private _animation = if (_isRevive) then {
                "AinvPknlMstpSlayWrflDnon_medic"
            } else {
                "Acts_Executioner_Forehand"
            };

            [[0, 8, 2]] call WL2_fnc_actionLockCamera;

            ["Animation", [_displayText, [
                ["Cancel", "Action"],
                ["", "ActionContext"],
                ["", "navigateMenu"]
            ]], _duration, true] spawn WL2_fnc_showHint;

            [player, [_animation]] remoteExec ["switchMove", 0];
            private _actionSuccess = false;
            private _startCheckingUnhold = false;
            private _endTime = serverTime + _duration;
            while { true } do {
                // interrupts
                if (!alive player) then {
                    break;
                };
                if (lifeState player == "INCAPACITATED") then {
                    break;
                };
                if (!alive _reviveTarget) then {
                    break;
                };
                if (lifeState _reviveTarget != "INCAPACITATED") then {
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
                    _actionSuccess = true;
                    break;
                };
                uiSleep 0.01;
            };

            ["Animation"] spawn WL2_fnc_showHint;

            private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
            private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
            if (_actionSuccess) then {
                if (!isNull _reviveTarget) then {
                    if (_isRevive) then {
                        playSoundUI ["AddItemOk", _hitmarkerVolume * 2];
                        [_reviveTarget] remoteExec ["WL2_fnc_revive", _reviveTarget];

                        if (isPlayer [_reviveTarget]) then {
                            private _reviveRewardTimers = player getVariable ["WL_reviveRewardTimers", createHashMap];
                            private _unitTimer = _reviveRewardTimers getOrDefault [hashValue _reviveTarget, 0];
                            if (_unitTimer < serverTime) then {
                                [player, "revived", 50] remoteExec ["WL2_fnc_handleClientRequest", 2];
                                private _newTimer = serverTime + 300;
                                _reviveRewardTimers set [hashValue _reviveTarget, _newTimer];
                                player setVariable ["WL_reviveRewardTimers", _reviveRewardTimers];
                            } else {
                                [player, "revived", 0] remoteExec ["WL2_fnc_handleClientRequest", 2];
                            };
                        } else {
                            [player, "revived", 0] remoteExec ["WL2_fnc_handleClientRequest", 2];
                        };
                    } else {
                        [player, "secure", _reviveTarget] remoteExec ["WL2_fnc_handleClientRequest", 2];
                    };
                };
            } else {
                playSoundUI ["AddItemFailed", _hitmarkerVolume * 2];
            };

            player setVariable ["WL2_reviveTarget", objNull];
            [player, [""]] remoteExec ["switchMove", 0];
            cameraOn cameraEffect ["Terminate", "BACK"];
        };
    },
    [],
    50,
    false,
    false,
    "",
    "alive (player getVariable ['WL2_reviveTarget', objNull]) && cameraOn == player",
    0,
    false,
    "",
    ""
];
player setVariable ["WL2_reviveActionId", _reviveActionId];

player setCaptive false;
player setVariable ["WL2_alreadyHandled", false, 2];
player setVariable ["WL_unconsciousTime", 0];
setPlayerRespawnTime WL_DURATION_RESPAWN;