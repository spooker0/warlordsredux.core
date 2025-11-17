#include "includes.inc"
private _actionId = player addAction [
	"Control UAV",
	{
        params ["_target", "_caller", "_actionId"];

        private _cursorObject = cursorObject;

        private _isDrone = [_cursorObject] call WL2_fnc_isDrone;
        if (_isDrone) then {
            private _access = [_cursorObject, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                uiNamespace setVariable ["WL2_remoteControlTarget", _cursorObject];
                uiNamespace setVariable ["WL2_remoteControlSeat", "Driver"];
            };
        };

        private _remoteControlTarget = uiNamespace getVariable ["WL2_remoteControlTarget", objNull];
        if (alive _remoteControlTarget && [_remoteControlTarget] call WL2_fnc_isDrone) then {
            switchCamera _remoteControlTarget;
            private _seat = uiNamespace getVariable ["WL2_remoteControlSeat", "Driver"];
            if (_seat == "Driver") then {
                private _driver = driver _remoteControlTarget;
                if (alive _driver) then {
                    player remoteControl _driver;
                } else {
                    uiNamespace setVariable ["WL2_remoteControlSeat", "Gunner"];
                    player remoteControl _remoteControlTarget;
                };
            } else {
                private _gunner = gunner _remoteControlTarget;
                if (alive _gunner) then {
                    player remoteControl _gunner;
                } else {
                    uiNamespace setVariable ["WL2_remoteControlSeat", "Driver"];
                    player remoteControl _remoteControlTarget;
                };
            };
        };
	},
	[],
	1,
	false,
	true,
	"",
	"call WL2_fnc_controlUAVEligibility",
    0,
	false
];
player setVariable ["WL2_controlUAVActionId", _actionId];