#include "includes.inc"

while { !BIS_WL_missionEnd } do {
    uiSleep 1;

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
    };

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
                if (!isNull _assignedVehicle) then {
                    _subordinate moveInDriver _assignedVehicle;
                    unassignVehicle _subordinate;
                    playSoundUI ["AddItemOK"];
                };
            };
            case "cargo": {
                if (!isNull _assignedVehicle) then {
                    _subordinate moveInCargo _assignedVehicle;
                    unassignVehicle _subordinate;
                    playSoundUI ["AddItemOK"];
                };
            };
            case "turret": {
                if (!isNull _assignedVehicle) then {
                    private _turretPath = _assignedRole # 1;
                    _subordinate moveInTurret [_assignedVehicle, _turretPath];
                    unassignVehicle _subordinate;
                    playSoundUI ["AddItemOK"];
                };
            };
            default {};
        };
    } forEach _ownedSubordinates;
};