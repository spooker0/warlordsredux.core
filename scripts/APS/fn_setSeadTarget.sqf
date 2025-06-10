params ["_missile", "_target"];

if (_target isKindOf "Air") exitWith {
    _missile setMissileTarget [_target, true];
};

private _terminal = false;
private _lastTargetPos = getPosASL _target;
private _laser = objNull;

while { alive _missile } do {
    if (alive _target) then {
        private _targetPos = getPosASL _target;
        if (_missile distance _laser > 500 && !_terminal) then {
            if (!alive _laser) then {
                _laser = createVehicleLocal ["LaserTargetC", [0, 0, 0], [], 0, "NONE"];
            };

            _laser setPosASL (_targetPos vectorAdd [0, 0, 500]);
            _missile setMissileTarget [_laser, true];
        } else {
            private _targetVectorDirAndUp = [getPosASL _missile, _targetPos] call BIS_fnc_findLookAt;
            private _currentVectorDir = vectorDir _missile;
            private _currentVectorUp = vectorUp _missile;

            private _actualVectorDir = vectorLinearConversion [0, 1, 0.1, _currentVectorDir, _targetVectorDirAndUp # 0, true];
            private _actualVectorUp = vectorLinearConversion [0, 1, 0.1, _currentVectorUp, _targetVectorDirAndUp # 1, true];
            _missile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];

            _missile setVelocityModelSpace [0, 200, 0];

            _terminal = true;
            deleteVehicle _laser;

            _missile setMissileTarget [_target, true];
        };
        _lastTargetPos = _targetPos;
    } else {
        _laser setPosASL _lastTargetPos;
        _missile setMissileTarget [_laser, true];
    };

    sleep 0.001;
};

sleep 3;
deleteVehicle _laser;
deleteVehicle _missile;