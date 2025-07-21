#include "includes.inc"
private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
if (!alive _respawnBag) then {
    [false, "No respawn tents deployed. Use chemlights to deploy a new tent."];
} else {
    [true, ""];
};