#include "includes.inc"
private _reviveActionId = player addAction [
    "<t color='#00ff00'>Revive</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId", "_arguments"];

            // start revive
            private _reviveTarget = player getVariable ["WL2_reviveTarget", objNull];
            if (isNull _reviveTarget) exitWith {};

            [[0, 8, 2]] call WL2_fnc_actionLockCamera;
            
            player switchMove "AinvPknlMstpSlayWrflDnon_medic";

            private _reviveSuccess = false;
            private _startCheckingUnhold = false;
            private _endTime = serverTime + 5;
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

                private _inputAction = inputAction "Action" + inputAction "ActionContext";
                if (_startCheckingUnhold && _inputAction > 0) then {
                    break;
                };
                if (_inputAction == 0) then {
                    _startCheckingUnhold = true;
                };

                if (serverTime >= _endTime) then {
                    _reviveSuccess = true;
                    break;
                };
                sleep 0.01;
            };

            private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
            private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
            if (_reviveSuccess) then {
                playSoundUI ["AddItemOk", _hitmarkerVolume * 2];

                if (!isNull _reviveTarget) then {
                    [_reviveTarget] remoteExec ["WL2_fnc_revive", _reviveTarget];

                    if (isPlayer [_reviveTarget]) then {
                        private _reviveRewardTimers = player getVariable ["WL_reviveRewardTimers", createHashMap];
                        private _unitTimer = _reviveRewardTimers getOrDefault [hashValue _reviveTarget, 0];
                        if (_unitTimer < serverTime) then {
                            [player, "revived"] remoteExec ["WL2_fnc_handleClientRequest", 2];
                            private _newTimer = serverTime + 300;
                            _reviveRewardTimers set [hashValue _reviveTarget, _newTimer];
                            player setVariable ["WL_reviveRewardTimers", _reviveRewardTimers];
                        };
                    };
                };
            } else {
                playSoundUI ["AddItemFailed", _hitmarkerVolume * 2];
            };

            player setVariable ["WL2_reviveTarget", objNull];
            player switchMove "";
            cameraOn cameraEffect ["Terminate", "BACK"];
        };
    },
    [],
    50,
    false,
    false,
    "",
    "alive (player getVariable ['WL2_reviveTarget', objNull])",
    0,
    false,
    "",
    ""
];
player setVariable ["WL2_reviveActionId", _reviveActionId];


player addAction [
	"<t color='#00ff00'>Hold on longer</t>",
	{
        params ["_target", "_caller", "_actionId", "_arguments"];
        player setVariable ["WL2_downedLiveTime", 90];
        player removeAction _actionId;
	},
	nil,
	1.5,
	true,
	true,
	"",
	"lifeState player == 'INCAPACITATED'",
	5,
	true,
	"",
	""
];

player addAction [
	"Customization",
	{
        0 spawn WLC_fnc_buildMenu;
	},
	nil,
	1.5,
	true,
	true,
	"",
	"lifeState player == 'INCAPACITATED'",
	5,
	true,
	"",
	""
];

player setCaptive false;
player setVariable ["WL2_alreadyHandled", false, 2];
player setVariable ["WL_unconsciousTime", 0];
setPlayerRespawnTime (getMissionConfigValue ["respawnDelay", 30]);