#include "includes.inc"
params ["_asset"];
if (isDedicated) exitWith {};

_asset addEventHandler ["Fired", {
    _this spawn {
        params ["_asset", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
        if !(local _asset) exitWith {};
        if (_weapon != "cannon_railgun_fake") exitWith {};

        private _existingPfHId = "bis_pfh_railgun_" + (str _asset);
        private _timeWaitStart = time;
        waitUntil {
            uiSleep 0.001;
            [_existingPfHId, "onEachFrame"] call BIS_fnc_removeStackedEventHandler ||
            time - _timeWaitStart < 5;
        };

        private _isAlreadyFiring = _asset getVariable ["WL2_railgunFiring", false];
        if (_isAlreadyFiring) exitWith {};

        _asset setVariable ["WL2_railgunFiring", true];

        private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
        private _railgunSecondClick = _settingsMap getOrDefault ["railgunSecondClick", true];

        if (_railgunSecondClick) then {
            waitUntil {
                uiSleep 0.001;
                inputAction "defaultAction" == 0;
            };
        };

        private _chargingSound = playSoundUI ["a3\sounds_f_decade\assets\arsenal\railgun_01\railgun_01_charge_start.wss"];
        [_asset, "CustomSoundController1", 0, 0.01] call BIS_fnc_setCustomSoundController;

        private _defaultRailgunDisplay = uiNamespace getVariable ["RscOptics_MBT_02_Railgun_gunner", displayNull];
        _defaultRailgunDisplay closeDisplay 0;

        private _chargeVelocity = 0;

        private _fullChargeTime = 8;
        private _timeChargeStart = time;
        private _timeChargeEnd = _timeChargeStart + _fullChargeTime;
        while { alive _asset } do {
            if (!alive _gunner) then {
                break;
            };
            if ((gunner _asset) isNotEqualTo _gunner) then {
                break;
            };

            if (isPlayer _gunner) then {
                if (_railgunSecondClick) then {
                    if (inputAction "defaultAction" != 0) then {
                        break;
                    };
                } else {
                    if (inputAction "defaultAction" == 0) then {
                        break;
                    };
                }
            } else {
                if (_chargeVelocity > 1.0) then {
                    break;
                };
            };

            _asset setUserMFDValue [0, _chargeVelocity];
            _asset setUserMFDValue [1, _chargeVelocity];
            _chargeVelocity = linearConversion [_timeChargeStart, _timeChargeEnd, time, 0, 1.2, true];

            private _soundParams = soundParams _chargingSound;
            private _soundPlayPosition = if (count _soundParams > 1) then {
                _soundParams # 1;
            } else {
                1;
            };
            if (_soundPlayPosition >= 1) then {
                stopSound _chargingSound;
                _chargingSound = playSoundUI ["a3\sounds_f_decade\assets\arsenal\railgun_01\railgun_01_charge_full_loop.wss"];
            };

            uiSleep 0.001;
        };
        stopSound _chargingSound;
        [_asset, "CustomSoundController1", 0, 0.01] call BIS_fnc_setCustomSoundController;

        _chargeVelocity = linearConversion [_timeChargeStart, _timeChargeEnd, time, 0, 1.2, true];

        if (_chargeVelocity <= 0.4) exitWith {
            playSoundUI ["a3\sounds_f_decade\assets\arsenal\railgun_01\railgun_01_charge_stop.wss"];

            _asset setWeaponReloadingTime [gunner _asset, "cannon_railgun_fake", 1];
            _asset setUserMFDValue [0, 0];
            _asset setUserMFDValue [1, 0];

            uiSleep 0.5;

            _asset setWeaponReloadingTime [gunner _asset, "cannon_railgun_fake", 0];
            _asset setUserMFDValue [0, 0];
            _asset setUserMFDValue [1, 0];
            _asset setVariable ["WL2_railgunFiring", false];
        };

        private _fakeGunner = objNull;
        if (isNull gunner _asset) then {
            _fakeGunner = createAgent ["VirtualMan_F", [0, 0, 10000], [], 0, "CAN_COLLIDE"];
            _fakeGunner moveInGunner _asset;
        };
        _asset setVariable ["BIS_MuzzleCoef", _chargeVelocity];

        [_asset, "cannon_railgun"] call BIS_fnc_fire;

        if (!isNull _fakeGunner) then {
            deleteVehicle _fakeGunner;
        };

        uiSleep 0.001;
        _asset selectWeapon "cannon_railgun_fake";

        private _ammoAmount = _asset magazineTurretAmmo ["RailGun_01_DummyMagazine", [0]];
        _ammoAmount = (_ammoAmount - 1) max 0;
        _asset setMagazineTurretAmmo ["RailGun_01_DummyMagazine", _ammoAmount, [0]];

        _asset setWeaponReloadingTime [gunner _asset, "cannon_railgun_fake", 1];
        _asset setUserMFDValue [0, 0];
        _asset setUserMFDValue [1, 0];

        private _currentDamage = _asset getHitPointDamage "HitGun";
        private _damage = if (_chargeVelocity > 1.15) then {
            0.2
        } else {
            0.03
        };
        _asset setHitPointDamage ["HitGun", _currentDamage + _damage];

        uiSleep (_chargeVelocity * 2);

        _asset setWeaponReloadingTime [gunner _asset, "cannon_railgun_fake", 0];
        _asset setUserMFDValue [0, 0];
        _asset setUserMFDValue [1, 0];
        _asset setVariable ["WL2_railgunFiring", false];
    };
}];