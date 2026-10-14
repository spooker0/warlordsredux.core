#include "..\includes.inc"
#include "..\..\includes.inc"

private _projectiles = "true" configClasses (missionConfigFile >> "WLProjectilesConfig");
private _spartanIndex = _projectiles findIf {
    "ammo_Missile_rim116" in getArray (_x >> "ammo");
};
if (_spartanIndex < 0) exitWith {
    hint localize "STR_WL_pilotMissingSpartan";
    createHashMap;
};
private _spartan = _projectiles # _spartanIndex;
private _minimum = getNumber (_spartan >> "flareMin");
private _maximum = getNumber (_spartan >> "flareMax");

// Freeze this illustration at the current sector coordinates, independently of sector configuration.
private _sites = [
    [[12293, 8891.32, 0], "O_SAM_System_04_F", localize "STR_WL_pilotRhea", 3000],
    [[10072, 11358.1, 0], "B_SAM_System_01_F", localize "STR_WL_pilotSpartan", 2200],
    [[14214.5, 13007.4, 0], "B_SAM_System_02_F", localize "STR_WL_pilotCenturion", 2500],
    [[13796.8, 6403.77, 0], "B_SAM_System_03_F", localize "STR_WL_pilotDefender", 1800]
];
_sites = _sites apply {
    _x params ["_position", "_vehicle", "_name", "_radius"];
    [_position, getText (configFile >> "CfgVehicles" >> _vehicle >> "icon"), _name, _radius];
};

private _panagia = [20419.4, 8847.76, 0];
private _westEdge = _panagia # 0;
private _eastEdge = _panagia # 0;
private _southEdge = _panagia # 1;
private _northEdge = _panagia # 1;
{
    _x params ["_position", "", "", "_radius"];
    _westEdge = _westEdge min ((_position # 0) - _radius);
    _eastEdge = _eastEdge max ((_position # 0) + _radius);
    _southEdge = _southEdge min ((_position # 1) - _radius);
    _northEdge = _northEdge max ((_position # 1) + _radius);
} forEach _sites;
private _overviewCenter = [(_westEdge + _eastEdge) / 2, (_southEdge + _northEdge) / 2, 0];
private _overviewSpan = [_eastEdge - _westEdge + 2400, _northEdge - _southEdge + 1600];
private _defaultFlares = [15, 6, 5];
private _flares = WL_ASSET("B_Plane_Fighter_01_F", "flares", _defaultFlares);

// Begin the singles example as soon as the last burst pair has faded.
private _singlesStart = 1 + 9 * 0.06 + 2.5;
private _flareDemoDuration = _singlesStart + 9 * 0.75 + 3;

createHashMapFromArray [
    ["header", localize "STR_WL_pilotHeader"],
    ["scenes", [
        [8, localize "STR_WL_pilotMissileWindow"],
        [10, localize "STR_WL_pilotPerpendicular"],
        [_flareDemoDuration, localize "STR_WL_pilotSingles"],
        [6, localize "STR_WL_pilotAltitude"],
        [6, localize "STR_WL_pilotSpeed"],
        [3, localize "STR_WL_pilotAwareness"]
    ]],
    ["state", createHashMapFromArray [
        ["spartanMin", _minimum],
        ["spartanMax", _maximum],
        ["launchDistance", _maximum + 1000],
        ["pauseDistance", (_minimum + _maximum) / 2],
        ["pilotFlares", _flares],
        ["singlesStart", _singlesStart],
        ["launcher", [14324.9, 16178.7, 0]],
        ["jetIcon", getText (configFile >> "CfgVehicles" >> "B_Plane_Fighter_01_F" >> "icon")],
        ["sideJetIcon", "a3\ui_f\data\gui\rsc\rscdisplaygarage\plane_ca.paa"],
        ["spartanIcon", getText (configFile >> "CfgVehicles" >> "B_SAM_System_01_F" >> "icon")],
        ["launchKey", ["launchCM"] call TUT_fnc_keyName],
        ["modeKey", ["nextCM"] call TUT_fnc_keyName],
        ["sites", _sites],
        ["routeStart", _panagia],
        ["routeEnd", [15400, 8847.76, 0]],
        ["overviewCenter", _overviewCenter],
        ["overviewSpan", _overviewSpan]
    ]],
    ["init", {
        uiNamespace setVariable ["TUT_pilotSurvivalShown", true];
    }],
    ["enter", TUT_fnc_pilotEnter],
    ["update", TUT_fnc_pilotUpdate],
    ["draw", TUT_fnc_pilotDraw]
];
