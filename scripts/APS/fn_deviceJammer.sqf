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

    _devicesInRange = [_devicesInRange, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;

    private _deviceTarget = _devicesInRange # 0;

    if (_deviceTarget getVariable ["BIS_WL_dazzlerActivated", false]) then {
        _deviceTarget setVariable ["BIS_WL_dazzlerActivated", false, true];
        [_deviceTarget, false] remoteExec ["WL2_fnc_setDazzlerState", 2];
        [["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true]] remoteExec ["playSoundUI", _controllingUnit];
        // _controllingUnit forceWeaponFire ["Laserdesignator_mounted","Laserdesignator_mounted"];
    };
};