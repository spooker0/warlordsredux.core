#include "includes.inc"
params [["_closeOnly", false]];

if (!hasInterface) exitWith {};
disableSerialization;

private _vehicle = cameraOn;
private _assetType = WL_ASSET_TYPE(_vehicle);
private _hasVisualizer = WL_ASSET(_assetType, "hasTurretVisualizer", 0) > 0;
private _canOpen = !_closeOnly && _hasVisualizer && alive _vehicle && alive player;

private _state = uiNamespace getVariable ["WL2_turretVisualizer", createHashMap];
private _trackedVehicle = _state getOrDefault ["vehicle", objNull];
private _trackedDisplay = _state getOrDefault ["display", displayNull];
if (_canOpen && _trackedVehicle == _vehicle && !isNull _trackedDisplay) exitWith {};

if (count _state > 0) then {
    uiNamespace setVariable ["WL2_turretVisualizer", nil];
    private _eventHandlers = _state getOrDefault ["handlers", []];
    {
        removeMissionEventHandler _x;
    } forEach _eventHandlers;
    "WL2_turretVisualizer" cutText ["", "PLAIN"];
};

if (!_canOpen) exitWith {};

"WL2_turretVisualizer" cutRsc ["RscWLTurretVisualizer", "PLAIN", -1, false, true];

private _display = uiNamespace getVariable ["RscWLTurretVisualizer", displayNull];
if (isNull _display) exitWith {};

_state = createHashMapFromArray [
    ["display", _display],
    ["vehicle", _vehicle],
    ["handlers", []],
    ["lines", []],
    ["labels", []],
    ["geometry", createHashMap],
    ["referenceASL", []],
    ["headlightsHeld", false]
];
uiNamespace setVariable ["WL2_turretVisualizer", _state];

_display displayAddEventHandler ["Unload", {
    params ["_unloadedDisplay"];

    private _state = uiNamespace getVariable ["WL2_turretVisualizer", createHashMap];
    if (count _state == 0) exitWith {};

    private _trackedDisplay = _state getOrDefault ["display", displayNull];
    if (_trackedDisplay != _unloadedDisplay) exitWith {};

    uiNamespace setVariable ["WL2_turretVisualizer", nil];

    private _eventHandlers = _state getOrDefault ["handlers", []];
    {
        removeMissionEventHandler _x;
    } forEach _eventHandlers;
}];

private _drawHandler = addMissionEventHandler ["Draw3D", {
    [true] call WL2_fnc_drawTurretVisualizer;
}];

// Draw3D can stop while the map is open. Keep input, hiding and cleanup alive.
private _updateHandler = addMissionEventHandler ["EachFrame", {
    [false] call WL2_fnc_drawTurretVisualizer;
}];

private _eventHandlers = [
    ["Draw3D", _drawHandler],
    ["EachFrame", _updateHandler]
];
_state set ["handlers", _eventHandlers];

if (typeOf _vehicle == "B_T_VTOL_01_armed_F") then {
    ["Blackfish", ["BLACKFISH CONTROLS", [
        ["Set Reference Point", "headlights"]
    ]], 10] spawn WL2_fnc_showHint;
};
