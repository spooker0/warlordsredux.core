#include "constants.inc"

params ["_projectile", "_unit", "_fov", "_defaultOpticsMode"];

private _originalPipViewDistance = getPiPViewDistance;
setPiPViewDistance viewDistance;

"APS_Camera" cutRsc ["RscTitleDisplayEmpty", "PLAIN", -1, true, true];

private _display = uiNamespace getVariable "RscTitleDisplayEmpty";

private _pictureSize = 1.5;

private _defaultTitlePosition = [safezoneX + 0.2, safezoneY + 0.1, 0.4 * _pictureSize, 0.05];
private _defaultPicturePosition = [safezoneX + 0.2, safeZoneY + 0.15, 0.4 * _pictureSize, 0.4 * _pictureSize];

private _titleBar = _display ctrlCreate ["RscText", -1];
_titleBar ctrlSetPosition _defaultTitlePosition;
_titleBar ctrlSetBackgroundColor [0, 0, 0, 0.9];
_titleBar ctrlSetTextColor [1, 1, 1, 1];
_titleBar ctrlSetText "Missile Camera";
_titleBar ctrlCommit 0;

private _pictureControl = _display ctrlCreate ["RscPicture", -1];
_pictureControl ctrlSetPosition _defaultPicturePosition;
_pictureControl ctrlSetText "#(argb,512,512,1)r2t(rtt1,1.0)";
_pictureControl ctrlCommit 0;

private _camera = "camera" camCreate (position _projectile);
_camera cameraEffect ["Internal", "BACK TOP", "rtt1"];

"rtt1" setPiPEffect [currentVisionMode player];

uiNamespace setVariable ["APS_Camera_Cam", _camera];

private _stop = false;
private _lastKnownPosition = position _unit;
private _lastKnownDirection = _projectile modelToWorld [0, 1000, 0];
private _startTime = time;

_camera camSetFov _fov;
_camera camSetTarget _projectile;
if (_defaultOpticsMode == 3) then {
    _camera camSetRelPos [0, 1, 0];
} else {
    _camera camSetRelPos [0, -3, 0.4];
};
_camera camCommit 0;

_camera attachTo [_projectile];

[_camera, _titleBar, _pictureControl, _defaultTitlePosition, _defaultPicturePosition, _defaultOpticsMode] spawn {
    params ["_camera", "_titleBar", "_pictureControl", "_defaultTitlePosition", "_defaultPicturePosition", "_defaultOpticsMode"];
    private _opticsMode = _defaultOpticsMode;
    if (_opticsMode == 3) exitWith {
        _titleBar ctrlShow false;
        _pictureControl ctrlShow false;
        _titleBar ctrlCommit 0;
        _pictureControl ctrlCommit 0;
    };
    private _changed = true;
    while { !isNull _camera } do {
        if (inputAction "opticsMode" > 0) then {
            waitUntil {inputAction "opticsMode" == 0};
            _opticsMode = (_opticsMode + 1) % 3;
            _changed = true;
        };
        if (_changed) then {
            switch (_opticsMode) do {
                case 0: {
                    _titleBar ctrlShow true;
                    _pictureControl ctrlShow true;
                    _titleBar ctrlSetPosition _defaultTitlePosition;
                    _pictureControl ctrlSetPosition _defaultPicturePosition;
                };
                case 1: {
                    _titleBar ctrlShow true;
                    _pictureControl ctrlShow true;
                    _titleBar ctrlSetPosition [safeZoneX / 2, safeZoneY / 2 - 0.05, 1 - safeZoneX, 0.05];
                    _pictureControl ctrlSetPosition [safeZoneX / 2, safeZoneY / 2, 1 - safeZoneX, 1 - safeZoneY];
                };
                case 2: {
                    _titleBar ctrlShow false;
                    _pictureControl ctrlShow false;
                };
            };
            _titleBar ctrlCommit 0;
            _pictureControl ctrlCommit 0;
            _changed = false;
        };
    };
};

if (_defaultOpticsMode == 3) then {
    [_projectile, _camera] spawn {
        params ["_projectile", "_camera"];
        private _yaw = getDir _projectile;

        private _dir = vectorDir _projectile;
        private _pitch = (_dir select 2) atan2 (sqrt ((_dir select 0)^2 + (_dir select 1)^2));

        private _pitchVel = 0;
        private _yawVel   = 0;

        private _maxRotSpeed   = 1;
        private _acceleration  = 0.01;
        private _damping       = 0.95;
        private _inputPerTime = 60;

        private _nightVision = false;

        _camera switchCamera "INTERNAL";

        showHUD [true, true, true, true, true, true, true, true, true, true, true];

        "missileCamera" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
		private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
        private _background = _display ctrlCreate ["RscPicture", -1];
		_background ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
		_background ctrlSetText "\a3\weapons_f\Reticle\data\optika_tv_CA.paa";
		_background ctrlCommit 0;

		private _reticle = _display ctrlCreate ["RscPicture", -1];
		_reticle ctrlSetPosition [1 / 8, 0, 3 / 4, 1];
		_reticle ctrlSetText "\a3\weapons_f\Reticle\data\Optics_Gunner_MBT_02_M_CA.paa";
		_reticle ctrlCommit 0;

		private _fuelDisplay = _display ctrlCreate ["RscStructuredText", -1];
		_fuelDisplay ctrlSetPosition [0, 0, 1, 0.2];
		_fuelDisplay ctrlSetTextColor [1, 1, 1, 1];
		_fuelDisplay ctrlCommit 0;

        private _instructionsDisplay = _display ctrlCreate ["RscStructuredText", -1];
        _instructionsDisplay ctrlSetPosition [0.7, 0.9, 0.5, 0.2];
        _instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];
        _instructionsDisplay ctrlSetStructuredText parseText format [
            "<t align='left' size='1.2'>[%1] Detonate<br/>[%2] Thermal Vision</t>",
            (actionKeysNames ["defaultAction", 1, "Combo"]) regexReplace ["""", ""],
            (actionKeysNames ["nightVision", 1, "Combo"]) regexReplace ["""", ""]
        ];
        _instructionsDisplay ctrlCommit 0;

        private _lastTime = serverTime;
        private _startTime = serverTime;
        private _timeToLive = getNumber (configFile >> "CfgAmmo" >> (typeOf _projectile) >> "timeToLive");

        sleep 1;

        while {alive _projectile} do {
            private _elapsedTime = serverTime - _lastTime;
            _lastTime = serverTime;

            private _pitchInput = (inputAction "AimHeadUp") - (inputAction "AimHeadDown");
            private _yawInput   = (inputAction "AimHeadLeft") - (inputAction "AimHeadRight");

            private _inputFactor = _inputPerTime * _elapsedTime;
            _pitchVel = _pitchVel + (_pitchInput * _acceleration * _inputFactor);
            _yawVel = _yawVel + (_yawInput * _acceleration * _inputFactor);

            _pitchVel = _pitchVel max (-_maxRotSpeed) min _maxRotSpeed;
            _yawVel = _yawVel max (-_maxRotSpeed) min _maxRotSpeed;

            _pitch = _pitch + _pitchVel;
            _yaw = _yaw - _yawVel;

            _pitch = 89 min (_pitch max -80);

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

            _projectile setVectorDirAndUp [_forward, _up];
            _projectile setVelocityModelSpace [0, 100, -1];

            if (inputAction "nightVision" > 0) then {
                waitUntil {inputAction "nightVision" == 0};
                _nightVision = !_nightVision;
            };
            if (_nightVision) then {
                true setCamUseTI 0;
            } else {
                false setCamUseTI 0;
            };

            if (inputAction "defaultAction" > 0) then {
                triggerAmmo _projectile;
            };

            _fuelDisplay ctrlSetStructuredText parseText format [
                "<t align='center' size='2'>Fuel: %1%%</t>",
                round (100 * (_timeToLive - (serverTime - _startTime)) / _timeToLive)
            ];
            sleep 0.001;
        };

        switchCamera player;

        "missileCamera" cutText ["", "PLAIN"];
    };
};

while { !_stop } do {
    sleep 0.5;

    private _projectilePosition = position _projectile;
    private _projectileDirection = _projectile modelToWorld [0, 1000, 0];
    private _isDestroyed = _projectilePosition isEqualTo [0, 0, 0] || _projectileDirection isEqualTo [0, 0, 0];
    private _expired = (time - _startTime) > WL_SAM_TIMEOUT;
    private _disconnected = unitIsUAV _unit && isNull (getConnectedUAV player);

    _stop = isNull _projectile || !alive _projectile || _isDestroyed || _expired || _disconnected || _projectile getEntityInfo 14;

    "rtt1" setPiPEffect [currentVisionMode player];

    if (!_stop) then {
        _lastKnownPosition = _projectilePosition;
        _lastKnownDirection = _projectileDirection;
    };
};

_camera camSetPos _lastKnownPosition;
_camera camSetTarget _lastKnownDirection;
_camera camCommit 0;

sleep 1.5;

_camera cameraEffect ["Terminate", "BACK TOP"];
camDestroy _camera;
"APS_Camera" cutFadeOut 0;

setPiPViewDistance _originalPipViewDistance;