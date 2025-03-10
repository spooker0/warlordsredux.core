#include "..\..\warlords_constants.inc"

params [["_requirements", []], ["_category", ""]];

private _findCurrentSector = (BIS_WL_sectorsArray # 0) select {
    player inArea (_x getVariable "objectAreaComplete")
};

private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBaseCategoryMap = [
    [""],
    ["", "Infantry", "Gear"],
    ["", "Infantry", "Gear", "Light Vehicles", "Sector Defense"],
    ["", "Infantry", "Gear", "Light Vehicles", "Sector Defense", "Heavy Vehicles", "Rotary Wing", "Air Defense", "Remote Control"]
];
private _forwardBases = _potentialBases select {
    private _fobLevel = _x getVariable ["WL2_forwardBaseLevel", 0];
    player distance2D _x < 100 &&
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide &&
    _fobLevel > 0 &&
    _category in (_forwardBaseCategoryMap # _fobLevel)
};

private _inRange = count _forwardBases > 0 || count _findCurrentSector > 0;

if (!_inRange && !("A" in _requirements) && !("W" in _requirements)) exitWith {
    [false, localize "STR_A3_WL_menu_arsenal_restr1"];
};

[true, ""];