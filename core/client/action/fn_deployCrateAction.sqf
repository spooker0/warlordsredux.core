#include "..\..\warlords_constants.inc"
params ["_asset"];
if (isDedicated) exitWith {};

private _deployActionId = _asset addAction [
	"<t color='#4b58ff'>Deploy Crate</t>",
	{
		_this params ["_asset", "_caller", "_deployActionId"];

        [_asset] spawn {
            params ["_asset"];

            private _crateType = switch (BIS_WL_playerSide) do {
                case west: { "Land_Cargo10_blue_F"; };
                case east: { "Land_Cargo10_red_F"; };
                default { ""; };
            };
            if (_crateType == "") exitWith {
                playSound "AddItemFailed";
                systemChat "Deploy Crate not available for this side!";
            };

            private _distanceToVehicle = player distance2D _asset;
            private _offset = [0, _distanceToVehicle, 0];
            private _deploymentResult = [_crateType, _crateType, _offset, 30, true, _asset] call WL2_fnc_deployment;

            if !(_deploymentResult # 0) exitWith {
                playSound "AddItemFailed";
            };

            private _position =  _deploymentResult # 1;
            private _direction = _deploymentResult # 3;
            private _nearbyEntities = [typeOf _asset, _position, _direction, "dontcheckuid", [_asset]] call WL2_fnc_grieferCheck;

            if (count _nearbyEntities > 0) exitWith {
                private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
                systemChat format ["Deploying too close to %1!", _nearbyObjectName];
                playSound "AddItemFailed";
            };

            private _deployCrates = _asset getVariable ["WL2_deployCrates", 0];
            if (_deployCrates <= 0) exitWith {
                playSound "AddItemFailed";
                systemChat "No deploy crates available!";
            };
            _asset setVariable ["WL2_deployCrates", _deployCrates - 1, true];

            private _offset = _deploymentResult # 2;
			[player, "orderAsset", "vehicle", _position, _crateType, _direction, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
        };
	},
	[],
	5,
	false,
	true,
	"",
	"cursorObject == _target && alive _target && _target getVariable ['WL2_deployCrates', 0] > 0",
	15,
	false
];
