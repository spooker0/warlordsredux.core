#include "includes.inc"
params ["_projectile"];

private _projectileType = typeOf _projectile;

waitUntil {
    uiSleep 0.5;
    !alive _projectile || (abs speed _projectile) < 0.1;
};

private _projectilePosition = getPosASL _projectile;
if (surfaceIsWater _projectilePosition && (_projectilePosition # 2) < -1) exitWith {
    deleteVehicle _projectile;
    ["Respawn tent cannot be placed under water."] call WL2_fnc_smoothText;
};

private _previousRespawnBag = player getVariable ["WL2_respawnBag", objNull];
if (!isNull _previousRespawnBag) then {
    player setVariable ["WL2_respawnBag", objNull];
    deleteVehicle _previousRespawnBag;
};

private _pos = _projectile modelToWorld [0, 0, 0];
// _pos set [2, 0];

private _tentMap = createHashMapFromArray [
    ["Chemlight_blue", "Land_TentSolar_01_bluewhite_F"],
    ["Chemlight_green", "Land_TentDome_F"],
    ["Chemlight_red", "Land_TentSolar_01_redwhite_F"],
    ["Chemlight_yellow", "Land_TentA_F"]
];
private _tentType = _tentMap getOrDefault [_projectileType, "Land_TentA_F"];

private _freshTent = createVehicle [_tentType, _pos, [], 0, "NONE"];
_freshTent setVehiclePosition [_pos, [], 0, "CAN_COLLIDE"];

player setVariable ["WL2_respawnBag", _freshTent];

_freshTent enableWeaponDisassembly false;
playSoundUI ["a3\ui_f\data\sound\cfgnotifications\communicationmenuitemadded.wss"];

[_freshTent, player] remoteExec ["WL2_fnc_setupSimpleAsset", 0, true];

private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
if (_isSquadLeader) then {
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
};

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
_ownedVehicles pushBack _freshTent;
missionNamespace setVariable [_ownedVehicleVar, _ownedVehicles, true];

deleteVehicle _projectile;