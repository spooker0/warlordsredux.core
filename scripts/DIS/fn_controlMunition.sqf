params ["_projectile", "_flightMode"];

"missileCamera" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
private _background = _display ctrlCreate ["RscPicture", -1];
_background ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
_background ctrlSetText "\a3\weapons_f\Reticle\data\optika_tv_CA.paa";
_background ctrlCommit 0;

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

private _instructionsDisplay = _display ctrlCreate ["RscStructuredText", -1];
_instructionsDisplay ctrlSetPosition [0.25, 1 - safeZoneY - 0.3, 0.5, 0.3];
_instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];

private _instructionStages = [
    ["defaultAction", "Detonate"],
    ["nightVision", "Thermal Vision"],
    ["zoomIn", "Map Zoom In"],
    ["zoomOut", "Map Zoom Out"]
];
if (_flightMode in [1, 2]) then {
    _instructionStages pushBack ["lockTarget", "Lock/Unlock Controls"];
};

_instructionStages = _instructionStages apply {
    private _action = _x # 0;
    private _text = _x # 1;
    format ["<t align='left'>%1</t><t align='right'>[%2]</t>", _text, (actionKeysNames [_action, 1, "Combo"]) regexReplace ["""", ""]];
};
private _instructionText = _instructionStages joinString "<br/>";

_instructionsDisplay ctrlSetStructuredText parseText format [
    "<t size='1.2'>%1</t>",
    _instructionText
];
_instructionsDisplay ctrlCommit 0;

private _mapDisplay = _display ctrlCreate ["RscMapControl", -1];
_mapDisplay ctrlCommit 0;
_mapDisplay ctrlMapSetPosition [safeZoneX + 0.1, 0.5, 0.6, 0.8];
_mapDisplay ctrlMapAnimAdd [0, 0.2, getPosASL _projectile];
ctrlMapAnimCommit _mapDisplay;
_mapDisplay mapCenterOnCamera true;
_mapDisplay ctrlAddEventHandler ["Draw", WL2_fnc_iconDrawMap];

private _yaw = getDir _projectile;

private _dir = vectorDir _projectile;
private _pitch = (_dir select 2) atan2 (sqrt ((_dir select 0)^2 + (_dir select 1)^2));

private _pitchVel = 0;
private _yawVel   = 0;

private _maxRotSpeed = 1;
private _acceleration = 0.01;
private _damping = 0.95;
private _inputPerTime = 60;

private _lastTime = serverTime;
private _startTime = serverTime;
private _timeToLive = getNumber (configFile >> "CfgAmmo" >> (typeOf _projectile) >> "timeToLive");
private _projectileSpeed = _projectile getVariable ["APS_speedOverride", 100];
private _nightVision = false;
private _fuelUsed = 0;

if (inputAction "defaultAction" > 0) then {
    waitUntil {
        sleep 0.001;
        inputAction "defaultAction" == 0
    };
};

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
        case 0: {
            100 * (_timeToLive - (serverTime - _startTime)) / _timeToLive;
        };
        case 1;
        case 2: {
            100 - _fuelUsed
        };
        case 3: {
            (100 - _fuelUsed) min (100 * (_timeToLive - (serverTime - _startTime)) / _timeToLive);
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

    private _inputFactor = _inputPerTime * _elapsedTime;

    private _pitchFinalInput = (_pitchInput * _acceleration * _inputFactor);
    private _yawFinalInput = (_yawInput * _acceleration * _inputFactor);

    _pitchVel = _pitchVel + _pitchFinalInput;
    _yawVel = _yawVel + _yawFinalInput;

    if (_flightMode == 2) then {
        private _fuelUsage = ((abs _pitchFinalInput) + (abs _yawFinalInput)) * 10;
        if (_altitude > 1000 || _pitch > 0) then {
            _fuelUsage = _fuelUsage * 10;
        };
        _fuelUsed = _fuelUsed + (_fuelUsage max 0.1);
    };

    if (_flightMode == 3) then {
        _fuelUsed = _fuelUsed + _elapsedTime * 2;
    };

    _pitchVel = _pitchVel max (-_maxRotSpeed) min _maxRotSpeed;
    _yawVel = _yawVel max (-_maxRotSpeed) min _maxRotSpeed;

    _pitch = _pitch + _pitchVel;
    _yaw = _yaw - _yawVel;

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

    _pitchVel = _pitchVel * _damping;
    _yawVel = _yawVel * _damping;

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

    switch (_flightMode) do {
        case 0;
        case 2;
        case 3: {
            _projectile setVectorDirAndUp [_forward, _up];
            _projectile setVelocityModelSpace [0, _projectileSpeed, 0];
        };
        case 1:{
            _dir = vectorDir _projectile;
            _pitch = (_dir # 2) atan2 (sqrt ((_dir # 0)^2 + (_dir # 1)^2));
            _yaw = getDir _projectile;

            _pitchVel = 0;
            _yawVel = 0;

            _projectileSpeed = velocityModelSpace _projectile # 1;
        };
    };

    private _zoomInMap = inputAction "zoomIn";
    if (_zoomInMap > 0) then {
        waitUntil {
            inputAction "zoomIn" == 0
        };
        private _currentZoom = ctrlMapScale _mapDisplay;
        _mapDisplay ctrlMapAnimAdd [0, _currentZoom / 2, getPosASL _projectile];
        ctrlMapAnimCommit _mapDisplay;
    };
    private _zoomOutMap = inputAction "zoomOut";
    if (_zoomOutMap > 0) then {
        waitUntil {
            inputAction "zoomOut" == 0
        };
        private _currentZoom = ctrlMapScale _mapDisplay;
        _mapDisplay ctrlMapAnimAdd [0, _currentZoom * 2, getPosASL _projectile];
        ctrlMapAnimCommit _mapDisplay;
    };

    if (inputAction "nightVision" > 0) then {
        waitUntil {inputAction "nightVision" == 0};
        _nightVision = !_nightVision;
    };
    private _sensorsDisabled = _projectile getVariable ["WL_sensorsDisabled", false];
    if (_nightVision && !_sensorsDisabled) then {
        true setCamUseTI 0;
    } else {
        false setCamUseTI 0;
    };

    if (inputAction "defaultAction" > 0) then {
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

    sleep 0.001;
};

sleep 1;
deleteVehicle _projectile;
"missileCamera" cutText ["", "PLAIN"];