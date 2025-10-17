#include "includes.inc"
params ["_projectile", "_unit"];

private _originalPipViewDistance = getPiPViewDistance;
setPiPViewDistance viewDistance;

private _display = uiNamespace getVariable ["RscWLMissileCameraDisplay", objNull];
if (!isNull _display) then {
    "missileCamera" cutFadeOut 0;
};
"missileCamera" cutRsc ["RscWLMissileCameraDisplay", "PLAIN", -1, true, true];
_display = uiNamespace getVariable "RscWLMissileCameraDisplay";

private _camera = "camera" camCreate (position _projectile);
_camera cameraEffect ["Terminate", "BACK TOP", "rtt1"];
_camera cameraEffect ["Internal", "BACK TOP", "rtt1"];

"rtt1" setPiPEffect [currentVisionMode player];

uiNamespace setVariable ["APS_Camera_Cam", _camera];

private _stop = false;
private _lastKnownPosition = position _unit;
private _lastKnownDirection = _projectile modelToWorld [0, 1000, 0];
private _startTime = time;

if (_projectile isKindOf "SubmunitionBase") then {
    [_camera, _projectile] spawn {
        params ["_camera", "_projectile"];
        while { alive _camera && alive _projectile } do {
            _camera setPosASL (_projectile modelToWorldWorld [0, 20, 0]);
            _camera setVectorDirAndUp [vectorDir _projectile, vectorUp _projectile];
            uiSleep 0.001;
        };
    };
} else {
    _camera camSetFov 0.75;
    _camera camSetTarget _projectile;
    _camera camSetRelPos [0, -3, 0.4];
    _camera camCommit 0;

    _camera attachTo [_projectile];
};

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
    if (_targetPosATL isEqualTo [0, 0, 0]) exitWith {};
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

[_camera, _display] spawn {
    params ["_camera", "_display"];
    private _titleBar = _display displayCtrl 5110;
    private _pictureControl = _display displayCtrl 5111;

    private  _opticsMode = missionNamespace getVariable ["DIS_missileCameraOpticsMode", 0];

    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    private _missileCameraLeft = _settingsMap getOrDefault ["missileCameraLeft", 0];
    private _missileCameraTop = _settingsMap getOrDefault ["missileCameraTop", 100];

    private _totalWidth = safeZoneW - safeZoneW / 4;
    private _totalHeight = safeZoneH - safeZoneW / 4 - 0.05;
    private _windowLeft = (_missileCameraLeft / 100) * _totalWidth + safeZoneX;
    private _windowTop = (_missileCameraTop / 100) * _totalHeight + safeZoneY;

    private _defaultTitlePosition = [_windowLeft, _windowTop, safeZoneW / 4, 0.05];
    private _defaultPicturePosition = [_windowLeft, _windowTop + 0.05, safeZoneW / 4, safeZoneW / 4];

    _titleBar ctrlSetPosition _defaultTitlePosition;
    _pictureControl ctrlSetPosition _defaultPicturePosition;
    _titleBar ctrlCommit 0;
    _pictureControl ctrlCommit 0;

    private _largeTitlePosition = [safeZoneX + 0.2, safeZoneY + 0.15, safeZoneW - 0.4, 0.05];
    private _largePicturePosition = [safeZoneX + 0.2, safeZoneY + 0.2, safeZoneW - 0.4, safeZoneH - 0.3];

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
                    _titleBar ctrlSetPosition _largeTitlePosition;
                    _pictureControl ctrlSetPosition _largePicturePosition;
                };
                case 2: {
                    _titleBar ctrlShow false;
                    _pictureControl ctrlShow false;
                };
            };
            _titleBar ctrlCommit 0;
            _pictureControl ctrlCommit 0;
            _changed = false;
            missionNamespace setVariable ["DIS_missileCameraOpticsMode", _opticsMode];
        };
    };
};

while { !_stop } do {
    uiSleep 0.5;

    private _projectilePosition = getPosASL _projectile;
    private _projectileDirection = _projectile modelToWorld [0, 1000, 0];
    private _isDestroyed = _projectilePosition isEqualTo [0, 0, 0] || _projectileDirection isEqualTo [0, 0, 0];
    private _disconnected = unitIsUAV _unit && isNull (getConnectedUAV player);
    private _playerDead = !alive player;

    _stop = isNull _projectile || !alive _projectile || _isDestroyed || _disconnected || _projectile getEntityInfo 14 || _playerDead;

    "rtt1" setPiPEffect [currentVisionMode player];

    if (!_stop) then {
        _lastKnownPosition = _projectilePosition;
        _lastKnownDirection = _projectileDirection;
    };
};

_camera camSetPos _lastKnownPosition;
_camera camSetTarget _lastKnownDirection;
_camera camCommit 0;

uiSleep 1.5;

camDestroy _camera;
"missileCamera" cutFadeOut 0;
removeMissionEventHandler ["Draw3D", _targetDrawer];

uiSleep 2;

setPiPViewDistance _originalPipViewDistance;