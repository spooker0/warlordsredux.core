#include "includes.inc"
params ["_asset"];

private _deployMortarAction = _asset addAction [
    "Deploy Integral Mortar",
    {
        _this spawn {
            params ["_asset", "_caller", "_actionId", "_arguments"];
            private _isDeployed = _asset getVariable ["WL2_miniMortarDeployed", false];
            if (_isDeployed) exitWith {
                ["Mortar already deployed."] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
            };
            _asset setVariable ["WL2_miniMortarDeployed", true, true];

            private _side = BIS_WL_playerSide;

            private _mortar = createVehicle ["B_Mortar_01_F", [0, 0, 0], [], 0, "NONE"];
            _mortar setVariable ["WL2_orderedClass", "B_Mortar_01_Integral_F", true];
            _mortar attachTo [_asset, [-0.75, -3, 0.8], "OtocVez", true];
            _mortar removeWeaponTurret ["mortar_82mm", [0]];
            _mortar removeAllMagazinesTurret [0];

            private _shellCountHE = _asset getVariable ["WL2_mortarShellCountHE", 0];
            _shellCountHE = _shellCountHE min 8;

            _mortar addMagazineTurret ["8Rnd_82mm_Mo_shells", [0], _shellCountHE];

            _mortar addWeaponTurret ["mortar_82mm", [0]];
            _mortar addEventHandler ["Fired", {
                params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                private _asset = attachedTo _unit;
                private _currentShells = _asset getVariable ["WL2_mortarShellCountHE", 0];
                if (_currentShells > 0) then {
                    _currentShells = _currentShells - 1;
                    _asset setVariable ["WL2_mortarShellCountHE", _currentShells, true];
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
            _unit moveInAny _mortar;
            _unit setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
            _mortar lockTurret [[0], true];

            switchCamera _mortar;
            player remoteControl _unit;

            while { true } do {
                uiSleep 0.1;

                if (!alive _mortar) then {
                    break;
                };
                if (!alive _unit) then {
                    break;
                };
                if (!alive _asset) then {
                    break;
                };
                if (!alive player || lifeState player == "INCAPACITATED") then {
                    break;
                };
                if !(player in _asset) then {
                    break;
                };
                if (focusOn != _unit) then {
                    break;
                };
            };

            _asset setVariable ["WL2_miniMortarDeployed", false, true];

            deleteVehicle _mortar;
            deleteVehicle _unit;

            switchCamera player;
            player remoteControl objNull;

            ["Mortar recovered."] call WL2_fnc_smoothText;
        };
    },
    nil,
    5,
    false,
    false,
    "",
    "cameraOn == _target && ([_target, _this, ""driver""] call WL2_fnc_accessControl) # 0",
    WL_MAINTENANCE_RADIUS,
    false
];