#include "includes.inc"

private _cache = uiNamespace getVariable ["WLM_menuTextOverrides", []];
if (count _cache > 0) exitWith {
    _cache
};

// Override magazine names
// Format: Mag class, new mag name
private _overrideMagazineNames = createHashMapFromArray [
    ["4Rnd_Titan_long_missiles", "STR_WL_magTitanAALong"],
    ["4Rnd_Titan_long_missiles_O", "STR_WL_magTitanAALong"],
    ["1Rnd_GAA_missiles", "STR_WL_magTitanAA"],
    ["2000Rnd_762x51_Belt", "STR_WL_mag762Belt"],
    ["2000Rnd_762x51_Belt_Red", "STR_WL_mag762BeltRed"],
    ["2000Rnd_762x51_Belt_Green", "STR_WL_mag762BeltGreen"],
    ["2000Rnd_762x51_Belt_Yellow", "STR_WL_mag762BeltYellow"],
    ["2000Rnd_762x51_Belt_T_Red", "STR_WL_mag762TracerBeltRed"],
    ["2000Rnd_762x51_Belt_T_Green", "STR_WL_mag762TracerBeltGreen"],
    ["2000Rnd_762x51_Belt_T_Yellow", "STR_WL_mag762TracerBeltYellow"],
    ["1000Rnd_762x51_Belt", "STR_WL_mag762Belt"],
    ["1000Rnd_762x51_Belt_Red", "STR_WL_mag762BeltRed"],
    ["1000Rnd_762x51_Belt_Green", "STR_WL_mag762BeltGreen"],
    ["1000Rnd_762x51_Belt_Yellow", "STR_WL_mag762BeltYellow"],
    ["1000Rnd_762x51_Belt_T_Red", "STR_WL_mag762TracerBeltRed"],
    ["1000Rnd_762x51_Belt_T_Green", "STR_WL_mag762TracerBeltGreen"],
    ["1000Rnd_762x51_Belt_T_Yellow", "STR_WL_mag762TracerBeltYellow"],
    ["200Rnd_762x51_Belt", "STR_WL_mag762Belt"],
    ["200Rnd_762x51_Belt_Red", "STR_WL_mag762BeltRed"],
    ["200Rnd_762x51_Belt_Green", "STR_WL_mag762BeltGreen"],
    ["200Rnd_762x51_Belt_Yellow", "STR_WL_mag762BeltYellow"],
    ["200Rnd_762x51_Belt_T_Red", "STR_WL_mag762TracerBeltRed"],
    ["200Rnd_762x51_Belt_T_Green", "STR_WL_mag762TracerBeltGreen"],
    ["200Rnd_762x51_Belt_T_Yellow", "STR_WL_mag762TracerBeltYellow"],
    ["140Rnd_30mm_MP_shells", "STR_WL_mag30mmMPT"],
    ["140Rnd_30mm_MP_shells_Tracer_Red", "STR_WL_mag30mmMPTRed"],
    ["140Rnd_30mm_MP_shells_Tracer_Green", "STR_WL_mag30mmMPTGreen"],
    ["140Rnd_30mm_MP_shells_Tracer_Yellow", "STR_WL_mag30mmMPTYellow"],
    ["60Rnd_30mm_APFSDS_shells_Tracer_Red", "STR_WL_mag30mmAPFSDSRed"],
    ["60Rnd_30mm_APFSDS_shells_Tracer_Green", "STR_WL_mag30mmAPFSDSGreen"],
    ["60Rnd_30mm_APFSDS_shells_Tracer_Yellow", "STR_WL_mag30mmAPFSDSYellow"],
    ["60Rnd_40mm_GPR_Tracer_Red_shells", "STR_WL_mag40mmGPRRed"],
    ["60Rnd_40mm_GPR_Tracer_Green_shells", "STR_WL_mag40mmGPRGreen"],
    ["60Rnd_40mm_GPR_Tracer_Yellow_shells", "STR_WL_mag40mmGPRYellow"],
    ["40Rnd_40mm_APFSDS_Tracer_Red_shells", "STR_WL_mag40mmAPFSDSRed"],
    ["40Rnd_40mm_APFSDS_Tracer_Green_shells", "STR_WL_mag40mmAPFSDSGreen"],
    ["40Rnd_40mm_APFSDS_Tracer_Yellow_shells", "STR_WL_mag40mmAPFSDSYellow"],
    ["SmokeLauncherMag", "STR_WL_magSmokeLauncher"],
    ["SmokeLauncherMag_boat", "STR_WL_magSmokeLauncher"],
    ["60Rnd_CMFlareMagazine", "STR_WL_magCountermeasures"],
    ["120Rnd_CMFlareMagazine", "STR_WL_magCountermeasures"],
    ["240Rnd_CMFlareMagazine", "STR_WL_magCountermeasures"],
    ["60Rnd_CMFlare_Chaff_Magazine", "STR_WL_magCountermeasures"],
    ["120Rnd_CMFlare_Chaff_Magazine", "STR_WL_magCountermeasures"],
    ["168Rnd_CMFlare_Chaff_Magazine", "STR_WL_magCountermeasures"],
    ["192Rnd_CMFlare_Chaff_Magazine", "STR_WL_magCountermeasures"],
    ["240Rnd_CMFlare_Chaff_Magazine", "STR_WL_magCountermeasures"],
    ["300Rnd_CMFlare_Chaff_Magazine", "STR_WL_magCountermeasures"],
    ["1000Rnd_Gatling_30mm_Plane_CAS_01_F", "STR_WL_mag30mmGatling"],
    ["500Rnd_Cannon_30mm_Plane_CAS_02_F", "STR_WL_mag30mmGatling"],
    ["60Rnd_20mm_HE_shells", "STR_WL_mag20mmHE"],
    ["60Rnd_20mm_AP_shells", "STR_WL_mag20mmAP"],
    ["PylonRack_3Rnd_Missile_AGM_02_F", "Macer"],
    ["PylonRack_3Rnd_LG_scalpel", "Scalpel"],
    ["PylonRack_4Rnd_LG_scalpel", "Scalpel"],
    ["PylonRack_7Rnd_Rocket_04_HE_F", "STR_WL_magShriekerRunwayBuster"],
    ["PylonRack_7Rnd_Rocket_04_AP_F", "STR_WL_magShriekerAP"],
    ["PylonRack_12Rnd_PGM_missiles", "DAGR-M"],
    ["PylonRack_20Rnd_Rocket_03_HE_F", "STR_WL_magTratnyrRunwayBuster"],
    ["PylonRack_20Rnd_Rocket_03_AP_F", "STR_WL_magTratnyrAP"],
    ["PylonRack_19Rnd_Rocket_Skyfire", "Skyfire"],
    ["PylonMissile_Missile_AMRAAM_C_x1", "AMRAAM C"],
    ["PylonRack_Missile_AMRAAM_C_x1", "AMRAAM C"],
    ["PylonRack_Missile_AMRAAM_C_x2", "AMRAAM C"],
    ["PylonMissile_Missile_AMRAAM_D_x1", "AMRAAM D"],
    ["PylonRack_Missile_AMRAAM_D_x1", "AMRAAM D"],
    ["PylonMissile_Missile_AMRAAM_D_INT_x1", "AMRAAM D"],
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