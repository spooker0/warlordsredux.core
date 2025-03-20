[
    player,
    "<t color='#00ff00'>Stop Demolition</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "speed player < 1 && !isNull (cursorObject getVariable [""WL_demolishable"", objNull])",
    "speed player < 1 && !isNull (cursorObject getVariable [""WL_demolishable"", objNull])",
    {
        (attachedTo cursorObject) setVariable ["WL_holdChargeExplosion", true, true];
    },
    {
        private _disarmSounds = [
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
        playSound3D [selectRandom _disarmSounds, cursorObject, false, getPosASL cursorObject, 2, 1, 200, 0];
    },
    {
        private _demolishable = cursorObject getVariable ["WL_demolishable", objNull];
        private _charges = cursorObject getVariable ["WL2_children", []];
        _charges = _charges - [_demolishable];
        cursorObject setVariable ["WL2_children", _charges, true];
        deleteVehicle (attachedTo cursorObject);
        deleteVehicle cursorObject;
    },
    {
        (attachedTo cursorObject) setVariable ["WL_holdChargeExplosion", false, true];
    },
    [],
    10,
    100,
    false,
    false
] call BIS_fnc_holdActionAdd;