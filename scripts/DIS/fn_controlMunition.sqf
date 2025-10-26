#include "includes.inc"
params ["_projectile", "_flightMode"];

if (inputAction "defaultAction" > 0) then {
    waitUntil {
        uiSleep 0.001;
        inputAction "defaultAction" == 0
    };
};

"munitionControl" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];

private _reticle = _display ctrlCreate ["RscPicture", -1];
_reticle ctrlSetText "\a3\weapons_f_beta\Reticle\Data\reticle_horizon2_CA.paa";
private _reticleWidth = 0.09;
private _reticleHeight = 0.12;
_reticle ctrlSetPosition [0.5 - _reticleWidth, 0.5 - _reticleHeight, _reticleWidth * 2, _reticleHeight * 2];
_reticle ctrlCommit 0;

private _fuelDisplay = _display ctrlCreate ["RscStructuredText", -1];
_fuelDisplay ctrlSetPosition [0, 0, 1, 0.2];
_fuelDisplay ctrlSetTextColor [1, 1, 1, 1];
_fuelDisplay ctrlCommit 0;

private _controlParams = ["TV GUIDED MUNITION", [
    ["Boost", "turbo"],
    ["Detonate", "defaultAction"]
]];
if (_flightMode in [1, 2]) then {
    _controlParams pushBack ["Lock/Unlock Controls", "lockTarget"];
};
["TV", _controlParams] call WL2_fnc_showHint;

private _yaw = getDir _projectile;

private _dir = vectorDir _projectile;
private _pitch = (_dir select 2) atan2 (sqrt ((_dir select 0)^2 + (_dir select 1)^2));

private _inputPerTime = 20;

private _lastTime = serverTime;
private _startTime = serverTime;
private _timeToLive = getNumber (configFile >> "CfgAmmo" >> (typeOf _projectile) >> "timeToLive");
private _projectileSpeed = _projectile getVariable ["APS_speedOverride", 100];
private _fuelUsed = 0;

while { alive _projectile && alive player && lifeState player != "INCAPACITATED" } do {
    private _elapsedTime = serverTime - _lastTime;
    _lastTime = serverTime;

    private _pitchInput = (inputAction "AimUp") - (inputAction "AimDown");
    private _yawInput = (inputAction "AimLeft") - (inputAction "AimRight");

    private _projectilePosition = _projectile modelToWorld [0, 0, 0];
    private _altitude = _projectilePosition # 2;

    if (serverTime - _startTime < 1 && _flightMode == 0) then {
        private _desiredPitch = 0;
        private _pitchError = _desiredPitch - _pitch;
        _pitchInput = (_pitchError min 10) max -10;
    };

    private _fuelRemaining = switch (_flightMode) do {
        case 0;
        case 3: {
            100 * (_timeToLive - (serverTime - _startTime)) / _timeToLive;
        };
        case 1;
        case 2: {
            100 - _fuelUsed
        };
    };

    if (_fuelRemaining <= 0 || _flightMode == 1) then {
        _pitchInput = 0;
        _yawInput = 0;
    };
    _fuelRemaining = _fuelRemaining max 0;
    if (_fuelRemaining <= 0) then {
        if (_flightMode == 2) then {
            _flightMode = 1;
        };
    };

    private _pitchFinalInput = (_pitchInput * _elapsedTime * _inputPerTime);
    private _yawFinalInput = (_yawInput * _elapsedTime * _inputPerTime);

    if (_flightMode == 2) then {
        private _fuelUsage = ((abs _pitchFinalInput) + (abs _yawFinalInput)) * 1;
        if (_altitude > 1000 || _pitch > 0) then {
            _fuelUsage = _fuelUsage * 10;
        };
        _fuelUsed = _fuelUsed + (_fuelUsage max 0.1);
    };

    if (_flightMode == 3) then {
        _fuelUsed = _fuelUsed + _elapsedTime * 2;
    };

    _pitch = _pitch + _pitchFinalInput;
    _yaw = _yaw - _yawFinalInput;

    switch (_flightMode) do {
        case 0: {
            _pitch = 89 min (_pitch max -80);
        };
        case 1: {
            _pitch = 89 min (_pitch max -89);
        };
        case 2: {
            _pitch = 89 min (_pitch max -89);
        };
        case 3: {
            _pitch = 10 min (_pitch max -40);
        };
    };

    private _cosPitch = cos _pitch;
    private _sinPitch = sin _pitch;
    private _cosYaw = cos _yaw;
    private _sinYaw = sin _yaw;

    private _forward = [
        _cosPitch * _sinYaw,
        _cosPitch * _cosYaw,
        _sinPitch
    ];
    private _right = _forward vectorCrossProduct [0, 0, 1];
    _right = vectorNormalized _right;

    private _up = _right vectorCrossProduct _forward;
    _up = vectorNormalized _up;

    if (_flightMode in [1, 2]) then {
        private _unlockInput = inputAction "lockTarget";
        if (_unlockInput > 0) then {
            waitUntil {
                inputAction "lockTarget" == 0
            };
            _flightMode = switch (_flightMode) do {
                case 1: {
                    2
                };
                case 2: {
                    1
                };
            };
        };
    };

    private _isSpeedModify = inputAction "turbo" > 0;
    private _speedModifier = if (_isSpeedModify) then {
        1
    } else {
        0.3
    };

    switch (_flightMode) do {
        case 0;
        case 2: {
            _projectile setVectorDirAndUp [_forward, _up];
            _projectile setVelocityModelSpace [0, _projectileSpeed * _speedModifier, 0];
        };
        case 1:{
            _dir = vectorDir _projectile;
            _pitch = (_dir # 2) atan2 (sqrt ((_dir # 0)^2 + (_dir # 1)^2));
            _yaw = getDir _projectile;

            _projectileSpeed = velocityModelSpace _projectile # 1;
        };
        case 3: {
            private _projectileSpeedDragged = (_projectileSpeed * _speedModifier) - (serverTime - _startTime) * 0.75;
            _projectile setVectorDirAndUp [_forward, _up];
            _projectile setVelocityModelSpace [0, _projectileSpeedDragged max 10, 0];
        };
    };

    if (inputAction "defaultAction" > 0 && serverTime - _startTime > 2) then {
        triggerAmmo _projectile;
        break;
    };

    private _altitudeColor = switch (_flightMode) do {
        case 0;
        case 3: {
            "";
        };
        case 1;
        case 2: {
            if (_altitude > 1000 || _pitch > 0) then {
                " color = '#ff0000'";
            } else {
                "";
            };
        };
    };

    _fuelDisplay ctrlSetStructuredText parseText format [
        "<t align='left' size='1.2'>GPS: %1</t><t align='center' size='2'>Fuel: %2%%</t><t align='right' size='1.2'%3>ALT: %4M</t>",
        mapGridPosition _projectile,
        round _fuelRemaining,
        _altitudeColor,
        round _altitude
    ];

    uiSleep 0.001;
};

uiSleep 1;
deleteVehicle _projectile;
"munitionControl" cutText ["", "PLAIN"];
["TV"] call WL2_fnc_showHint;