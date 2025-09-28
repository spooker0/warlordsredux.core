#include "includes.inc"

if (isDedicated) exitWith {};

private _display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
if (isNull _display) then {
	"turretLimits" cutRsc ["RscWLTurretMenu", "PLAIN", -1, true, true];
	_display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _draw3dHandler = addMissionEventHandler ["Draw3D", {
    private _display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
    private _texture = _display displayCtrl 5502;

    if (cameraOn == player) exitWith {
        "turretLimits" cutText ["", "PLAIN"];
    };
    private _allTurrets = allTurrets [cameraOn, false];
    private _occupiedTurrets = _allTurrets select {
        !isNull (cameraOn turretUnit _x)
    };

    private _screenPoints = [];
    private _weaponScreenPoints = [];
    {
        private _turretData = [_x] call WL2_fnc_turretLimits;
        private _turretLimits = _turretData # 0;
        private _weaponScreenPoint = _turretData # 1;
        _screenPoints append _turretLimits;
        _weaponScreenPoints pushBack _weaponScreenPoint;
    } forEach _occupiedTurrets;

    private _script = format [
        "setReferencePoints(%1);setBoxLines(%2);",
        toJSON _weaponScreenPoints,
        toJSON _screenPoints
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
}];

waitUntil {
    sleep 0.1;
    !alive player || 
    !alive cameraOn ||
    isNull _display
};

"turretLimits" cutText ["", "PLAIN"];
removeMissionEventHandler ["Draw3D", _draw3dHandler];