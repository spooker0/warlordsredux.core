#include "includes.inc"

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\vehicles.html"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    private _params = fromJSON _message;
    _params params ["_vehicleNetId", "_actionId"];

    private _vehicle = objectFromNetId _vehicleNetId;
    if (!alive _vehicle) exitWith {};

    switch (_actionId) do {
        case "remove": {
            [_vehicle] spawn WL2_fnc_deleteAssetFromMap;
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
            _vehicle setVariable ["WL2_accessControl", 6, true];
            playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss", _vehicle, false, getPosASL _vehicle, 1, 1, 0, 0];
        };
        case "connect": {
            private _access = [_vehicle, player, "driver"] call WL2_fnc_accessControl;
            if (_access # 0) then {
                player connectTerminalToUAV _vehicle;
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
                [toUpper localize "STR_A3_WL_popup_asset_repaired"] spawn WL2_fnc_smoothText;
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

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    [_texture] call WL2_fnc_sendVehicleData;
    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    [_texture] spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            [_texture] call WL2_fnc_sendVehicleData;
            sleep 2;
        };
    };
}];