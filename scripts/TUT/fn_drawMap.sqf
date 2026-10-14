#include "includes.inc"
params ["_map"];

private _display = ctrlParent _map;
private _closed = _display getVariable ["TUT_closed", true];
if (isNull _display || _closed || !(ctrlShown _map)) exitWith {};

private _definition = _display getVariable ["TUT_definition", createHashMap];
_display setVariable ["TUT_labelCount", 0];
[_map] call (_definition getOrDefault ["draw", {}]);

private _used = _display getVariable ["TUT_labelCount", 0];
{
    if (_forEachIndex >= _used) then {
        _x ctrlShow false;
    };
} forEach (_display getVariable ["TUT_labelPool", []]);
