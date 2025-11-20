#include "includes.inc"

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\vehicles.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    private _params = fromJSON _message;
    _params params ["_vehicleNetId", "_actionId"];

    private _vehicle = objectFromNetId _vehicleNetId;
    if (!alive _vehicle) exitWith {
        closeDialog 0;
        playSoundUI ["AddItemFailed"];
        ["Vehicle is no longer available."] call WL2_fnc_smoothText;
    };
    if (!alive player || lifeState player == "INCAPACITATED") exitWith {
        closeDialog 0;
        playSoundUI ["AddItemFailed"];
        ["You are incapacitated."] call WL2_fnc_smoothText;
    };

    switch (_actionId) do {
        case "remove": {
            [_vehicle, _texture] spawn WL2_fnc_deleteAssetFromMap;
        };
        case "kick": {
            private _unwantedPassengers = (crew _vehicle) select {
                _x != player &&
                getPlayerUID player != (_x getVariable ["BIS_WL_ownerAsset", "123"])
            };
            {
                moveOut _x;
            } forEach _unwantedPassengers;
        };
        case "lock": {
            private _accessControl = _vehicle getVariable ["WL2_accessControl", 0];
            _vehicle setVariable ["WL2_accessControl", (_accessControl + 1) min 7, true];
            playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss", _vehicle, false, getPosASL _vehicle, 1, 1, 0, 0];
        };
        case "unlock": {
            private _accessControl = _vehicle getVariable ["WL2_accessControl", 0];
            _vehicle setVariable ["WL2_accessControl", (_accessControl - 1) max 0, true];
            playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_open.wss", _vehicle, false, getPosASL _vehicle, 1, 1, 0, 0];
        };
        case "connect-driver": {
            private _access = [_vehicle, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                switchCamera _vehicle;
                player remoteControl (driver _vehicle);

                private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];
                _eligibleDrones pushBackUnique _vehicle;
                missionNamespace setVariable ["WL2_eligibleDrones", _eligibleDrones];
                _vehicle setVariable ["WL2_lastSeatUsed", "Driver"];

                closeDialog 0;
            };
        };
        case "connect-gunner": {
            private _access = [_vehicle, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                switchCamera _vehicle;
                player remoteControl (gunner _vehicle);

                private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];
                _eligibleDrones pushBackUnique _vehicle;
                missionNamespace setVariable ["WL2_eligibleDrones", _eligibleDrones];
                _vehicle setVariable ["WL2_lastSeatUsed", "Gunner"];

                closeDialog 0;
            };
        };
        case "set-auto": {
            private _access = [_vehicle, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                if (isAutonomous _vehicle) then {
                    [_vehicle, false] remoteExec ["setAutonomous", 0];
                    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_fatal.wss"];
                } else {
                    [_vehicle, true] remoteExec ["setAutonomous", 0];
                    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_restart.wss"];
                };
            };
        };
        case "rearm": {
            private _assetActualType = _vehicle getVariable ["WL2_orderedClass", typeOf _vehicle];
            private _rearmTime = WL_ASSET(_assetActualType, "rearm", 600);
            _vehicle setVariable ["BIS_WL_nextRearm", serverTime + _rearmTime, true];

            private _pylonConfig = configFile >> "CfgVehicles" >> typeOf _vehicle >> "Components" >> "TransportPylonsComponent";
            private _isAircraft = !(isNull _pylonConfig);

            if (_isAircraft) then {
                private _attachments = _vehicle getVariable ["WLM_assetAttachments", [["default"]]];
                if (count _attachments > 0 && (_attachments # 0 # 0 == "default")) then {
                    private _defaultAttachments = [];
                    {
                        _defaultAttachments pushBack [_x # 3, _x # 2];
                    } forEach (getAllPylonsInfo _vehicle);
                    _vehicle setVariable ["WLM_assetAttachments", _defaultAttachments, true];
                    _attachments = _defaultAttachments;
                };
                [_vehicle, _attachments, true] remoteExec ["WLM_fnc_applyPylon", _vehicle];
            } else {
                [_vehicle] remoteExec ["WLM_fnc_rearmVehicle", _vehicle];
            };

            playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss", _vehicle, false, getPosASL _vehicle, 2, 1, 75];
        };
        case "repair": {
            private _nextRepairTime = _vehicle getVariable ["WL2_nextRepair", 0];
            if (_nextRepairTime <= serverTime) then {
                [player, "repair", _nextRepairTime, 0, _vehicle] remoteExec ["WL2_fnc_handleClientRequest", 2];
                playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Repair.wss", _vehicle, false, getPosASL _vehicle, 2, 1, 75];
                [localize "STR_A3_WL_popup_asset_repaired"] call WL2_fnc_smoothText;
                _vehicle setVariable ["WL2_nextRepair", serverTime + WL_COOLDOWN_REPAIR, true];
            } else {
                playSound "AddItemFailed";
            };
        };
        case "refuel": {
            playSound3D ["a3\sounds_f\sfx\ui\vehicles\vehicle_refuel.wss", _vehicle, false, getPosASL _vehicle, 2, 1, 75];
            [_vehicle, 1] remoteExec ["setFuel", _vehicle];
        };
    };

    [_texture] spawn WL2_fnc_sendVehicleData;
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    [_texture] spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            [_texture] call WL2_fnc_sendVehicleData;
            uiSleep 0.5;
        };

        private _override = uiNamespace getVariable ["WL2_modOverrideUid", ""];
        if (_override != "") then {
            ["Mod vehicle access expired."] call WL2_fnc_smoothText;
            uiNamespace setVariable ["WL2_modOverrideUid", ""];
        };
    };
}];