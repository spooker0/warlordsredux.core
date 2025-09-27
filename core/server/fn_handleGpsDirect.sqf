#include "includes.inc"
params ["_hitEntity", "_caller"];
_hitEntity setDamage [1, true, _caller, _caller];