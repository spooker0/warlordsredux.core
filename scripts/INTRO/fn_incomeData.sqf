#include "includes.inc"
params [["_sectors", createHashMap]];

private _route = ["Airbase", "AirbaseCompound", "MainPower", "SouthTelos"];
private _routeData = createHashMap;
private _positions = [];
{
    private _data = _sectors getOrDefault [_x, createHashMap];
    if (count _data == 0) then { _data = [_x] call INTRO_fnc_sectorData; };
    if (count _data == 0) exitWith { _positions = []; };
    _routeData set [_x, _data];
    _positions pushBack (_data get "position");
} forEach _route;
if (count _positions != count _route) exitWith { createHashMap };

private _links = getArray (missionConfigFile >> "CfgWarlordSectors" >> "connections") select {
    (_x # 0) in _route && { (_x # 1) in _route }
};
private _regions = [];
{
    private _members = _x;
    private _closed = true;
    for "_i" from 0 to (count _members - 1) do {
        private _from = _members # _i;
        private _to = _members # ((_i + 1) % count _members);
        if ((_links findIf {
            ((_x # 0) == _from && { (_x # 1) == _to }) ||
            { (_x # 0) == _to && { (_x # 1) == _from } }
        }) == -1) then { _closed = false; };
    };
    if (_closed) then {
        private _points = _members apply { (_routeData get _x) get "position" };
        private _center = [0, 0, 0];
        { _center = _center vectorAdd _x; } forEach _points;
        _regions pushBack (createHashMapFromArray [
            ["members", _members],
            ["positions", _points],
            ["center", _center vectorMultiply (1 / count _points)]
        ]);
    };
} forEach [
    ["Airbase", "AirbaseCompound", "MainPower"],
    ["AirbaseCompound", "MainPower", "SouthTelos"]
];

private _route10 = ["Anthrakia", "Rodopoli", "Paros"];
private _routeData10 = createHashMap;
private _positions10 = [];
{
    private _data = _sectors getOrDefault [_x, createHashMap];
    if (count _data == 0) then { _data = [_x] call INTRO_fnc_sectorData; };
    if (count _data == 0) exitWith { _positions10 = []; };
    _routeData10 set [_x, _data];
    _positions10 pushBack (_data get "position");
} forEach _route10;
if (count _positions10 != count _route10) exitWith { createHashMap };
private _links10 = getArray (missionConfigFile >> "CfgWarlordSectors" >> "connections") select {
    (_x # 0) in _route10 && { (_x # 1) in _route10 }
};

createHashMapFromArray [
    ["route", _route],
    ["sectorData", _routeData],
    ["positions", _positions],
    ["regions", _regions],
    ["links", _links],
    ["route10", _route10],
    ["sectorData10", _routeData10],
    ["positions10", _positions10],
    ["links10", _links10],
    ["departures9", [0.25, 2.3, 4.6, 6.9]],
    ["arrivals9", [0.8, 3.1, 5.4, 7.7]],
    ["captures9", [1.5, 3.8, 6.1, 8.4]],
    ["animationDuration10", 8.5],
    ["departures10", [0.25, 2.45, 4.65]],
    ["arrivals10", [0.8, 3, 5.2]],
    ["captures10", [1.98, 4.18, 7.1]],
    ["enemyCounts10", [2, 2, 4]],
    ["kills10", [[0.3, 0.75], [0.3, 0.75], [0.3, 0.75, 1.2, 1.65]]]
]
