#include "includes.inc"
params ["_asset", "_crateType"];
if (isDedicated) exitWith {};

private _crateTypeDisplayText = WL_ASSET(_crateType, "name", getText (configFile >> "CfgVehicles" >> _crateType >> "displayName"));

private _crateIsConversion = WL_ASSET(_crateType, "conversion", 0) != 0;
if (_crateIsConversion) then {
    _crateTypeDisplayText = format ["Convert to %1", _crateTypeDisplayText];
} else {
    _crateTypeDisplayText = format ["Deploy %1", _crateTypeDisplayText];
};

private _deployActionId = _asset addAction [
	format ["<t color='#4b58ff'>%1</t>", _crateTypeDisplayText],
	{
		_this params ["_asset", "_caller", "_deployActionId", "_arguments"];

        private _crateType = _arguments # 0;

        [_asset, _crateType] spawn {
            params ["_asset", "_crateType"];
            if (_crateType == "") exitWith {
                playSound "AddItemFailed";
                ["Deploy Crate not available for this side!"] call WL2_fnc_smoothText;
            };

            private _distanceToVehicle = player distance2D _asset;
            private _offset = [0, _distanceToVehicle, 0];

            private _deployClass = WL_ASSET(_crateType, "spawn", _crateType);
            private _deploymentResult = [_deployClass, _crateType, _offset, 30, true, _asset] call WL2_fnc_deployment;

            if !(_deploymentResult # 0) exitWith {
                playSound "AddItemFailed";
            };

            private _position =  _deploymentResult # 1;
            private _direction = _deploymentResult # 3;
            private _nearbyEntities = [_crateType, _position, _direction, getPlayerUID player, [_asset]] call WL2_fnc_grieferCheck;

            if (count _nearbyEntities > 0) exitWith {
                private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
                [format ["Deploying too close to %1!", _nearbyObjectName]] call WL2_fnc_smoothText;
                playSound "AddItemFailed";
            };

            private _deployCrates = _asset getVariable ["WL2_deployCrates", 0];
            if (_deployCrates <= 0) exitWith {
                playSound "AddItemFailed";
                ["No deployment available!"] call WL2_fnc_smoothText;
            };
            _asset setVariable ["WL2_deployCrates", _deployCrates - 1, true];

            private _offset = _deploymentResult # 2;
			[player, "orderAsset", "vehicle", _position, _crateType, _direction, true, true] remoteExec ["WL2_fnc_handleClientRequest", 2];

            playSoundUI ["assemble_target", 1];

            private _crateIsConversion = WL_ASSET(_crateType, "conversion", 0) != 0;
            if (_crateIsConversion) then {
                deleteVehicle _asset;
            };
        };
	},
	[_crateType],
	5,
	false,
	true,
	"",
	"cursorObject == _target && alive _target && _target getVariable ['WL2_deployCrates', 0] > 0",
	15,
	false
];
