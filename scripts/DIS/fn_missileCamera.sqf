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

uiNamespace setVariable ["APS_Camera_Projectile", _projectile];
private _targetDrawer = addMissionEventHandler ["Draw3D", {
    private _projectile = uiNamespace getVariable ["APS_Camera_Projectile", objNull];
    if (isNull _projectile) exitWith {};
    private _coordinates = _projectile getVariable ["DIS_targetCoordinates", []];
    private _targetPosATL = if (count _coordinates == 0) then {
        (missileTarget _projectile) modelToWorld [0, 0, 0]
    } else {
        _coordinates
    };
    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscIngameUI\RscOptics\AzimuthMark.paa",
        [1, 0, 0, 1],
        _targetPosATL,
        1,
        1,
        180,
        "TARGET",
        0,
        0.02,
        "TahomaB",
        "center",
        true,
        0,
        0.01
    ];
}];

[_camera, _titleBar, _pictureControl, _defaultOpticsMode] spawn {
    params ["_camera", "_titleBar", "_pictureControl", "_defaultOpticsMode"];
    private _opticsMode = _defaultOpticsMode;
    if (_opticsMode == 3) exitWith {
        _titleBar ctrlShow false;
        _pictureControl ctrlShow false;
        _titleBar ctrlCommit 0;
        _pictureControl ctrlCommit 0;
    };
    private _changed = true;
    private _originalCamera = cameraOn;
    private _originalCamView = cameraView;
    private _originalRemote = if (isRemoteControlling player) then {
        getConnectedUAVUnit player;
    } else {
        objNull
    };
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
                };
                case 1: {
                    _titleBar ctrlShow false;
                    _pictureControl ctrlShow false;

                    _camera switchCamera "INTERNAL";
                    cameraEffectEnableHUD true;
                    showHUD [true, true, true, true, true, true, true, true, true, true, true];
                };
                case 2: {
                    _titleBar ctrlShow false;
                    _pictureControl ctrlShow false;
                    _originalCamera switchCamera _originalCamView;
                    if (!isNull _originalRemote) then {
                        player remoteControl _originalRemote;
                    };
                };
            };
            _titleBar ctrlCommit 0;
            _pictureControl ctrlCommit 0;
            _changed = false;
        };
    };
};

if (_defaultOpticsMode == 3) then {
    [_projectile, _camera] spawn DIS_fnc_tvMunition;
};

private _originalCamera = cameraOn;
private _originalCamView = cameraView;
private _originalRemote = if (isRemoteControlling player) then {
    getConnectedUAVUnit player;
} else {
    objNull
};

while { !_stop } do {
    sleep 0.5;

    private _projectilePosition = position _projectile;
    private _projectileDirection = _projectile modelToWorld [0, 1000, 0];
    private _isDestroyed = _projectilePosition isEqualTo [0, 0, 0] || _projectileDirection isEqualTo [0, 0, 0];
    private _expired = (time - _startTime) > WL_SAM_TIMEOUT;
    private _disconnected = unitIsUAV _unit && isNull (getConnectedUAV player);
    private _playerDown = !alive player || lifeState player == "INCAPACITATED";

    _stop = isNull _projectile || !alive _projectile || _isDestroyed || _expired || _disconnected || _projectile getEntityInfo 14 || _playerDown;

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
removeMissionEventHandler ["Draw3D", _targetDrawer];

_originalCamera switchCamera _originalCamView;
if (!isNull _originalRemote) then {
    player remoteControl _originalRemote;
};

setPiPViewDistance _originalPipViewDistance;