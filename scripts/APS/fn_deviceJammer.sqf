params ["_asset", "_turret"];

while { alive _asset } do {
    sleep 0.2;

    private _controllingUnit = _asset turretUnit _turret;
    if !(isPlayer _controllingUnit) then {
        sleep 1;
        continue;
    };

    private _laserTarget = _asset laserTarget _turret;
    if (isNull _laserTarget) then {
        sleep 1;
        continue;
    };

    private _devicesInRange = (_laserTarget nearEntities 50) select {
        _x getVariable ["apsType", -1] == 3;
    };

    if (count _devicesInRange == 0) then {
        continue;
    };

    {
        private _deviceTarget = _x;
        if (_deviceTarget getVariable ["BIS_WL_dazzlerActivated", false]) then {
            _deviceTarget setVariable ["BIS_WL_dazzlerActivated", false, true];
            [_deviceTarget, false] remoteExec ["WL2_fnc_setDazzlerState", 2];
            [["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true]] remoteExec ["playSoundUI", _controllingUnit];
        };
    } forEach _devicesInRange;
};