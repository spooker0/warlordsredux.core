#include "includes.inc"
params ["_unit", "_assetActualType", "_killerEntry"];

if (_unit isKindOf "Man") exitWith {
    _killerEntry set ["kills", (_killerEntry getOrDefault ["kills", 0]) + 1];
};

if (_unit isKindOf "StaticWeapon") exitWith {
    _killerEntry set ["staticKills", (_killerEntry getOrDefault ["staticKills", 0]) + 1];
};

if (_unit isKindOf "Plane") exitWith {
    _killerEntry set ["planeKills", (_killerEntry getOrDefault ["planeKills", 0]) + 1];
};

if (_unit isKindOf "Air") exitWith {
    _killerEntry set ["heloKills", (_killerEntry getOrDefault ["heloKills", 0]) + 1];
};

private _apsLevel = WL_ASSET(_assetActualType, "aps", -1);
if (_apsLevel >= 2) exitWith {
    _killerEntry set ["heavyKills", (_killerEntry getOrDefault ["heavyKills", 0]) + 1];
};

_killerEntry set ["lightKills", (_killerEntry getOrDefault ["lightKills", 0]) + 1];