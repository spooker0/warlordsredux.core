params ["_projectile", "_camera"];
player setVariable ["WL_hmdOverride", 1];

private _nightVision = false;
private _projectileIsShell = _projectile isKindOf "ShellCore";

uiNamespace setVariable ["WL_waypointPosition", customWaypointPosition];

_camera switchCamera "INTERNAL";
cameraEffectEnableHUD true;
showHUD [true, true, true, true, true, true, true, true, true, true, true];

private _waypointDrawer = addMissionEventHandler ["Draw3D", {
    private _waypointPosition = uiNamespace getVariable ["WL_waypointPosition", []];
    if (count _waypointPosition == 0) exitWith {};
    drawIcon3D [
        "\A3\ui_f\data\IGUI\RscIngameUI\RscOptics\square.paa",
        [1, 1, 1, 1],
        _waypointPosition,
        0.3,
        0.3,
        0,
        "WAYPOINT",
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