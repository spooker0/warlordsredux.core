#include "includes.inc"

while { !BIS_WL_missionEnd } do {
    uiSleep 1;

    if (!WL_ISUP(player)) then {
        continue;
    };

    private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
    private _aiVehicleTp = _settingsMap getOrDefault ["aiVehicleTp", true];
    if (!_aiVehicleTp) then {
        uiSleep 10;
        continue;
    };

    private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
    private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
    private _ownedSubordinates = _ownedVehicles select {
        _x isKindOf "Man"
    } select {
        WL_ISUP(_x)
    } select {
        _x != player
    } select {
        side group _x == side group player
    } select {
        vehicle _x == _x
    } select {
        currentCommand _x == "GET IN";
    };

    private _hasMovedCrew = false;
    {
        private _subordinate = _x;

        private _assignedVehicle = assignedVehicle _subordinate;
        private _assignedRole = assignedVehicleRole _subordinate;

        if (_assignedRole isEqualTo []) then {
            continue;
        };

        private _assignRoleType = _assignedRole # 0;
        switch (_assignRoleType) do {
            case "driver": {
                if (!isNull _assignedVehicle && local _assignedVehicle) then {
                    _subordinate moveInDriver _assignedVehicle;
                    _hasMovedCrew = true;
                };
            };
            case "cargo": {
                if (!isNull _assignedVehicle && _assignedVehicle turretLocal [0]) then {
                    _subordinate moveInCargo _assignedVehicle;
                    _hasMovedCrew = true;
                };
            };
            case "turret": {
                if (!isNull _assignedVehicle && _assignedVehicle turretLocal [0]) then {
                    private _turretPath = _assignedRole # 1;
                    _subordinate moveInTurret [_assignedVehicle, _turretPath];
                    _hasMovedCrew = true;
                };
            };
            default {};
        };
    } forEach _ownedSubordinates;
    if (_hasMovedCrew) then {
        playSoundUI ["AddItemOK"];
    };
};