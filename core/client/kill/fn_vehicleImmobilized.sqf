#include "includes.inc"
params ["_unit"];
[player, "immobilized", _unit] remoteExec ["WL2_fnc_handleClientRequest", 2];