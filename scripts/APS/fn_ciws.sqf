params ["_asset"];

[_asset] spawn {
    params ["_asset"];
    private _muzzleVelocity = getNumber (configFile >> "CfgMagazines" >> currentMagazine _asset >> "initSpeed");
    while { alive _asset } do {
        private _currentTarget = _asset getVariable ["WL2_target", objNull];
        if (!alive _currentTarget) then {
            private _munitions = (8 allObjects 2) select {
                alive _x &&
                _x distance _asset < 3000 &&
                getPosATL _x # 2 > 50 &&
                [_x] call WL2_fnc_isScannerMunition &&
                !(_x getVariable ["WL2_targetEngaged", false])
            };

            if (count _munitions > 0) then {
                _munitions = [_munitions, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
                private _target = _munitions # 0;
                _asset setVariable ["WL2_target", _target];
                _currentTarget = _target;
                _target setVariable ["WL2_targetEngaged", true];

                _target addEventHandler ["SubmunitionCreated", {
                    params ["_projectile", "_submunitionProjectile", "_pos", "_velocity"];
                    private _asset = _projectile getVariable ["WL2_tracker", objNull];
                    _asset setVariable ["WL2_target", _submunitionProjectile];
                    private _projectileDestroyTime = _projectile getVariable ["WL2_targetDestroyTime", -1];
                    _submunitionProjectile setVariable ["WL2_targetEngaged", true];
                    _submunitionProjectile setVariable ["WL2_targetDestroyTime", _projectileDestroyTime];
                }];
            };
        };

        if (!isNull _currentTarget) then {
            private _target = _currentTarget;
            private _targetPos = getPosASL _target;
            private _targetVelocity = velocity _target;
            private _distanceToTarget = _targetPos distance _asset;
            private _timeToTarget = _distanceToTarget / _muzzleVelocity;
            _timeToTarget = _timeToTarget + random [-0.3, 0, 0.3];
            _targetPos = _targetPos vectorAdd (_targetVelocity vectorMultiply _timeToTarget);
            _asset lockCameraTo [_targetPos, [0], false];
            _asset setVariable ["WL2_firing", true];

            private _targetDestroyTime = _target getVariable ["WL2_targetDestroyTime", -1];
            if (_targetDestroyTime == -1) then {
                private _weaponDir = _asset weaponDirection (currentWeapon _asset);
                private _targetDir = _targetPos vectorDiff (getPosASL _asset);
                private _dotProduct = (vectorNormalized _weaponDir) vectorDotProduct (vectorNormalized _targetDir);
                private _angle = acos (_dotProduct min 1);

                if (_angle < 5) then {
                    _target setVariable ["WL2_targetDestroyTime", serverTime + 3.5];
                    _target setVariable ["WL2_tracker", _asset];
                };
            } else {
                if (serverTime > _targetDestroyTime && someAmmo _asset) then {
                    triggerAmmo _target;
                };
            };
        } else {
            _asset setVariable ["WL2_firing", false];
            _asset lockCameraTo [objNull, [0], true];
        };
        sleep 0.1;
    };
};

[_asset] spawn {
    params ["_asset"];
    while { alive _asset } do {
        if (_asset getVariable ["WL2_firing", false]) then {
            private _gunner = gunner _asset;
            _gunner forceWeaponFire [currentWeapon _asset, "close"];
        };
        sleep 0.01;
    };
};