#include "includes.inc"
params ["_unit"];

_unit setUnconscious false;
_unit setCaptive false;
_unit switchMove "AidlPpneMstpSnonWnonDnon_AI";
_unit setDamage 0.8;

_unit setVariable ["WL2_alreadyHandled", false, 2];
_unit setVariable ["WL_unconsciousTime", 0];
[_unit, true] remoteExec ["setPhysicsCollisionFlag", 0];
enableSentences true;

if !(isPlayer _unit) exitWith {};

private _group = group _unit;
if (leader _group != _unit) then {
	[_group, _unit] remoteExec ["selectLeader", groupOwner _group];
};

{
	_x setUnconscious false;
} forEach (units _unit);