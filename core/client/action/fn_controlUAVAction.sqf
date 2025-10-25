#include "includes.inc"
private _actionId = player addAction [
	"Control UAV",
	{
        params ["_target", "_caller", "_actionId"];

        private _cursorObject = cursorObject;
        if (unitIsUAV _cursorObject) then {
            private _access = [_cursorObject, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                uiNamespace setVariable ["WL2_remoteControlTarget", _cursorObject];
                uiNamespace setVariable ["WL2_remoteControlSeat", "Driver"];
            };
        };

        private _remoteControlTarget = uiNamespace getVariable ["WL2_remoteControlTarget", objNull];
        if (alive _remoteControlTarget && unitIsUAV _remoteControlTarget) then {
            switchCamera _remoteControlTarget;
            private _seat = uiNamespace getVariable ["WL2_remoteControlSeat", "Driver"];
            if (_seat == "Driver") then {
                private _driver = driver _remoteControlTarget;
                if (alive _driver) then {
                    player remoteControl _driver;
                } else {
                    player remoteControl _remoteControlTarget;
                };
            } else {
                player remoteControl (gunner _remoteControlTarget);
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