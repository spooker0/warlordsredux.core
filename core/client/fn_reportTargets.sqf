#include "..\warlords_constants.inc"
params ["_targets", "_timeout"];
{
    BIS_WL_playerSide reportRemoteTarget [_x, _timeout];
} forEach _targets;