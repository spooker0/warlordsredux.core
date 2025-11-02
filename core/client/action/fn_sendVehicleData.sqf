#include "includes.inc"
params ["_texture"];

private _playerUid = getPlayerUID player;

private _modOverrideUid = uiNamespace getVariable ["WL2_modOverrideUid", ""];
if (_modOverrideUid != "") then {
    _playerUid = _modOverrideUid;
};

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", _playerUid];
private _playerVehicles = missionNamespace getVariable [_ownedVehicleVar, []];

private _uavsWithAccess = allUnitsUAV select {
    private _assetSide = [_x] call WL2_fnc_getAssetSide;
    _assetSide == BIS_WL_playerSide;
} select {
    private _uavAccess = [_x, player, "driver"] call WL2_fnc_accessControl;
    _uavAccess # 0;
};
_playerVehicles insert [-1, _uavsWithAccess, true];
_playerVehicles = _playerVehicles select { alive _x };

private _vehicleInfoText = toJSON (
    _playerVehicles apply {
        private _vehicle = _x;

        private _displayName = [_vehicle] call WL2_fnc_getAssetTypeName;
        private _assetSector = BIS_WL_allSectors select { _vehicle inArea (_x getVariable "objectAreaComplete") };
        private _assetLocation = if (count _assetSector > 0) then {
            (_assetSector # 0) getVariable ["WL2_name", str (mapGridPosition _vehicle)];
        } else {
            mapGridPosition _vehicle;
        };
        private _vehicleMaxAps = _vehicle call APS_fnc_getMaxAmmo;
        private _apsAmmo = if (_vehicleMaxAps > 0) then {
            private _actualApsAmmo = _vehicle getVariable ["apsAmmo", 0];
            format ["(APS: %1/%2)", _actualApsAmmo, _vehicleMaxAps]
        } else {
            ""
        };

        private _accessControl = _vehicle getVariable ["WL2_accessControl", -1];
        (_accessControl call WL2_fnc_getVehicleLockStatus) params ["_lockColor", "_lockLabel"];

        private _vehicleName = format ["%1 @ %2 %3 | %4", _displayName, _assetLocation, _apsAmmo, _lockLabel];
        private _vehicleOwner = _vehicle getVariable ["BIS_WL_ownerAsset", "123"];
        if (_vehicleOwner != _playerUid) then {
            _vehicleName = format ["(SHARED) %1", _vehicleName];
        };

        // private _vehicleIcon = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "picture");
		// _vehicleIcon = if (_vehicleIcon in ["pictureThing", "pictureStaticObject"]) then {
		// 	"a3\ui_f\data\map\vehicleicons\iconcratesupp_ca.paa";
		// } else {
		// 	_vehicleIcon regexReplace ["^\\", ""];
		// };

        private _availableActions = ["remove"];

        private _unwantedPassengers = (crew _vehicle) select {
            _x != player &&
            _playerUid != (_x getVariable ["BIS_WL_ownerAsset", "123"])
        };
        if (getPosATL _vehicle # 2 < 10 && count _unwantedPassengers > 0) then {
            _availableActions pushBack "kick";
        };

        if (_accessControl < 7) then {
            _availableActions pushBack "lock";
        };
        if (_accessControl > 0) then {
            _availableActions pushBack "unlock";
        };

        private _driverAccess = [_vehicle, player, "driver"] call WL2_fnc_accessControl;
        if (unitIsUAV _vehicle && _driverAccess # 0) then {
            if (alive (gunner _vehicle)) then {
                _availableActions pushBack "connect-gunner";
            };
            if (alive (driver _vehicle)) then {
                _availableActions pushBack "connect-driver";
            };
            _availableActions pushBack "set-auto";
        };

        private _fullAccess = [_vehicle, player, "full"] call WL2_fnc_accessControl;
        if (_fullAccess # 0) then {
            private _cooldown = ((_vehicle getVariable ["BIS_WL_nextRearm", 0]) - serverTime) max 0;
            private _nearbyVehicles = (_vehicle nearEntities WL_MAINTENANCE_RADIUS) select { alive _x };
            private _rearmVehicles = _nearbyVehicles select {
                _x getVariable ["WLM_ammoCargo", 0] > 250
            };
            if (count _rearmVehicles > 0 && _cooldown == 0) then {
                _availableActions pushBack "rearm";
            };
        };

        private _canRepair = [_vehicle, player] call WL2_fnc_repairActionEligibility;
        private _nextRepairTime = _vehicle getVariable ["WL2_nextRepair", 0];
        if (_canRepair && _nextRepairTime <= serverTime) then {
            _availableActions pushBack "repair";
        };

        private _canRefuel = [_vehicle, player] call WL2_fnc_refuelActionEligibility;
        if (_canRefuel) then {
            _availableActions pushBack "refuel";
        };

        [netid _vehicle, _vehicleName, _availableActions]
    }
);
_vehicleInfoText = _texture ctrlWebBrowserAction ["ToBase64", _vehicleInfoText];

private _script = format [
    "updateData(atobr(""%1""));",
    _vehicleInfoText
];
_texture ctrlWebBrowserAction ["ExecJS", _script];