#include "..\..\warlords_constants.inc"

params ["_category", "_class"];

if (_category != "Fixed Wing" && _category != "Rotary Wing" && _category != "Remote Control") exitWith {
    [true, ""]
};

private _costMap = missionNamespace getVariable ["WL2_costs", createHashMap];
private _assetCost = _costMap getOrDefault [_class, 0];

if (_assetCost < 5000) exitWith {
    [true, ""]
};

// private _players = (playersNumber west) + (playersNumber east);

if ((playersNumber west) <= 7 && (playersNumber east) <= 7) then {
    [false, "Player count is too small to deploy heavily armed aerial assets!"]
} else {
    [true, ""]
};