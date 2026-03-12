#include "includes.inc"
{
    profileNamespace setVariable [_x, createHashMap];
    player setVariable [_x, createHashMap, true];
} forEach [
    "WL2_playerReports",
    "WL2_playerTransfers",
    "WL2_afkLog"
];