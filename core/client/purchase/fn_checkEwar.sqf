#include "includes.inc"
if (player getVariable ["WL2_canAccessEW", true]) then {
    [true, ""];
} else {
    [false, "You have been locked out of electronic warfare for a wrong attempt. Respawn to try again."];
};