#include "includes.inc"
params ["_asset"];

_asset addAction [
    "<t color='#00ff00'>Deploy Integral Weapon</t>",
    {
        _this spawn {
            params ["_asset", "_caller", "_actionId", "_arguments"];
            private _isDeployed = _asset getVariable ["WL2_isWeaponDeployed", false];
            if (_isDeployed) exitWith {
                ["Weapon already deployed."] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
            };
            _asset setVariable ["WL2_isWeaponDeployed", true, true];

            private _side = BIS_WL_playerSide;

            private _deployedWeapon = WL_UNIT(_asset, "integralWeapon", []);
            _deployedWeapon params ["_ammoCount", "_weaponOffset", "_vehicleClass", "_overrideClass", "_weaponClass", "_magazineClass", "_magazineSize"];

            private _weapon = createVehicle [_vehicleClass, [0, 0, 10], [], 0, "NONE"];
            _weapon setVariable ["WL2_orderedClass", _overrideClass, true];
            _weapon setVariable ["WL2_manualDrone", true, true];
            _weapon setVariable ["WL2_hasHMD", true];
            _weapon setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
            _weapon enableWeaponDisassembly false;

            _weapon setVehicleReceiveRemoteTargets true;
            _weapon setVehicleReportRemoteTargets true;
            _weapon setVehicleReportOwnPosition true;

            if (_asset isKindOf "B_MBT_01_cannon_F") then {
                _weapon attachTo [_asset, _weaponOffset, "OtocVez", true];
            } else {
                _weapon attachTo [_asset, _weaponOffset];
            };

            private _weaponsTurret = _weapon weaponsTurret [0];
            {
                _weapon removeWeaponTurret [_x, [0]];
            } forEach _weaponsTurret;
            _weapon removeAllMagazinesTurret [0];

            private _ammoCount = _asset getVariable ["WL2_deployedWeaponAmmo", 0];

            while { _ammoCount > _magazineSize } do {
                _weapon addMagazineTurret [_magazineClass, [0]];
                _ammoCount = _ammoCount - _magazineSize;
            };
            if (_ammoCount > 0) then {
                _weapon addMagazineTurret [_magazineClass, [0], _ammoCount];
            };

            _weapon addWeaponTurret [_weaponClass, [0]];
            _weapon addEventHandler ["Fired", {
                params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                private _asset = attachedTo _unit;
                private _currentAmmo = _asset getVariable ["WL2_deployedWeaponAmmo", 0];
                if (_currentAmmo > 0) then {
                    _currentAmmo = _currentAmmo - 1;
                    _asset setVariable ["WL2_deployedWeaponAmmo", _currentAmmo, true];
                };
            }];

            private _assetGrp = createGroup [_side, true];

            private _aiUnit = switch (_side) do {
                case west: { "B_UAV_AI" };
                case east: { "O_UAV_AI" };
                case independent: { "I_UAV_AI" };
            };

            private _unit = _assetGrp createUnit [_aiUnit, [0, 0, 0], [], 0, "NONE"];
            _unit linkItem "ItemMap";
            _unit moveInAny _weapon;
            _unit setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
            _weapon lockTurret [[0], true];

            switchCamera _weapon;
            player remoteControl _unit;

            while { true } do {
                uiSleep 0.1;

                if (!alive _weapon) then {
                    break;
                };
                if (!alive _unit) then {
                    break;
                };
                if (!alive _asset) then {
                    break;
                };
                if (WL_ISDOWN(player)) then {
                    break;
                };
                if !(player in _asset) then {
                    break;
                };
                if (focusOn != _unit) then {
                    break;
                };
            };

            _asset setVariable ["WL2_isWeaponDeployed", false, true];

            deleteVehicle _weapon;
            deleteVehicle _unit;

            switchCamera player;
            player remoteControl objNull;

            ["Weapon recovered."] call WL2_fnc_smoothText;
        };
    },
    nil,
    6,
    false,
    false,
    "",
    "cameraOn == _target && ([_target, _this, ""driver""] call WL2_fnc_accessControl) # 0",
    WL_MAINTENANCE_RADIUS,
    false
];