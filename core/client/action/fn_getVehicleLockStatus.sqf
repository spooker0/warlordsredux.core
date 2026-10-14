#include "includes.inc"
params ["_accessControl"];

switch (_accessControl) do {
    case 2: { ["#ff0000", "Locked"]; };
    case 3: { ["#00ff00", "Unlocked"]; };
    default { ["", ""]; };
};