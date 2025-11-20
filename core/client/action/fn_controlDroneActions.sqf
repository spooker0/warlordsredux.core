#include "includes.inc"

private _isDroneAction = {
    params ["_actionId"];
    private _actionParams = player actionParams _actionId;
    private _actionArgs = _actionParams select 2;
    if (isNil "_actionArgs") exitWith { false };
    if (count _actionArgs != 2) exitWith { false };
    _actionArgs params ["_actionType", "_drone"];
    if (_actionType != "WL2_controlDrone") exitWith { false };
    true;
};

while { alive player } do {
    uiSleep 1;

    private _eligibleDrones = missionNamespace getVariable ["WL2_eligibleDrones", []];
    _eligibleDrones = _eligibleDrones select {
        alive _x;
    } select {
        private _access = [_x, player, "driver"] call WL2_fnc_accessControl;
        _access # 0
    };

    private _droneActions = (actionIds player) select {
        [_x] call _isDroneAction;
    } apply {
        private _actionParams = player actionParams _x;
        private _actionArgs = _actionParams select 2;
        private _drone = _actionArgs select 1;
        [_x, _drone]
    };

    private _dirty = count _eligibleDrones != count _droneActions;
    {
        private _droneActionId = _x # 0;
        private _drone = _x # 1;
        if !(_drone in _eligibleDrones) then {
            _dirty = true;
            break;
        };
    } forEach _droneActions;

    if (!_dirty) then {
        continue;
    };

    {
        private _actionId = _x # 0;
        player removeAction _actionId;
    } forEach _droneActions;

    {
        private _drone = _x;
        private _droneName = [_drone] call WL2_fnc_getAssetTypeName;
        player addAction [
            format ["Control %1", _droneName],
            {
                params ["_target", "_caller", "_actionId", "_args"];

                _args params ["_actionType", "_drone"];
                private _accessControl = [_drone, _caller, "driver"] call WL2_fnc_accessControl;
                if !(_accessControl # 0) exitWith { false };

                switchCamera _drone;

                private _remoteControlTarget = _drone;

                private _lastSeatUsed = _drone getVariable ["WL2_lastSeatUsed", "Any"];
                if (_lastSeatUsed == "Driver" && alive (driver _drone)) then {
                    _remoteControlTarget = driver _drone;
                };
                if (_lastSeatUsed == "Gunner" && alive (gunner _drone)) then {
                    _remoteControlTarget = gunner _drone;
                };

                player remoteControl _remoteControlTarget;
            },
            ["WL2_controlDrone", _drone],
            1,
            false,
            true,
            "",
            "",
            0,
            false
        ];
    } forEach _eligibleDrones;
};