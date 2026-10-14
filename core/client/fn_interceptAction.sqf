#include "includes.inc"
private _interceptAction = {
    params ["_target", "_caller", "_index", "_name", "_text", "_priority", "_showWindow", "_hideOnUse", "_shortcut", "_visibility", "_eventName"];
    switch (_name) do {
        case "MoveToPilot";
        case "MoveToDriver";
        case "MoveToTurret";
        case "MoveToCargo";
        case "GetInPilot";
        case "GetInDriver";
        case "GetInTurret";
        case "GetInCargo";
        case "Gear";
        case "Rearm": {
            private _access = [_target, _caller] call WL2_fnc_accessControl;
            if !(_access # 0) then {
                [format ["Vehicle locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
                true;
            } else {
                false;
            };
        };
        case "TakeVehicleControl": {
            private _bannedVehicles = ["C_Plane_Civil_01_F", "I_C_Plane_Civil_01_F"];
            if (typeof _target in _bannedVehicles) then {
                ["You cannot take control of this vehicle."] call WL2_fnc_smoothText;
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
        case "Eject": {
            private _altitude = (player modelToWorld [0, 0, 0]) # 2;
            private _eligible = _altitude > 20;
            if (_eligible) then {
                moveOut player;
                [player] spawn WL2_fnc_parachuteSetup;
                true;
            } else {
                false;
            };
        };
        case "UserType": {
            switch (_text) do {
                case (localize "STR_DN_OUT_O_DOOR");
                case (localize "STR_DN_OUT_C_DOOR"): {
                    private _doorLocked = _target getVariable ["WL2_doorsLocked", BIS_WL_playerSide];
                    if (_doorLocked == BIS_WL_playerSide) then {
                        [_target] spawn WL2_fnc_autoCloseDoor;
                        false;
                    } else {
                        private _doorsDamaged = _target getVariable ["WL2_doorsDamaged", 0];
                        if (_doorsDamaged > serverTime) then {
                            [_target] spawn WL2_fnc_autoCloseDoor;
                            false;
                        } else {
                            playSoundUI ["AddItemFailed"];
                            private _message = if (simulationEnabled _target) then {
                                [_target] spawn WL2_fnc_unlockDoorAction;
                            } else {
                                ["Door locked."] call WL2_fnc_smoothText;
                            };

                            true;
                        };
                    };
                };
                case (localize "STR_A3_action_eject"): {
                    private _altitude = (player modelToWorld [0, 0, 0]) # 2;
                    private _eligible = _altitude > 20;
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
        private _squadMenu = uiNamespace getVariable ["SQD_Menu", displayNull];
        !isNull _squadMenu
    } else {
        [-1] call WL2_fnc_scoreboardScroll;
        true;
    };
};
inGameUISetEventHandler ["PrevAction", toString _interceptScrollUp];

private _interceptScrollDown = {
    private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
    if (isNull _display) then {
        private _squadMenu = uiNamespace getVariable ["SQD_Menu", displayNull];
        !isNull _squadMenu
    } else {
        [1] call WL2_fnc_scoreboardScroll;
        true;
    };
};
inGameUISetEventHandler ["NextAction", toString _interceptScrollDown];