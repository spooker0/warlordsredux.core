#include "includes.inc"
params ["_unit"];

_unit setUnconscious false;
_unit setCaptive false;
_unit setDamage 0;
[_unit, ["AidlPpneMstpSnonWnonDnon_AI"]] remoteExec ["switchMove", 0];

_unit setVariable ["WL2_alreadyHandled", false, 2];
_unit setVariable ["WL_unconsciousTime", 0];
[_unit, true] remoteExec ["setPhysicsCollisionFlag", 0];

if !(isPlayer _unit) exitWith {};

private _group = group _unit;
if (leader _group != _unit) then {
	[_group, _unit] remoteExec ["selectLeader", groupOwner _group];
};

#if __GAME_BUILD__ <= 153351
{
	_x setUnconscious false;
	_x setCaptive false;
} forEach (units _unit);
#endif