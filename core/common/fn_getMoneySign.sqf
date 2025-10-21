#include "includes.inc"
params ["_team"];
if (isNil "_team") exitWith {
    "$"
};

switch (_team) do {
    case WEST: {
        "$"
    };
    case EAST: {
        "¥"
    };
    case INDEPENDENT: {
        "$"
    };
    default {
        "$"
    };
};