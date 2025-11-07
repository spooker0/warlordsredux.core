#include "includes.inc"
params ["_asset"];

_asset addAction [
    "<t color='#ff4b4b'>Claim Vehicle</t>",
	{
        _this spawn {
            params ["_asset", "_caller", "_actionId", "_arguments"];
            private _animation = "Acts_TerminalOpen";
            [player, [_animation]] remoteExec ["switchMove", 0];

            [[0, -3, 1]] call WL2_fnc_actionLockCamera;

            ["Animation", ["CLAIM", [
                ["Cancel", "Action"],
                ["", "ActionContext"],
                ["", "navigateMenu"]
            ]], WL_DURATION_CLAIM, true] spawn WL2_fnc_showHint;

			private _soundSource = createSoundSource ["WLAlarmSound", _asset modelToWorld [0, 0, 0], [], 0];

            private _startCheckingUnhold = false;
            private _timeToStop = serverTime + WL_DURATION_CLAIM;
			private _claimSuccess = false;
            while { true } do {
                if (!alive player) then {
                    break;
                };
                if (lifeState player == "INCAPACITATED") then {
                    break;
                };
				if (count ((crew _asset) select { alive _x }) > 0) then {
					break;
				};

                private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
                if (_startCheckingUnhold && _inputAction > 0) then {
                    break;
                };
                if (_inputAction == 0) then {
                    _startCheckingUnhold = true;
                };

                if (_timeToStop <= serverTime) then {
					_claimSuccess = true;
                    break;
                };

                uiSleep 0.001;
            };

            ["Animation"] spawn WL2_fnc_showHint;

			if (_claimSuccess) then {
				private _displayName = [_asset] call WL2_fnc_getAssetTypeName;
				systemChat format ["%1 has been claimed.", _displayName];
				playSound3D ["\a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", _asset, false, getPosASL _asset, 2, 1, 200];

				_asset setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
				_asset setVariable ["BIS_WL_ownerAssetSide", side group player, true];

				private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
				private _vehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
				_vehicles pushBack _asset;
				missionNamespace setVariable [_ownedVehicleVar, _vehicles, true];
			} else {
                private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
                private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
                playSoundUI ["AddItemFailed", _hitmarkerVolume * 2];
            };

            cameraOn cameraEffect ["Terminate", "BACK"];
            [player, [""]] remoteExec ["switchMove", 0];
			deleteVehicle _soundSource;
        };
	},
    [],
    -98,
    false,
    false,
    "",
    "[_target, _this] call WL2_fnc_claimEligibility",
    15,
    false,
    "",
    ""
];