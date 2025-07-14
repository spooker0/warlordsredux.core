#include "includes.inc"

player setVariable ["WL2_demolishTarget", objNull];
[
    player,
    "<t color='#ff0000'>Demolish</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_forceRespawn_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_forceRespawn_ca.paa",
    "call WL2_fnc_demolishEligibility",
    "alive player && lifeState player != 'INCAPACITATED'",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        player setVariable ["WL2_demolishTarget", cursorObject];
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
        if (_frame % 2 == 1) exitWith {};
        private _impactSounds = [
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_01.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_02.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_03.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_04.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_01.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_02.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_03.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_01.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_02.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_03.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_04.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_01.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_02.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_03.wss",
            "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_04.wss"
        ];

        playSound3D [selectRandom _impactSounds, player, false, getPosASL player, 5, 1, 0];
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _targetObject = player getVariable ["WL2_demolishTarget", objNull];
        player setVariable ["WL2_demolishTarget", objNull];
        [_targetObject, 1] call WL2_fnc_demolishStep;
    },
    {
        player setVariable ["WL2_demolishTarget", objNull];
    },
    [],
    4,
    50,
    false,
    false
] call BIS_fnc_holdActionAdd;