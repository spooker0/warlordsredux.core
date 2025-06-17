#include "includes.inc"

private _cache = uiNamespace getVariable ["WLM_menuTextOverrides", []];
if (count _cache > 0) exitWith {
    _cache
};

// Override magazine names
// Format: Mag class, new mag name
private _overrideMagazineNames = createHashMapFromArray [
    ["4Rnd_Titan_long_missiles", "Titan AA (Long)"],
    ["4Rnd_Titan_long_missiles_O", "Titan AA (Long)"],
    ["1Rnd_GAA_missiles", "Titan AA"],
    ["2000Rnd_762x51_Belt", "7.62x51 mm Belt"],
    ["2000Rnd_762x51_Belt_Red", "7.62x51 mm Belt Red"],
    ["2000Rnd_762x51_Belt_Green", "7.62x51 mm Belt Green"],
    ["2000Rnd_762x51_Belt_Yellow", "7.62x51 mm Belt Yellow"],
    ["2000Rnd_762x51_Belt_T_Red", "7.62x51 mm Tracer Belt Red"],
    ["2000Rnd_762x51_Belt_T_Green", "7.62x51 mm Tracer Belt Green"],
    ["2000Rnd_762x51_Belt_T_Yellow", "7.62x51 mm Tracer Belt Yellow"],
    ["1000Rnd_762x51_Belt", "7.62x51 mm Belt"],
    ["1000Rnd_762x51_Belt_Red", "7.62x51 mm Belt Red"],
    ["1000Rnd_762x51_Belt_Green", "7.62x51 mm Belt Green"],
    ["1000Rnd_762x51_Belt_Yellow", "7.62x51 mm Belt Yellow"],
    ["1000Rnd_762x51_Belt_T_Red", "7.62x51 mm Tracer Belt Red"],
    ["1000Rnd_762x51_Belt_T_Green", "7.62x51 mm Tracer Belt Green"],
    ["1000Rnd_762x51_Belt_T_Yellow", "7.62x51 mm Tracer Belt Yellow"],
    ["200Rnd_762x51_Belt", "7.62x51 mm Belt"],
    ["200Rnd_762x51_Belt_Red", "7.62x51 mm Belt Red"],
    ["200Rnd_762x51_Belt_Green", "7.62x51 mm Belt Green"],
    ["200Rnd_762x51_Belt_Yellow", "7.62x51 mm Belt Yellow"],
    ["200Rnd_762x51_Belt_T_Red", "7.62x51 mm Tracer Belt Red"],
    ["200Rnd_762x51_Belt_T_Green", "7.62x51 mm Tracer Belt Green"],
    ["200Rnd_762x51_Belt_T_Yellow", "7.62x51 mm Tracer Belt Yellow"],
    ["140Rnd_30mm_MP_shells", "30 mm MP-T"],
    ["140Rnd_30mm_MP_shells_Tracer_Red", "30 mm MP-T Red"],
    ["140Rnd_30mm_MP_shells_Tracer_Green", "30 mm MP-T Green"],
    ["140Rnd_30mm_MP_shells_Tracer_Yellow", "30 mm MP-T Yellow"],
    ["60Rnd_30mm_APFSDS_shells_Tracer_Red", "30 mm APFSDS Red"],
    ["60Rnd_30mm_APFSDS_shells_Tracer_Green", "30 mm APFSDS Green"],
    ["60Rnd_30mm_APFSDS_shells_Tracer_Yellow", "30 mm APFSDS Yellow"],
    ["60Rnd_40mm_GPR_Tracer_Red_shells", "40 mm GPR Red"],
    ["60Rnd_40mm_GPR_Tracer_Green_shells", "40 mm GPR Green"],
    ["60Rnd_40mm_GPR_Tracer_Yellow_shells", "40 mm GPR Yellow"],
    ["40Rnd_40mm_APFSDS_Tracer_Red_shells", "40 mm APFSDS Red"],
    ["40Rnd_40mm_APFSDS_Tracer_Green_shells", "40 mm APFSDS Green"],
    ["40Rnd_40mm_APFSDS_Tracer_Yellow_shells", "40 mm APFSDS Yellow"],
    ["SmokeLauncherMag", "Smoke Launcher Ammo"],
    ["SmokeLauncherMag_boat", "Smoke Launcher Ammo"],
    ["168Rnd_CMFlare_Chaff_Magazine", "Countermeasures"],
    ["240Rnd_CMFlare_Chaff_Magazine", "Countermeasures"],
    ["120Rnd_CMFlare_Chaff_Magazine", "Countermeasures"],
    ["192Rnd_CMFlare_Chaff_Magazine", "Countermeasures"],
    ["1000Rnd_Gatling_30mm_Plane_CAS_01_F", "30mm Gatling"],
    ["500Rnd_Cannon_30mm_Plane_CAS_02_F", "30mm Gatling"],
    ["60Rnd_20mm_HE_shells", "20mm HE Shells"],
    ["60Rnd_20mm_AP_shells", "20mm AP Shells"],
    ["PylonRack_3Rnd_Missile_AGM_02_F", "Macer"],
    ["PylonRack_3Rnd_LG_scalpel", "Scalpel"],
    ["PylonRack_4Rnd_LG_scalpel", "Scalpel"],
    ["PylonRack_7Rnd_Rocket_04_HE_F", "Shrieker HE"],
    ["PylonRack_7Rnd_Rocket_04_AP_F", "Shrieker AP"],
    ["PylonRack_12Rnd_PGM_missiles", "DAGR-M"],
    ["PylonRack_20Rnd_Rocket_03_HE_F", "Tratnyr HE"],
    ["PylonRack_20Rnd_Rocket_03_AP_F", "Tratnyr AP"],
    ["PylonRack_19Rnd_Rocket_Skyfire", "Skyfire"],
    ["PylonMissile_Missile_AMRAAM_C_x1", "AMRAAM C"],
    ["PylonRack_Missile_AMRAAM_C_x1", "AMRAAM C"],
    ["PylonRack_Missile_AMRAAM_C_x2", "AMRAAM C"],
    ["PylonMissile_Missile_AMRAAM_D_x1", "AMRAAM D"],
    ["PylonRack_Missile_AMRAAM_D_x1", "AMRAAM D"],
    ["PylonMissile_Missile_AMRAAM_D_INT_x1", "AMRAAM D"],
    ["PylonRack_Missile_AMRAAM_D_x1", "AMRAAM D"],
    ["PylonRack_Missile_AMRAAM_D_x2", "AMRAAM D"],
    ["PylonMissile_Missile_BIM9X_x1", "BIM 9X"],
    ["PylonRack_Missile_BIM9X_x1", "BIM 9X"],
    ["PylonRack_Missile_BIM9X_x2", "BIM 9X"],
    ["PylonMissile_Missile_AGM_02_x1", "Macer II AGM"],
    ["PylonMissile_Missile_AGM_02_x2", "Macer II AGM"],
    ["PylonRack_Missile_AGM_02_x1", "Macer II AGM"],
    ["PylonRack_Missile_AGM_02_x2", "Macer II AGM"],
    ["PylonMissile_Bomb_GBU12_x1", "GBU 12 LGB"],
    ["PylonRack_Bomb_GBU12_x2", "GBU 12 LGB"],
    ["PylonMissile_Missile_AA_R73_x1", "R73 SR"],
    ["PylonMissile_Missile_AA_R77_x1", "R77 MR"],
    ["PylonMissile_Missile_AA_R77_INT_x1", "R77 MR"],
    ["PylonMissile_Missile_AGM_KH25_x1", "KH25 AGM"],
    ["PylonMissile_Missile_AGM_KH25_INT_x1", "KH25 AGM"],
    ["PylonMissile_Bomb_KAB250_x1", "KAB 250 LGB"],
    ["PylonMissile_Missile_HARM_x1", "AGM-88C HARM"],
    ["PylonRack_Missile_HARM_x1", "AGM-88C HARM"],
    ["PylonMissile_Missile_HARM_INT_x1", "AGM-88C HARM"],
    ["PylonRack_Bomb_SDB_x4", "GBU SDB"],
    ["PylonMissile_Missile_KH58_x1", "KH58 ARM"],
    ["PylonMissile_Missile_KH58_INT_x1", "KH58 ARM"],
    ["PylonRack_Bomb_SDB_x4", "GBU SDB"]
];

// Override magazine descriptions
// Format: Mag class, new mag description
private _overrideMagazineDescriptions = createHashMapFromArray [
    ["4Rnd_Titan_long_missiles", "Short-range, infrared-guided, surface-to-air missile with high-explosive warhead."],
    ["4Rnd_Titan_long_missiles_O", "Short-range, infrared-guided, surface-to-air missile with high-explosive warhead."],
    ["1Rnd_GAA_missiles", "Short-range, infrared-guided, surface-to-air missile with high-explosive warhead."]
];

private _return = [_overrideMagazineNames, _overrideMagazineDescriptions];
uiNamespace setVariable ["WLM_menuTextOverrides", _return];
_return;