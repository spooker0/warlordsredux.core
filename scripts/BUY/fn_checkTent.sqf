#include "includes.inc"

private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
if (!alive _respawnBag) then {
    [false, localize "STR_WL_tentNotDeployed"];
} else {
    [true, ""];
};
