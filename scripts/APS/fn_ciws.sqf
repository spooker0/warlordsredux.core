params ["_asset"];

[_asset] spawn {
    params ["_asset"];
    private _muzzleVelocity = getNumber (configFile >> "CfgMagazines" >> currentMagazine _asset >> "initSpeed");
    private _target = objNull;
    private _laserTarget = objNull;

    while { alive _asset } do {
        _asset setVariable ["WL2_target", _target];

        if (isNull _laserTarget) then {
            _laserTarget = createVehicle ["LaserTargetC", getPosASL _asset, [], 0, "NONE"];
        };

        if (!alive _target) then {
            private _munitions = (8 allObjects 2) select {
                alive _x &&
                getPosATL _x # 2 > 50 &&
                _x getVariable ["WL2_isShell", false] &&
                !(_x getVariable ["WL2_targetEngaged", false]) &&
                _x distance _asset < 3000
            };

            if (count _munitions > 0) then {
                _munitions = [_munitions, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
                _target = _munitions # 0;
                _target setVariable ["WL2_targetEngaged", true];
            };
        };

        if (!isNull _target) then {
            private _targetPos = getPosASL _target;
            if (_targetPos # 2 < 50) then {
                continue;
            };

            private _targetVelocity = velocity _target;
            private _distanceToTarget = _targetPos distance _asset;
            if (_distanceToTarget > 3000) then {
                continue;
            };
            _asset setVariable ["WL2_firing", true];

            private _timeToTarget = _distanceToTarget / _muzzleVelocity;
            _timeToTarget = _timeToTarget + 0.5;
            _targetPos = _targetPos vectorAdd (_targetVelocity vectorMultiply _timeToTarget);

            _laserTarget setPosASL _targetPos;

            private _lockedTarget = _asset lockedCameraTo [0];
            if (isNil "_lockedTarget" || {_lockedTarget != _laserTarget}) then {
                [_asset, [_laserTarget, [0], false]] remoteExec ["lockCameraTo", 0];
            };

            private _weaponDir = _asset weaponDirection (currentWeapon _asset);
            private _targetDir = _targetPos vectorDiff (getPosASL _asset);
            private _dotProduct = (vectorNormalized _weaponDir) vectorDotProduct (vectorNormalized _targetDir);
            private _angle = acos (_dotProduct min 1);

            // todo: test LoS
            private _isIntercepting = _angle < 5 && someAmmo _asset;
            if (_isIntercepting) then {
                _asset setVariable ["WL2_targetRealPosition", _targetPos, true];
            } else {
                _asset setVariable ["WL2_targetRealPosition", [], true];
            };
        } else {
            _asset setVariable ["WL2_firing", false];
            private _lockedTarget = _asset lockedCameraTo [0];
            if !(isNil "_lockedTarget") then {
                [_asset, [objNull, [0], true]] remoteExec ["lockCameraTo", 0];
            };
            _asset setVariable ["WL2_targetRealPosition", [], true];
        };
        sleep 0.01;
    };
};

[_asset] spawn {
    params ["_asset"];
    private _soundId = -1;
    while { alive _asset } do {
        if (_asset getVariable ["WL2_firing", false]) then {
            private _gunner = gunner _asset;

            if (_soundId == -1) then {
                _soundId = playSound3D [getMissionPath "src\sounds\incoming.ogg", _asset, false, getPosASL _asset, 5, 1, 0, 0, false];
            } else {
                if ((soundParams _soundId) isEqualTo []) then {
                    _soundId = -1;
                };
            };

            _gunner forceWeaponFire [currentWeapon _asset, "close"];
        };
        sleep 0.01;
    };
};

addMissionEventHandler ["Draw3D", {
    private _asset = objectFromNetId (_thisArgs # 0);
    if (getConnectedUAV player != _asset) exitWith {};

    private _target = _asset getVariable ["WL2_target", objNull];
    if (isNull _target) exitWith {};

    private _interceptChance = _target getVariable ["WL2_interceptChance", -1];
    private _displayText = if (_interceptChance == -1) then {
        "INCOMING"
    } else {
        format ["INTERCEPT %1%%", round (_interceptChance * 10 / 3)];
    };

    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
        [1, 0, 0, 1],
        _target modelToWorldVisual [0, 0, 0],
        1,
        1,
        0,
        _displayText,
        true,
        0.035,
        "RobotoCondensedBold",
        "center",
        true
    ];

    // private _targetPos = _asset getVariable ["WL2_targetPos", []];
    // if (count _targetPos == 0) exitWith {};
    // drawIcon3D [
    //     "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
    //     [1, 0, 0, 1],
    //     ASLtoAGL _targetPos,
    //     0.5,
    //     0.5,
    //     0,
    //     _displayText,
    //     true,
    //     0.03,
    //     "RobotoCondensedBold",
    //     "center",
    //     true
    // ];
}, [netid _asset]];