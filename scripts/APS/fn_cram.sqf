params ["_projectile", "_isLocal"];

private _interceptChance = 0;

_projectile setVariable ["WL2_isShell", true];

while { alive _projectile } do {
    sleep 0.1;
    private _projectilePosATL = getPosATL _projectile;
    if (_projectilePosATL # 2 < 50) then {
        continue;
    };

    private _interceptors = (entities "B_AAA_System_01_F") select {
        alive _x &&
        _projectile distance _x < 3000
    };

    {
        private _interceptor = _x;

        private _targetRealPosition = _interceptor getVariable ["WL2_targetRealPosition", []];
        if (count _targetRealPosition == 0) then {
            continue;
        };

        private _targetDistance = _targetRealPosition distance (getPosASL _projectile);
        private _isTargeted = _targetDistance < 50;
        if (!_isTargeted) then {
            continue;
        };

        _interceptChance = _interceptChance + 1;
    } forEach _interceptors;

    if (_interceptChance >= 30) then {
        if (_isLocal) then {
            createVehicle ["SmallSecondary", ASLtoAGL (getPosASL _projectile), [], 0, "FLY"];
        };
        _projectile setPosWorld [0, 0, 0];
        deleteVehicle _projectile;
        break;
    };

    private _projectileInterceptChance = _projectile getVariable ["WL2_interceptChance", -1];
    if (_projectileInterceptChance != _interceptChance) then {
        _projectile setVariable ["WL2_interceptChance", _interceptChance];
    };
};