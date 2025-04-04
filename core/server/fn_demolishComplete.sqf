#include "..\warlords_constants.inc"

params ["_target", "_caller", "_explosive", "_explPos"];

if !(isNull _caller) then {
    [_target, _caller] call WL2_fnc_killRewardHandle;
};
_target setVariable ["WL_lastHitter", _caller];

private _explosion = createVehicle [_explosive, _explPos, [], 0, "FLY"];
_explosion setShotParents [_caller, _caller];
sleep 0.5;
triggerAmmo _explosion;
_target setDamage [1, true, _caller, _caller];

sleep 2;
deleteVehicle _target;