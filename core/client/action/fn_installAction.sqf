#include "includes.inc"

private _installActionId = player addAction [
	"<t color='#ADD8E6'>Deploy Item</t>",
	{
        _this spawn {
            params ["_target", "_caller", "_actionId", "_arguments"];
            private _installableTarget = player getVariable ["WL2_installableTarget", objNull];
            if (isNull _installableTarget) exitWith {};

            private _installable = _installableTarget getVariable ["WL2_installable", ""];
            if (_installable == "") exitWith {
                playSound "AddItemFailed";
                ["Installation not available!"] call WL2_fnc_smoothText;
            };

            private _isConversion = WL_ASSET(_installable, "conversion", 0) != 0;

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

            private _deployClass = WL_ASSET(_installable, "spawn", _installable);

            private _offset = WL_ASSET(_installable, "offset", []);
            if (count _offset != 3) then {
                _offset = [0, 8, 0];
            };

            private _deploymentResult = [_deployClass, _installable, _offset, 30, true, true] call WL2_fnc_deployment;

            if !(_deploymentResult # 0) exitWith {
                playSound "AddItemFailed";
            };

            private _position =  _deploymentResult # 1;
            private _direction = _deploymentResult # 3;
            private _nearbyEntities = [_installable, _position, _direction, getPlayerUID player, [_installableTarget]] call WL2_fnc_grieferCheck;

            if (count _nearbyEntities > 0) exitWith {
                private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
                [format ["Deploying too close to %1!", _nearbyObjectName]] call WL2_fnc_smoothText;
                playSound "AddItemFailed";
            };

            private _installable = _installableTarget getVariable ["WL2_installable", ""];
            if (_installable == "") exitWith {
                playSound "AddItemFailed";
                ["Installation not available!"] call WL2_fnc_smoothText;
            };
            _installableTarget setVariable ["WL2_installable", "", true];

            private _singleton = WL_ASSET(_installable, "singleton", 0) > 0;
            if (_singleton) then {
                private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
                private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
                private _limitedOwnedVehicle = _ownedvehicles select {
                    WL_ASSET_TYPE(_x) == _installable
                };
                {
                    deleteVehicle _x;
                } forEach _limitedOwnedVehicle;
            };

            private _offset = _deploymentResult # 2;
			[player, "orderAsset", "vehicle", _position, _installable, _direction, true, true] remoteExec ["WL2_fnc_handleClientRequest", 2];

            playSoundUI ["assemble_target", 1];

            if (_isConversion) then {
                deleteVehicle _installableTarget;
            };
        };
	},
	[],
	5,
	false,
	true,
	"",
	"!isNull (player getVariable ['WL2_installableTarget', objNull]) && cameraOn == player",
	15,
	false
];

player setVariable ["WL2_installActionId", _installActionId];