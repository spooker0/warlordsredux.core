params ["_projectile", "_unit"];

private _coordinates = +(_projectile getVariable ["DIS_targetCoordinates", getPosATL _unit]);
private _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
_coordinates set [2, 400];
_laserTarget setPosATL _coordinates;
_projectile setMissileTarget [_laserTarget, true];

sleep 1;

private _terminalManeuver = false;
private _originalDistance = _projectile distance _laserTarget;
while { alive _projectile } do {
    private _distanceToTarget = _projectile distance _laserTarget;
    if (!_terminalManeuver) then {
        private _speed = linearConversion [0, _originalDistance, _distanceToTarget, 400, 1000, true];
        _projectile setVelocityModelSpace [0, _speed, 0];
        _projectile setMissileTarget [_laserTarget, true];
    } else {
        _projectile setVelocityModelSpace [0, 300, 0];
    };

    if (!_terminalManeuver && _projectile distance2D _laserTarget < 200) then {
        _terminalManeuver = true;

        _coordinates set [2, 0];
        private _enemiesNear = (_coordinates nearEntities 50) select {
            ([_x] call WL2_fnc_getAssetSide) != BIS_WL_playerSide &&
            alive _x &&
            lifeState _x != "INCAPACITATED"
        };

        private _currentPosition = getPosASL _projectile;
        private _finalPosition = [];
        if (count _enemiesNear == 0) then {
            _laserTarget setPosATL _coordinates;
            _finalPosition = AGLtoASL _coordinates;
            _projectile setMissileTarget [_laserTarget, true];
        } else {
            private _sortedEnemies = [_enemiesNear, [_coordinates], { _x distance _input0 }, "DESCEND"] call BIS_fnc_sortBy;
            private _closestEnemy = _sortedEnemies # 0;
            _finalPosition = getPosASL _closestEnemy;
            _projectile setMissileTarget [_closestEnemy, true];
        };

        private _targetVectorDirAndUp = [_currentPosition, _finalPosition] call BIS_fnc_findLookAt;
        private _currentVectorDir = vectorDir _projectile;
        private _currentVectorUp = vectorUp _projectile;
        private _startTime = serverTime;
        private _endTime = serverTime + 0.15;

        while { alive _projectile &&  serverTime < _endTime } do {
            private _interpVectorDir = vectorLinearConversion [_startTime, _endTime, serverTime, _currentVectorDir, _targetVectorDirAndUp # 0, true];
            private _interpVectorUp = vectorLinearConversion [_startTime, _endTime, serverTime, _currentVectorUp, _targetVectorDirAndUp # 1, true];
            private _interpVectorDirAndUp = [_interpVectorDir, _interpVectorUp];
            _projectile setVectorDirAndUp _interpVectorDirAndUp;
            _projectile setVelocityModelSpace [0, 300, 0];
            sleep 0.0001;
        };
    };

    if (!alive _laserTarget) then {
        _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
        _laserTarget setPosATL _coordinates;
    };

    sleep 0.001;
};

deleteVehicle _laserTarget;