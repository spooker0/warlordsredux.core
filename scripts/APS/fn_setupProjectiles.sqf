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

    private _projectileAmmoOverrides = WL_UNIT(_unit, "ammoOverrides", []);
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
    if (_projectileMine && !isDedicated) then {
        private _isExplosive = _projectileConfig getOrDefault ["explosive", false];
        [_projectile, _isExplosive] spawn APS_fnc_limitMines;

        if (_isExplosive) then {
            _projectile addEventHandler ["HitExplosion", {
                params ["_projectile", "_hitEntity", "_projectileOwner", "_hitSelections", "_instigator"];
                private _hitEntityLock = _hitEntity getVariable ["WL2_doorsLocked", sideUnknown];
                if (_hitEntityLock == sideUnknown) exitWith {};
                _hitEntity setVariable ["WL2_doorsDamaged", serverTime + 30, true];
            }];
        };
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

    private _projectileRunway = _projectileConfig getOrDefault ["runway", 0];
    if (_projectileRunway > 0) then {
        _projectile setVariable ["WL2_runwayBuster", _projectileRunway];
        _projectile addEventHandler ["Explode", {
            params ["_projectile", "_position", "_velocity"];
            private _runwayBusterMunitions = _projectile getVariable ["WL2_runwayBuster", 0];
            [_position, _runwayBusterMunitions] spawn WL2_fnc_runwayBuster;
        }];
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

    private _projectileLaser = _projectileConfig getOrDefault ["laser", false];
    if (_projectileLaser) then {
        [_projectile, _unit] spawn DIS_fnc_laserMunition;
    };

    private _projectileESam = _projectileConfig getOrDefault ["esam", false];
    if (_projectileESam) then {
        [_projectile, _unit] spawn DIS_fnc_extendedSam;
    };

    [_projectile, _unit] spawn APS_fnc_apsHandler;

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

    private _projectileSam = _projectileConfig getOrDefault ["sam", 0];
    if (_projectileSam > 0) then {
        [_projectile, _unit, _projectileSam] spawn DIS_fnc_frag;
        [_projectile, _unit] spawn DIS_fnc_maneuver;
    };

    private _projectileManualSam = _projectileConfig getOrDefault ["manualSam", []];
    if (_projectileManualSam isNotEqualTo []) then {
        _projectileManualSam params ["_manSamSpeed", "_manSamLead", "_manSamMaxRange", "_manSamProxRange", "_manSamDamage"];
        [_projectile, _unit, _manSamDamage, _manSamProxRange] spawn DIS_fnc_frag;
        [_projectile, _unit, _projectileManualSam] spawn DIS_fnc_manualSam;
    };

    private _projectileSead = _projectileConfig getOrDefault ["sead", false];
    if (_projectileSead) then {
        [_projectile, _unit] spawn APS_fnc_sead;
    };

    // private _projectileTerminal = _projectileConfig getOrDefault ["terminal", false];
    // if (_projectileTerminal) then {
    //     [_projectile, _unit] spawn DIS_fnc_terminalGuidance;
    // };

    private _projectileIncendiary = _projectileConfig getOrDefault ["incendiary", false];
    if (_projectileIncendiary) then {
        [_projectile] spawn WL2_fnc_incendiary;
    };

    private _projectileMineLayer = _projectileConfig getOrDefault ["mineLayer", ""];
    if (_projectileMineLayer != "") then {
        [_projectile, _unit, _projectileMineLayer] spawn DIS_fnc_mineLayer;
    };

    // Shells and global munitions below this point
    private _unitOwner = _unit getVariable ["BIS_WL_ownerAsset", "123"];
    if (_unitOwner == "123" || _unitOwner != getPlayerUID player) exitWith {};

    private _projectileDroneDeployer = _projectileConfig getOrDefault ["deployDrone", false];
    if (_projectileDroneDeployer) then {
        [_projectile, _unit] spawn DIS_fnc_droneDeployer;
    };

    private _projectileShell = _projectileConfig getOrDefault ["shell", ""];
    if (_projectileShell != "") then {
        _projectile setVariable ["APS_subShell", _projectileShell];
        _projectile addEventHandler ["HitPart", {
            params ["_projectile", "_hitEntity", "_projectileOwner", "_hitPos"];
            private _subShell = _projectile getVariable ["APS_subShell", ""];
            [_subShell, _hitPos, [vectorDir _projectile, vectorUp _projectile], 0] spawn DIS_fnc_bunkerBuster;
            _projectile removeEventHandler ["HitPart", _thisEventHandler];
        }];
    };
}];