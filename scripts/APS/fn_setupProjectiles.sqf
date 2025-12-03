#include "includes.inc"

addMissionEventHandler ["ProjectileCreated", {
	params ["_projectile"];
	if !(local _projectile) exitWith {};

    private _unit = getShotParents _projectile # 0;
    if (isNil "_unit") then {
        _unit = player;
    };
    if (isNull _unit) then {
        _unit = player;
    };

    if (_projectile isKindOf "Chemlight_base") exitWith {
        [_projectile] spawn WL2_fnc_placeRespawnBag;
    };

    private _projectileType = typeOf _projectile;
    if ("#" in _projectileType) exitWith {};

    private _assetActualType = _unit getVariable ["WL2_orderedClass", typeOf _unit];
    private _projectileAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
    _projectileAmmoOverrides = _projectileAmmoOverrides select {
        _x # 0 == _projectileType
    };
    if (count _projectileAmmoOverrides > 0) then {
        private _projectileAmmoOverride = _projectileAmmoOverrides # 0;
        _projectile setVariable ["APS_ammoOverride", _projectileAmmoOverride # 1 # 0];
    };

    private _apsProjectileType = _projectile getVariable ["APS_ammoOverride", _projectileType];
    if !(_apsProjectileType in APS_projectileConfig) exitWith {};

    private _projectileConfig = APS_projectileConfig getOrDefault [_apsProjectileType, createHashMap];

    private _projectileMine = _projectileConfig getOrDefault ["mine", false];
    if (_projectileMine) then {
        private _ownedMineVar = format ["WL2_ownedMines_%1", getPlayerUID player];
        private _allOwnedMines = missionNamespace getVariable [_ownedMineVar, []];
        _allOwnedMines = _allOwnedMines select { alive _x };

        private _currentCount = count _allOwnedMines;
        if (_currentCount >= WL_MAX_MINES) then {
            private _oldestMine = _allOwnedMines # 0;
            private _oldestMineDefaultMag = getText (configFile >> "CfgAmmo" >> typeOf _oldestMine >> "defaultMagazine");
            private _oldestMineType = getText (configFile >> "CfgMagazines" >> _oldestMineDefaultMag >> "displayName");

            if (_oldestMineType == "") then {
                _oldestMineType = "Deployed Mine";
            };

            [format ["Maximum of %1 deployed explosives reached. Removing oldest: %2", WL_MAX_MINES, _oldestMineType]] call WL2_fnc_smoothText;
            deleteVehicle _oldestMine;
        };

        BIS_WL_playerSide revealMine _projectile;

        _allOwnedMines pushBack _projectile;
        _allOwnedMines = _allOwnedMines select { alive _x };
        missionNamespace setVariable [_ownedMineVar, _allOwnedMines, true];
    };

    private _projectileTV = _projectileConfig getOrDefault ["tv", false];
    if (_projectileTV) then {
        private _projectileSpeed = _projectileConfig getOrDefault ["speed", 0];
        _projectileSpeed = _projectileSpeed + (speed _unit) / 3.6;
        _projectile setVariable ["APS_speedOverride", _projectileSpeed];
        [_projectile] spawn DIS_fnc_tvMunition;
    } else {
        private _projectileMissileCamera = _projectileConfig getOrDefault ["camera", false];
        if (_projectileMissileCamera) then {
            [_projectile, _unit] call DIS_fnc_startMissileCamera;
        };
    };
    private _projectileRemote = _projectileConfig getOrDefault ["remote", false];
    private _projectileBunker = _projectileConfig getOrDefault ["bunker", 0];
    if (_projectileRemote) then {
        private _remoteController = _unit getVariable ["WL2_selectedTargetPlayer", objNull];
        if (alive _remoteController) then {
            [_projectile, _unit, _projectileBunker] remoteExec ["DIS_fnc_remoteMunition", _remoteController];
        };
    };

    private _projectileGPS = _projectileConfig getOrDefault ["gps", false];
    if (_projectileGPS) then {
        private _inRangeCalculation = [_unit] call DIS_fnc_calculateInRange;
        private _inRange = _inRangeCalculation # 0;
        if (_inRange) then {
            private _coordinates = _inRangeCalculation # 3;
            _projectile setVariable ["DIS_targetCoordinates", _coordinates];
            [_projectile, _unit] spawn DIS_fnc_gpsMunition;
        } else {
            ["GPS target out of range."] call WL2_fnc_smoothText;
        };

        private _overrideRange = _unit getVariable ["WL2_overrideRange", 0];
        if (_overrideRange > 0) then {
            if (_inRange) then {
                playSound3D ["a3\sounds_f\weapons\rockets\new_rocket_3.wss", _projectile, false, getPosASL _projectile, 5, 0.8 + random 0.4];
            } else {
                deleteVehicle _projectile;
                playSoundUI ["AddItemFailed"];
            };
        };
    };

    private _projectileESam = _projectileConfig getOrDefault ["esam", false];
    if (_projectileESam) then {
        [_projectile, _unit] spawn DIS_fnc_extendedSam;
    };

    [_projectile, _unit] spawn APS_fnc_firedProjectile;

    private _projectileAsam = _projectileConfig getOrDefault ["asam", false];
    if (_projectileAsam) then {
        [_projectile, _unit] spawn DIS_fnc_advancedSam;
    };

    if (_projectileBunker > 0) then {
        _projectile setVariable ["DIS_bunkerBusterSteps", _projectileBunker];
        _projectile addEventHandler ["Explode", {
            params ["_projectile", "_position"];
            private _bunkerBusterSteps = _projectile getVariable ["DIS_bunkerBusterSteps", 7];
            [typeOf _projectile, _position, [vectorDir _projectile, vectorUp _projectile], _bunkerBusterSteps] spawn DIS_fnc_bunkerBuster;
        }];
    };

    private _projectileSam = _projectileConfig getOrDefault ["sam", false];
    if (_projectileSam) then {
        [_projectile, _unit] spawn DIS_fnc_frag;
        [_projectile, _unit] spawn DIS_fnc_maneuver;
    };

    private _projectileSead = _projectileConfig getOrDefault ["sead", false];
    if (_projectileSead) then {
        [_projectile, _unit] spawn APS_fnc_sead;
    };

    private _projectileTerminal = _projectileConfig getOrDefault ["terminal", false];
    if (_projectileTerminal) then {
        [_projectile, _unit] spawn DIS_fnc_terminalGuidance;
    };
}];