#include "includes.inc"
params ["_className"];

private _config = missionConfigFile >> "CfgWarlordSectors" >> _className;
if (!isClass _config) exitWith { createHashMap };

private _position = getArray (_config >> "location");
private _area = getArray (_config >> "area");
if (count _position < 2 || count _area < 4) exitWith { createHashMap };

private _services = getArray (_config >> "services");
private _iconType = if ("A" in _services) then {
    "uav"
} else {
    if ("H" in _services) then { "air" } else { "installation" }
};

createHashMapFromArray [
    ["position", _position],
    ["area", [abs (_area # 0), abs (_area # 1), _area # 2, (_area # 3) == 1]],
    ["name", getText (_config >> "name")],
    ["iconType", _iconType]
]