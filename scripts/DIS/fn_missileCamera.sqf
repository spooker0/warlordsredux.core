#include "includes.inc"
params ["_projectile", "_unit"];

private _originalPipViewDistance = getPiPViewDistance;
setPiPViewDistance viewDistance;

"APS_Camera" cutRsc ["RscTitleDisplayEmpty", "PLAIN", -1, true, true];

private _display = uiNamespace getVariable "RscTitleDisplayEmpty";

private _defaultTitlePosition = [safezoneX + 0.2, safezoneY + 0.1, safeZoneW / 4, 0.05];
private _defaultPicturePosition = [safezoneX + 0.2, safeZoneY + 0.15, safeZoneW / 4, safeZoneW / 4];

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
            sleep 0.001;
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

[_camera, _titleBar, _pictureControl, _defaultTitlePosition, _defaultPicturePosition] spawn {
    params ["_camera", "_titleBar", "_pictureControl", "_defaultTitlePosition", "_defaultPicturePosition"];
    private  _opticsMode = missionNamespace getVariable ["DIS_missileCameraOpticsMode", 0];
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
                    private _largeTitlePosition = [safeZoneX + 0.2, safeZoneY + 0.15, safeZoneW - 0.4, 0.05];
                    private _largePicturePosition = [safeZoneX + 0.2, safeZoneY + 0.2, safeZoneW - 0.4, safeZoneH - 0.3];
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
    sleep 0.5;

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

sleep 1.5;

camDestroy _camera;
"APS_Camera" cutFadeOut 0;
removeMissionEventHandler ["Draw3D", _targetDrawer];

sleep 2;

setPiPViewDistance _originalPipViewDistance;