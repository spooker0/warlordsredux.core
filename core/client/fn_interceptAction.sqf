#include "includes.inc"
private _interceptAction = {
    params ["_target", "_caller", "_index", "_name", "_text", "_priority", "_showWindow", "_hideOnUse", "_shortcut", "_visibility", "_eventName"];
    switch (_name) do {
        case "MoveToPilot": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Pilot seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "MoveToDriver": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Driver seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "MoveToTurret": {
            private _access = [_target, _caller, "gunner"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Turret seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "MoveToCargo": {
            private _access = [_target, _caller, "cargo"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Passenger seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInPilot": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Pilot seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInDriver": {
            private _access = [_target, _caller, "driver"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Driver seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInTurret": {
            private _access = [_target, _caller, "gunner"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Turret seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "GetInCargo": {
            private _access = [_target, _caller, "cargo"] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Passenger seat locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
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
                [format ["Inventory locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "TakeVehicleControl": {
            private _bannedVehicles = ["C_Plane_Civil_01_F", "I_C_Plane_Civil_01_F"];
            if (typeof _target in _bannedVehicles) then {
                [format ["You cannot take control of this vehicle."]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "SwitchToUAVDriver": {
            cameraOn setVariable ["WL2_lastSeatUsed", "Driver"];
            false;
        };
        case "SwitchToUAVGunner": {
            cameraOn setVariable ["WL2_lastSeatUsed", "Gunner"];
            false;
        };
        case "UserType": {
            switch (_text) do {
                case (localize "STR_DN_OUT_C_DOOR"): {
                    if (_target getVariable ["WL2_doorsLocked", false]) then {
                        [format ["Door locked."]] call WL2_fnc_smoothText;
                        playSoundUI ["AddItemFailed"];
                        true;
                    } else {
                        false;
                    };
                };
                case (localize "STR_A3_action_eject"): {
                    private _vehicle = vehicle player;
                    private _eligible = _vehicle isKindOf "Plane" && speed _vehicle > 1;
                    if (_eligible) then {
                        playSoundUI ["a3\sounds_f_jets\vehicles\air\shared\fx_plane_jet_ejection_in.wss"];
                        moveOut player;
                        [player] spawn WL2_fnc_parachuteSetup;
                        true;
                    } else {
                        false;
                    };
                };
                default {
                    false;
                };
            };
        };
        default {
            false;
        };
    };
};
inGameUISetEventHandler ["Action", toString _interceptAction];

private _interceptScrollUp = {
    private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
    if (isNull _display) then {
        false;
    } else {
        private _texture = _display displayCtrl 5502;
        _texture ctrlWebBrowserAction ["ExecJS", "scrollUp();"];
        true;
    };
};
inGameUISetEventHandler ["PrevAction", toString _interceptScrollUp];

private _interceptScrollDown = {
    private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
    if (isNull _display) then {
        false;
    } else {
        private _texture = _display displayCtrl 5502;
        _texture ctrlWebBrowserAction ["ExecJS", "scrollDown();"];
        true;
    };
};
inGameUISetEventHandler ["NextAction", toString _interceptScrollDown];