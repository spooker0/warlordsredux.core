#include "..\warlords_constants.inc"
params ["_targets", "_timeout"];
private _side = side group player;
{
    _side reportRemoteTarget [_x, _timeout];
} forEach _targets;