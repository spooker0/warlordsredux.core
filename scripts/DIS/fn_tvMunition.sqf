params ["_projectile"];

private _camera = "camera" camCreate (position _projectile);
_camera camSetTarget _projectile;
_camera camSetRelPos [0, 1, 0];
_camera camCommit 0;
_camera attachTo [_projectile];

player setVariable ["WL_hmdOverride", 2];

private _nightVision = false;
private _projectileIsShell = _projectile isKindOf "ShellCore";

uiNamespace setVariable ["WL_waypointPosition", customWaypointPosition];

_camera switchCamera "INTERNAL";
cameraEffectEnableHUD true;
showHUD [true, true, true, true, true, true, true, true, true, true, true];

private _waypointDrawer = addMissionEventHandler ["Draw3D", {
    private _waypointPosition = uiNamespace getVariable ["WL_waypointPosition", []];
    if (count _waypointPosition == 0) exitWith {};
    private _distance = _waypointPosition distance cameraOn;
    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscIngameUI\RscOptics\square.paa",
        [1, 1, 1, 1],
        _waypointPosition,
        0.3,
        0.3,
        0,
        format ["WAYPOINT %1KM", (_distance / 1000) toFixed 1],
        0,
        0.02,
        "TahomaB",
        "center",
        true,
        0,
        0.01
    ];
}];

_projectile setVariable ["BIS_WL_ownerAssetSide", BIS_WL_playerSide];
_projectile setVariable ["WL_tvMunition", true];
[_projectile, player] spawn WL2_fnc_uavJammer;

private _flightMode = if (_projectileIsShell) then {
    1
} else {
    0
};
[_projectile, _flightMode] call DIS_fnc_controlMunition;

player setVariable ["WL_hmdOverride", -1];
removeMissionEventHandler ["Draw3D", _waypointDrawer];
switchCamera player;