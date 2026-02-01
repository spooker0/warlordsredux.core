#include "includes.inc"
params ["_freshTent"];

private _actionId = _freshTent addAction [
    "<t color='#00FF00'>Construct Field Fortification</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId", "_arguments"];
            private _animation = "Acts_TerminalOpen";
            [player, [_animation]] remoteExec ["switchMove", 0];

            private _validHitPoints = _arguments select 0;
            [[0, -3, 1]] call WL2_fnc_actionLockCamera;

            private _deployTime = 2;
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
                if (!alive player) then {
                    _constructionSuccess = false;
                    break;
                };
                if (lifeState player == "INCAPACITATED") then {
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

            if (_constructionSuccess) then {
                deleteVehicle _target;

                private _sandbags = "Land_BagFence_Long_F";
                private _offset = [0, 3, 0];

                private _deploymentResult = [_sandbags, _sandbags, _offset, 30, true] call WL2_fnc_deployment;

                if !(_deploymentResult # 0) exitWith {
                    playSound "AddItemFailed";
                };

                private _position =  _deploymentResult # 1;
                private _direction = _deploymentResult # 3;
                private _nearbyEntities = [_sandbags, _position, _direction, "dontcheckuid", []] call WL2_fnc_grieferCheck;

                if (count _nearbyEntities > 0) exitWith {
                    private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
                    [format ["Deploying too close to %1!", _nearbyObjectName]] call WL2_fnc_smoothText;
                    playSound "AddItemFailed";
                };

                private _offset = _deploymentResult # 2;
                [player, "orderAsset", "vehicle", _position, _sandbags, _direction, true, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
            } else {
                ["Construction cancelled."] call WL2_fnc_smoothText;
            };
        };
    },
    [],
    100,
    false,
    false,
    "",
    "cameraOn == player",
    5,
    false
];

private _fieldText = "<t color='#00FF00'>Construct Field Fortification</t>";
private _fieldImage = "<img size='2' color='#00FF00' image='A3\ui_f\data\map\mapcontrol\Ruin_CA.paa'/> <t size='1.5' color='#00FF00'>Construct Field Fortification</t>";
_freshTent setUserActionText [_actionId, _fieldText, _fieldImage];