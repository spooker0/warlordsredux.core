#include "includes.inc"

if (isDedicated) exitWith {};

private _display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
if (isNull _display) then {
	"turretLimits" cutRsc ["RscWLTurretMenu", "PLAIN", -1, true, true];
	_display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

uiNamespace setVariable ["WL2_turretRefPoint", [0, 0, 0]];

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

    private _refPointScript = "setReferencePoint(-1, -1);setDesiredPoint(-1);";
    if (typeof cameraOn == "B_T_VTOL_01_armed_F") then {
        private _referencePointData = [[-1], true] call WL2_fnc_turretLimits;
        if (count _referencePointData == 4) then {
            private _referencePoint = _referencePointData # 0;
            private _desiredPoint = _referencePointData # 1;
            private _screenPoint = _referencePointData # 2;
            private _noseElev = _referencePointData # 3;
            _refPointScript = format [
                "setReferencePoint(%1, %2);setDesiredPoint(%3, %4, %5, %6);", 
                _referencePoint # 0, 
                _referencePoint # 1,
                _desiredPoint # 0,
                _screenPoint # 0,
                _screenPoint # 1,
                _noseElev
            ];
        };
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
        "setCrosshairs(%1);setBoxLines(%2);%3",
        toJSON _weaponScreenPoints,
        toJSON _screenPoints,
        _refPointScript
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
}];

0 spawn {
    private _display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];
    private _texture = _display displayCtrl 5502;

    while { alive player && alive cameraOn && !isNull _display } do {
        if (visibleMap) then {
            _texture ctrlWebBrowserAction [
                "ExecJS",
                "setCrosshairs([]);setBoxLines([]);setReferencePoint(-1, -1);setDesiredPoint(-1);"
            ];
        };
        sleep 0.001;
    };
};

if (typeof cameraOn == "B_T_VTOL_01_armed_F") then {
    ["Blackfish", ["BLACKFISH CONTROLS", [
        ["Set Reference Point", "headlights"]
    ]], 10] call WL2_fnc_showHint;

    0 spawn {
        private _display = uiNamespace getVariable ["RscWLTurretMenu", displayNull];

        while { alive player && alive cameraOn && !isNull _display } do {
            if (inputAction "headlights" > 0) then {
                waitUntil {
                    inputAction "headlights" == 0
                };

                private _referencePoint = uiNamespace getVariable ["WL2_turretRefPoint", [0, 0, 0]];
                if (_referencePoint isEqualTo [0, 0, 0]) then {
                    private _hitPoint = screenToWorld [0.5, 0.5];
                    uiNamespace setVariable ["WL2_turretRefPoint", _hitPoint];
                } else {
                    uiNamespace setVariable ["WL2_turretRefPoint", [0, 0, 0]];
                };
            };
            sleep 0.001;
        };
    };
};

waitUntil {
    sleep 0.1;
    !alive player || 
    !alive cameraOn ||
    isNull _display
};

"turretLimits" cutText ["", "PLAIN"];
removeMissionEventHandler ["Draw3D", _draw3dHandler];