#include "includes.inc"

private _missileTypeMap = createHashMapFromArray [
    ["M_Zephyr", "ZEPHYR"],
    ["M_Titan_AA", "TITAN"],
    ["M_Titan_AA_static", "TITAN"],
    ["M_Titan_AA_long", "TITAN UP"],
    ["ammo_Missile_mim145", "DEFENDER"],
    ["ammo_Missile_s750", "RHEA"],
    ["ammo_Missile_rim116", "SPARTAN"],
    ["ammo_Missile_rim162", "CENTURION"],
    ["M_70mm_SAAMI", "SAAMI"],
    ["ammo_Missile_AA_R73", "R73"],
    ["ammo_Missile_AA_R77", "R77"],
    ["ammo_Missile_AMRAAM_C", "AMRAAM-C"],
    ["ammo_Missile_AMRAAM_D", "AMRAAM-D"],
    ["ammo_Missile_BIM9X", "BIM9X"],
    ["M_Air_AA", "ASRAAM"],
    ["Missile_AA_03_F", "SAHR"],
    ["ammo_Missile_Cruise_01", "CRUISE"],
    ["ammo_Bomb_SDB", "SDB"],
    ["ammo_Missile_HARM", "HARM"],
    ["ammo_Missile_KH58", "KH58"]
];
_missileTypeMap;