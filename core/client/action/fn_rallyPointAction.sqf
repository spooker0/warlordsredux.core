#include "includes.inc"
params ["_freshTent"];

private _actionId = _freshTent addAction [
    "<t color='#00FF00'>Construct Rally Point</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId", "_arguments"];
            private _animation = "Acts_TerminalOpen";
            [player, [_animation]] remoteExec ["switchMove", 0];

            private _validHitPoints = _arguments select 0;
            [[0, -3, 1]] call WL2_fnc_actionLockCamera;

            private _deployTime = 10;
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

            if (_constructionSuccess) then {
                [_target] call WL2_fnc_constructRallyPoint;
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

private _rallyText = "<t color='#00FF00'>Construct Rally Point</t>";
private _rallyImage = "<img size='2' color='#00FF00' image='A3\ui_f\data\map\mapcontrol\Ruin_CA.paa'/> <t size='1.5' color='#00FF00'>Construct Rally Point</t>";
_freshTent setUserActionText [_actionId, _rallyText, _rallyImage];