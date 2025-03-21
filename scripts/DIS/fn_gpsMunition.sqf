params ["_projectile", "_unit"];

private _coordinates = _unit getVariable ["APS_targetCoordinates", getPosATL _unit];
private _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
_coordinates set [2, 200];
_laserTarget setPosATL _coordinates;
_projectile setMissileTarget [_laserTarget, true];

sleep 1;

private _terminalManeuver = false;
while { alive _projectile } do {
    private _distanceToTarget = _projectile distance _laserTarget;
    if (!_terminalManeuver) then {
        private _speed = linearConversion [0, 15000, _distanceToTarget, 400, 1000, true];
        _projectile setVelocityModelSpace [0, _speed, 0];
        _projectile setMissileTarget [_laserTarget, true];
    } else {
        _projectile setVelocityModelSpace [0, 300, 0];
    };

    if (!_terminalManeuver && _projectile distance2D _laserTarget < 40) then {
        _terminalManeuver = true;
        _projectile setVelocityModelSpace [0, 0, 0];
        _coordinates set [2, 0];
        private _enemiesNear = (_coordinates nearEntities 30) select {
            ([_x] call WL2_fnc_getAssetSide) != BIS_WL_playerSide &&
            alive _x &&
            lifeState _x != "INCAPACITATED"
        };

        if (count _enemiesNear == 0) then {
            _laserTarget setPosATL _coordinates;
            private _vectorDirAndUp = [getPosASL _projectile, AGLToASL _coordinates] call BIS_fnc_findLookAt;
            _projectile setVectorDirAndUp _vectorDirAndUp;
            continue;
        };
        private _sortedEnemies = [_enemiesNear, [_coordinates], { _x distance _input0 }, "DESCEND"] call BIS_fnc_sortBy;
        private _closestEnemy = _sortedEnemies # 0;
        _projectile setMissileTarget [_closestEnemy, true];

        private _vectorDirAndUp = [getPosASL _projectile, getPosASL _closestEnemy] call BIS_fnc_findLookAt;
        _projectile setVectorDirAndUp _vectorDirAndUp;
    };

    if (!alive _laserTarget) then {
        _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
        _laserTarget setPosATL _coordinates;
    };

    sleep 0.001;
};

deleteVehicle _laserTarget;