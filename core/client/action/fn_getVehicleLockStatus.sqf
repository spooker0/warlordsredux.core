#include "includes.inc"
params ["_accessControl"];

private _color = switch (_accessControl) do {
    case 0;
    case 1;
    case 2: { "#4bff58"; };
    case 3;
    case 4;
    case 5: { "#00ffff"; };
    case 6;
    case 7: { "#ff4b4b"; };
};

private _lockLabel = switch (_accessControl) do {
    case 0: { "Access: All (Full)"; };
    case 1: { "Access: All (Operate)"; };
    case 2: { "Access: All (Passenger Only)"; };
    case 3: { "Access: Squad (Full)"; };
    case 4: { "Access: Squad (Operate)"; };
    case 5: { "Access: Squad (Passenger Only)"; };
    case 6: { "Access: Personal"; };
    case 7: { "Access: Locked"; };
    default { "Access: None"; };
};

[_color, _lockLabel];