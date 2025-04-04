[
    player,
    "<t color='#00ff00'>Stop Demolition</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "[true] call WL2_fnc_disarmEligibility",
    "[false] call WL2_fnc_disarmEligibility",
    {

        private _charge = cursorObject;
        private _target = _charge getVariable ["WL_demolishable", objNull];
        if (isNull _target) then {
            private _nearbyCharges = player nearObjects ["DemoCharge_F", 5];
            if (count _nearbyCharges > 0) then {
                _charge = _nearbyCharges # 0;
            };
        };

        uiNamespace setVariable ["WL_holdChargeObject", _charge];
        (attachedTo _charge) setVariable ["WL_holdChargeExplosion", true, true];
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
        private _charge = uiNamespace getVariable ["WL_holdChargeObject", objNull];
        playSound3D [selectRandom _disarmSounds, _charge, false, getPosASL _charge, 2, 1, 200, 0];
    },
    {
        private _charge = uiNamespace getVariable ["WL_holdChargeObject", objNull];
        private _demolishable = _charge getVariable ["WL_demolishable", objNull];
        private _charges = _charge getVariable ["WL2_children", []];
        _charges = _charges - [_demolishable];
        _charge setVariable ["WL2_children", _charges, true];
        deleteVehicle (attachedTo _charge);
        deleteVehicle _charge;
    },
    {
        private _charge = uiNamespace getVariable ["WL_holdChargeObject", objNull];
        (attachedTo _charge) setVariable ["WL_holdChargeExplosion", false, true];
    },
    [],
    5,
    100,
    false,
    false
] call BIS_fnc_holdActionAdd;