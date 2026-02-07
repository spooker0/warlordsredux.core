#include "includes.inc"
params ["_asset", "_crateType", "_isConversion"];
if (isDedicated) exitWith {};

private _crateTypeDisplayText = WL_ASSET(_crateType, "name", getText (configFile >> "CfgVehicles" >> _crateType >> "displayName"));

if (_isConversion) then {
    _crateTypeDisplayText = format ["Convert to %1", _crateTypeDisplayText];
} else {
    _crateTypeDisplayText = format ["Deploy %1", _crateTypeDisplayText];
};

private _deployActionId = _asset addAction [
	format ["<t color='#ADD8E6'>%1</t>", _crateTypeDisplayText],
	{
		_this params ["_asset", "_caller", "_deployActionId", "_arguments"];

        private _crateType = _arguments # 0;
        private _isConversion = _arguments # 1;

        [_asset, _crateType, _isConversion] spawn {
            params ["_asset", "_crateType", "_isConversion"];
            if (_crateType == "") exitWith {
                playSound "AddItemFailed";
                ["Deploy crate not available!"] call WL2_fnc_smoothText;
            };

            private _success = if (_isConversion) then {
                private _animation = "Acts_TerminalOpen";
                [player, [_animation]] remoteExec ["switchMove", 0];

                [[0, -3, 1]] call WL2_fnc_actionLockCamera;

                private _deployTime = 3;
                private _playerPosition = player modelToWorld [0, 0, 0];
                private _soundSource = createSoundSource ["WLDemolitionSound", _playerPosition, [], 0];

                ["Animation", ["CONSTRUCTION", [
                    ["Cancel", "Action"],
                    ["", "ActionContext"],
                    ["", "navigateMenu"]
                ]], _deployTime, true] spawn WL2_fnc_showHint;

                private _startCheckingUnhold = false;
                private _constructionSuccess = true;
                private _timeToDone = serverTime + _deployTime;
                while { _timeToDone > serverTime } do {
                    if (WL_ISDOWN(player)) then {
                        _constructionSuccess = false;
                        break;
                    };

                    private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
                    if (_startCheckingUnhold && _inputAction > 0) then {
                        _constructionSuccess = false;
                        break;
                    };
                    if (_inputAction == 0) then {
                        _startCheckingUnhold = true;
                    };

                    uiSleep 0.001;
                };

                ["Animation"] spawn WL2_fnc_showHint;

                cameraOn cameraEffect ["Terminate", "BACK"];
                [player, [""]] remoteExec ["switchMove", 0];

                deleteVehicle _soundSource;

                _constructionSuccess;
            } else {
                true
            };

            if (!_success) exitWith {
                ["Construction cancelled."] call WL2_fnc_smoothText;
            };

            private _deployClass = WL_ASSET(_crateType, "spawn", _crateType);

            private _offset = WL_ASSET(_crateType, "offset", []);
            if (count _offset != 3) then {
                _offset = [0, 8, 0];
            };

            private _deploymentResult = [_deployClass, _crateType, _offset, 30, true, true] call WL2_fnc_deployment;

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

            if (_isConversion) then {
                deleteVehicle _asset;
            };
        };
	},
	[_crateType, _isConversion],
	5,
	false,
	true,
	"",
	"cursorObject == _target && alive _target && _target getVariable ['WL2_deployCrates', 0] > 0",
	15,
	false
];
