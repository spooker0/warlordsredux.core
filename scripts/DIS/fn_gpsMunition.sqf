params ["_projectile", "_unit"];

private _coordinates = +(_projectile getVariable ["DIS_targetCoordinates", getPosATL _unit]);
private _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
_coordinates set [2, 400];
_laserTarget setPosATL _coordinates;
_projectile setMissileTarget [_laserTarget, true];

sleep 1;

private _terminalManeuver = false;
private _originalDistance = _projectile distance _laserTarget;
private _launchTime = serverTime;
private _originalSpeed = (velocityModelSpace _unit) # 1;

private _initialVectorUp = vectorUp _projectile;
_initialVectorUp set [0, 0];
_initialVectorUp set [1, 0];
_projectile setVectorDirAndUp [vectorDir _projectile, _initialVectorUp];

private _finalPosition = [];
while { alive _projectile } do {
    private _distanceToTarget = _projectile distance _laserTarget;
    private _speed = _originalSpeed - (serverTime - _launchTime) * 0.1;
    if (!_terminalManeuver) then {
        _projectile setVelocityModelSpace [0, _speed max 150, 0];
        _projectile setMissileTarget [_laserTarget, true];
    } else {
        private _currentPosition = getPosASL _projectile;
        private _targetVectorDirAndUp = [_currentPosition, _finalPosition] call BIS_fnc_findLookAt;
        private _currentVectorDir = vectorDir _projectile;
        private _currentVectorUp = vectorUp _projectile;

        private _actualVectorDir = vectorLinearConversion [0, 1, 0.01, _currentVectorDir, _targetVectorDirAndUp # 0, true];
        private _actualVectorUp = vectorLinearConversion [0, 1, 0.01, _currentVectorUp, _targetVectorDirAndUp # 1, true];
        _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];

        _projectile setVelocityModelSpace [0, _speed max 100, 0];
    };

    if (_projectile distance2D _laserTarget < 200 && !_terminalManeuver) then {
        _terminalManeuver = true;

        _coordinates set [2, 0];
        private _enemiesNear = (_coordinates nearEntities 100) select {
            ([_x] call WL2_fnc_getAssetSide) != BIS_WL_playerSide &&
            alive _x &&
            lifeState _x != "INCAPACITATED"
        };

        _finalPosition = [];
        if (count _enemiesNear == 0) then {
            _laserTarget setPosATL _coordinates;
            _finalPosition = AGLtoASL _coordinates;
            _projectile setMissileTarget [_laserTarget, true];
        } else {
            private _rewardsDB = missionNamespace getVariable ["WL2_killRewards", createHashMap];
            private _sortedEnemies = [_enemiesNear, [_rewardsDB], {
                private _rewardsDB = _input0;
                private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
                _rewardsDB getOrDefault [_assetActualType, 0]
            }, "DESCEND"] call BIS_fnc_sortBy;
            private _closestEnemy = _sortedEnemies # 0;
            _finalPosition = getPosASL _closestEnemy;
            _projectile setMissileTarget [_closestEnemy, true];
        };
    };

    if (!alive _laserTarget) then {
        _laserTarget = createVehicleLocal ["LaserTargetC", _coordinates, [], 0, "CAN_COLLIDE"];
        _laserTarget setPosATL _coordinates;
    };

    sleep 0.001;
};

deleteVehicle _laserTarget;