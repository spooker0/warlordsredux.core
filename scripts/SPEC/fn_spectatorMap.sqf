#include "includes.inc"

private _existingMapDisplay = uiNamespace getVariable ["SPEC_MapDisplay", displayNull];
if (!isNull _existingMapDisplay) exitWith {
    closeDialog 0;
};

private _spectatorDisplay = createDialog ["RscSpectatorDisplay", true];
uiNamespace setVariable ["SPEC_MapDisplay", _spectatorDisplay];
private _mapControl = _spectatorDisplay displayCtrl 5503;
_mapControl ctrlMapAnimAdd [0, 0.2, getPosASL cameraOn];
ctrlMapAnimCommit _mapControl;

_mapControl ctrlAddEventHandler ["Draw", WL2_fnc_mapEachFrame];
_mapControl ctrlAddEventHandler ["Draw", WL2_fnc_iconDrawMap];

_mapControl ctrlAddEventHandler ["Draw", {
    params ["_map"];
    private _start = uiNamespace getVariable ["SPEC_mouseClickStart", []];
    if (count _start == 0) exitWith {};

    private _posStart = _map ctrlMapScreenToWorld _start;
    private _posEnd = _map ctrlMapScreenToWorld getMousePosition;

    if (_posStart distance2D _posEnd > 10) then {
        _map drawArrow [
            _posStart,
            _posEnd,
            [1, 0, 0, 1]
        ];
    };
}];

_mapControl ctrlAddEventHandler ["MouseButtonDown", {
    params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    if (_button != 0) exitWith {};
    // Start map drag
    uiNamespace setVariable ["SPEC_mouseClickStart", [_xPos, _yPos]];
}];

_mapControl ctrlAddEventHandler ["MouseButtonUp", {
    params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    if (_button != 0) exitWith {};

    private _start = uiNamespace getVariable ["SPEC_mouseClickStart", []];
    if (count _start == 0) exitWith {};
    uiNamespace setVariable ["SPEC_mouseClickStart", []];

    // Reset to free cam in scripts
    uiNamespace setVariable ["SPEC_CameraTarget", objNull];

    if !(cameraOn isKindOf "Camera") exitWith {};
    private _posStart = _map ctrlMapScreenToWorld _start;
    _posStart set [2, (getPosATL cameraOn) # 2];

    private _posEnd = _map ctrlMapScreenToWorld [_xPos, _yPos];
    _posEnd set [2, 0];

    if (_posStart distance2D _posEnd > 10) then {
        private _targetVectorDirAndUp = [_posStart, _posEnd] call BIS_fnc_findLookAt;
        cameraOn setVectorDirAndUp _targetVectorDirAndUp;
    };

    cameraOn setPosATL _posStart;
}];