#include "includes.inc"
params ["_magazine"];

private _asset = uiNamespace getVariable ["WLM_asset", objNull];

private _magazineName = [_magazine] call WL2_fnc_getMagazineName;
private _magazineConfig = configFile >> "CfgMagazines" >> _magazine;

private _magAmmoType = getText (_magazineConfig >> "ammo");
private _ammoConfig = configFile >> "CfgAmmo" >> _magAmmoType;

private _magDesc = [];

_magDesc pushBack [format ["%1 | %2", _magazineName, _magazine], ""];

_magDesc pushBack ["break"];

private _magDescCount = getNumber (_magazineConfig >> "count");
if (_magDescCount != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmMagazineCount"), format ["%1", _magDescCount]];
};

if (_magAmmoType != "") then {
    _magDesc pushBack [(localize "STR_WL_wlmAmmoType"), _magAmmoType];
};

private _magDescWarheadName = getText (_ammoConfig >> "warheadName");
if (_magDescWarheadName != "") then {
    _magDesc pushBack [(localize "STR_WL_wlmWarheadType"), _magDescWarheadName];
};

private _magDescCartridge = getText (_ammoConfig >> "cartridge");
if (_magDescCartridge != "") then {
    _magDesc pushBack [(localize "STR_WL_wlmCartridge"), _magDescCartridge];
};

_magDesc pushBack ["break"];

private _magDescWeaponLockSystem = getNumber (_ammoConfig >> "weaponLockSystem");
private _isMissile = [_magDescWeaponLockSystem, 16] call BIS_fnc_bitflagsCheck;
private _isRadarGuided = [_magDescWeaponLockSystem, 8] call BIS_fnc_bitflagsCheck;
private _isLaserGuided = [_magDescWeaponLockSystem, 4] call BIS_fnc_bitflagsCheck;
private _isIRGuided = [_magDescWeaponLockSystem, 2] call BIS_fnc_bitflagsCheck;
private _isVisualGuided = [_magDescWeaponLockSystem, 1] call BIS_fnc_bitflagsCheck;
private _magDescManualControl = getNumber (_ammoConfig >> "manualControl");
private _magDescAutoSeek = getNumber (_ammoConfig >> "autoSeekTarget");

if (_isMissile) then {
    _magDesc pushBack [(localize "STR_WL_wlmMissile"), (localize "STR_WL_wlmYes")];
};

private _magDescGuidance = [];
if (_isRadarGuided) then {
    _magDescGuidance pushBack (localize "STR_WL_wlmRadar");
};
if (_isLaserGuided) then {
    _magDescGuidance pushBack (localize "STR_WL_wlmLaser");
};
if (_isIRGuided) then {
    _magDescGuidance pushBack (localize "STR_WL_wlmIR");
};
if (_isVisualGuided) then {
    _magDescGuidance pushBack (localize "STR_WL_wlmVisual");
};
if (_magDescAutoSeek != 0) then {
    _magDescGuidance pushBack (localize "STR_WL_wlmAutoSeek");
};
private _magDescMaxControlRange = 0;
if (_magDescManualControl != 0) then {
    _magDescGuidance pushBack (localize "STR_WL_wlmManualGuidance");
    _magDescMaxControlRange = getNumber (_ammoConfig >> "maxControlRange");
};
if (count _magDescGuidance > 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmSpectrum"), _magDescGuidance joinString ", "];
};

if (_magDescMaxControlRange != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmMaxControlRange"), format ["%1 m", _magDescMaxControlRange]];
};

private _magDescMissileLockMaxDistance = getNumber (_ammoConfig >> "missileLockMaxDistance");
if (_magDescMissileLockMaxDistance != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmLockMaxDistance"), format ["%1 m", _magDescMissileLockMaxDistance]];
};

private _magDescMissileLockMaxSpeed = getNumber (_ammoConfig >> "missileLockMaxSpeed");
if (_magDescMissileLockMaxSpeed != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmLockMaxSpeed"), format ["%1 m/s", _magDescMissileLockMaxSpeed]];
};

private _magDescMissileLockMinDistance = getNumber (_ammoConfig >> "missileLockMinDistance");
if (_magDescMissileLockMinDistance != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmLockMinDistance"), format ["%1 m", _magDescMissileLockMinDistance]];
};

private _magDescCmImmunity = getNumber (_ammoConfig >> "cmImmunity");
if (_magDescCmImmunity != 0 && _magDescCmImmunity != 1) then {
    _magDesc pushBack [(localize "STR_WL_wlmCountermeasureImmunity"), format ["%1%2", round (_magDescCmImmunity * 100), "%"]];
};

_magDesc pushBack ["break"];

private _magDescInitSpeed = getNumber (_magazineConfig >> "initSpeed");
if (_magDescInitSpeed != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmMuzzleVelocity"), format ["%1 m/s", _magDescInitSpeed]];
};

private _magDescMaxSpeed = getNumber (_ammoConfig >> "maxSpeed");
if (_magDescMaxSpeed != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmMaxSpeed"), format ["%1 m/s", _magDescMaxSpeed]];
};

private _magDescManeuverability = getNumber (_ammoConfig >> "maneuvrability"); // Yes, it's spelled wrong on purpose
if (_magDescManeuverability > 1) then {
    _magDesc pushBack [(localize "STR_WL_wlmManeuverability"), format ["%1", _magDescManeuverability]];
};

_magDesc pushBack ["break"];

private _magDescHit = getNumber (_ammoConfig >> "hit");
if (_magDescHit != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmDamageDirect"), format ["%1", _magDescHit]];
};

private _magDescIndirectHit = getNumber (_ammoConfig >> "indirectHit");
if (_magDescIndirectHit != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmDamageSplash"), format ["%1", _magDescIndirectHit]];
};

private _magDescIndirectHitRange = getNumber (_ammoConfig >> "indirectHitRange");
if (_magDescIndirectHitRange != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmSplashRadius"), format ["%1-%2 m", _magDescIndirectHitRange, _magDescIndirectHitRange * 4]];
};

private _magDescCaliber = getNumber (_ammoConfig >> "caliber");
private _penetrationRHA = _magDescInitSpeed * _magDescCaliber * 15 / 1000;
if (_penetrationRHA != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmPenetrationRHA"), format ["%1 mm", _penetrationRHA]];
};

_magDesc pushBack ["break"];

private _magSubmunitionAmmo = getText (_ammoConfig >> "submunitionAmmo");
if (_magSubmunitionAmmo != "") then {
    private _submunitionConfig = configFile >> "CfgAmmo" >> _magSubmunitionAmmo;

    private _submunitionHit = getNumber (_submunitionConfig >> "hit");
    if (_submunitionHit != 0) then {
        _magDesc pushBack [(localize "STR_WL_wlmSubmunitionDamageDirect"), format ["%1", _submunitionHit]];
    };

    private _submunitionIndirectHit = getNumber (_submunitionConfig >> "indirectHit");
    if (_submunitionIndirectHit != 0) then {
        _magDesc pushBack [(localize "STR_WL_wlmSubmunitionDamageSplash"), format ["%1", _submunitionIndirectHit]];
    };

    private _submunitionIndirectHitRange = getNumber (_submunitionConfig >> "indirectHitRange");
    if (_submunitionIndirectHitRange != 0) then {
        _magDesc pushBack [(localize "STR_WL_wlmSubmunitionSplashRadius"), format ["%1-%2 m", _submunitionIndirectHitRange, _submunitionIndirectHitRange * 4]];
    };

    private _submunitionCaliber = getNumber (_submunitionConfig >> "caliber");
    private _submunitionInitSpeed = getNumber (_ammoConfig >> "submunitionInitSpeed");
    private _submunitionPenetrationRHA = _submunitionInitSpeed * _submunitionCaliber * 15 / 1000;
    if (_submunitionPenetrationRHA != 0) then {
        _magDesc pushBack [(localize "STR_WL_wlmSubmunitionPenetrationRHA"), format ["%1 mm", _submunitionPenetrationRHA]];
    };

    private _submunitionAutoSeek = getNumber (_submunitionConfig >> "autoSeekTarget");
    if (_submunitionAutoSeek != 0) then {
        _magDesc pushBack [(localize "STR_WL_wlmSubmunitionAutoSeek"), (localize "STR_WL_wlmYes")];
    };

    _magDesc pushBack ["break"];
};

private _magDescTracersEvery = getNumber (_magazineConfig >> "tracersEvery");
if (_magDescTracersEvery != 0) then {
    _magDesc pushBack [(localize "STR_WL_wlmTracersEvery"), format ["%1", _magDescTracersEvery]];
};

private _assetAmmoOverrides = WL_UNIT(_asset, "ammoOverrides", []);
private _actualAmmoType = _assetAmmoOverrides select {
    _x # 0 == _magAmmoType
};
_actualAmmoType = if (count _actualAmmoType > 0) then {
    _actualAmmoType # 0 # 1 # 0;
} else {
    _magAmmoType
};

private _ammoAPSConfig = APS_projectileConfig getOrDefault [_actualAmmoType, createHashMap];
if (count _ammoAPSConfig > 0) then {
    private _magDescAPS = [];

    private _magDescAPSType = _ammoAPSConfig getOrDefault ["aps", []];
    private _typeString = _magDescAPSType apply {
        switch (_x) do {
            case 1: {localize "STR_WL_wlmLightAPS"};
            case 2: {localize "STR_WL_wlmMediumAPS"};
            case 3: {localize "STR_WL_wlmHeavyAPS"};
            case 4: {localize "STR_WL_wlmDazzler"};
            case 5: {localize "STR_WL_wlmAdvancedAPS"};
        };
    };
    if (count _magDescAPSType > 0) then {
        _typeString = _typeString joinString ", ";
        _magDescAPS pushBack [(localize "STR_WL_wlmInterceptedBy"), _typeString];
    } else {
        _magDescAPS pushBack [(localize "STR_WL_wlmInterceptedBy"), (localize "STR_WL_wlmNothing")];
    };

    private _magDescAPSConsumption = _ammoAPSConfig getOrDefault ["consumption", 1];
    if (_magDescAPSConsumption != 0) then {
        _magDescAPS pushBack [(localize "STR_WL_wlmAPSAmmoConsumption"), format ["%1", _magDescAPSConsumption]];
    };

    private _magDescAPSCamera = _ammoAPSConfig getOrDefault ["camera", false];
    if (_magDescAPSCamera) then {
        _magDescAPS pushBack [(localize "STR_WL_wlmMissileCamera"), (localize "STR_WL_wlmYes")];
    };

    private _magDescTVGuidance = _ammoAPSConfig getOrDefault ["tv", false];
    if (_magDescTVGuidance) then {
        _magDescAPS pushBack [(localize "STR_WL_wlmTVGuidance"), (localize "STR_WL_wlmYes")];
    };

    _magDesc pushBack ["break"];
    _magDesc append _magDescAPS;
};

private _magDescFinal = [];
{
    if (_x # 0 == "break") then {
        if (count _magDesc != (_forEachIndex + 1)) then {
            private _nextItem = _magDesc # (_forEachIndex + 1);
            if (_nextItem # 0 != "break") then {
                _magDescFinal pushBack _x;
            };
        };
    } else {
        _magDescFinal pushBack _x;
    }
} forEach _magDesc;

private _magazineDescription = "";
{
    if (_x # 0 == "break") then {
        _magazineDescription = _magazineDescription + "\n---";
    } else {
        private _descValue = if (_x # 1 == "") then {
            "";
        } else {
            format [": %1", _x # 1];
        };
        private _descLine = if (_forEachIndex == 0) then {
            format ["%1%2", _x # 0, _descValue];
        } else {
            format ["\n%1%2", _x # 0, _descValue];
        };
        _magazineDescription = _magazineDescription + _descLine;
    };
} forEach _magDescFinal;

_magazineDescription;