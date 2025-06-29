params ["_unit", "_shellId"];
private _shellMap = _unit getVariable ["WL2_shellMap", createHashMap];
private _shell = _shellMap getOrDefault [_shellId, objNull];
if (isNull _shell) exitWith {};
triggerAmmo _shell;