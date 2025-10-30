#include "includes.inc"
private _interceptAction = {
    params ["_target", "_caller", "_index", "_name", "_text", "_priority", "_showWindow", "_hideOnUse", "_shortcut", "_visibility", "_eventName"];
    switch (_name) do {
        case "MoveToPilot": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Pilot seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "MoveToDriver": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Driver seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "MoveToTurret": {
            private _access = [_target, _caller, "gunner"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Turret seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "MoveToCargo": {
            private _access = [_target, _caller, "cargo"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Passenger seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInPilot": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Pilot seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInDriver": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Driver seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInTurret": {
            private _access = [_target, _caller, "gunner"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Turret seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInCargo": {
            private _access = [_target, _caller, "cargo"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Passenger seat locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "Gear";
        case "Rearm": {
            private _access = [_target, _caller, "cargo"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                systemChat format ["Inventory locked. (%1)", _access # 1];
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "TakeVehicleControl": {
            private _bannedVehicles = ["C_Plane_Civil_01_F", "I_C_Plane_Civil_01_F"];
            if (typeof _target in _bannedVehicles) then {
                systemChat "You cannot take control of this vehicle.";
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "UAVTerminalOpen": {
            0 spawn {
                private _result = [
                    "Control UAV",
                    "The supported way to take control of UAVs is through the map or vehicle manager interface. Do you want to go to that instead?",
                    "Yes", "No"
                ] call WL2_fnc_prompt;
                if (_result) then {
                    0 spawn WL2_fnc_vehicleManager;
                } else {
                    player action ["UAVTerminalOpen", player];
                };
            };
            true;
        };
        case "SwitchToUAVDriver": {
            uiNamespace setVariable ["WL2_remoteControlSeat", "Driver"];
            false;
        };
        case "SwitchToUAVGunner": {
            uiNamespace setVariable ["WL2_remoteControlSeat", "Gunner"];
            false;
        };
        default {
            false;
        };
    };
};
inGameUISetEventHandler ["Action", toString _interceptAction];

private _interceptScrollUp = {
    private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
    if (isNull _display) exitWith {
        false;
    };
    private _texture = _display displayCtrl 5502;
    _texture ctrlWebBrowserAction ["ExecJS", "scrollUp();"];
    true;
};
inGameUISetEventHandler ["PrevAction", toString _interceptScrollUp];

private _interceptScrollDown = {
    private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
    if (isNull _display) exitWith {
        false;
    };
    private _texture = _display displayCtrl 5502;
    _texture ctrlWebBrowserAction ["ExecJS", "scrollDown();"];
    true;
};
inGameUISetEventHandler ["NextAction", toString _interceptScrollDown];