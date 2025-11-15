#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _catapultActionID = _asset addAction [
	localize "STR_A3_action_useCatapult",
	{
        _this params ["_asset", "_caller", "_actionId"];

        ["Launching in 5 seconds!"] call WL2_fnc_smoothText;
        playSoundUI ["AddItemOk"];

        _asset engineOn true;
        _caller actionNow ["flapsDown", _asset];
        _caller actionNow ["flapsDown", _asset];
        _caller actionNow ["flapsDown", _asset];
        _caller actionNow ["flapsDown", _asset];

        [_asset] spawn {
            params ["_asset"];
            uiSleep 5;

            private _assetConfig = configFile >> "CfgVehicles" >> typeOf _asset;
            private _stallSpeed = getNumber(_assetConfig >> "stallSpeed");
            private _maxGForce = getNumber(_assetConfig >> "maxGForce");

            private _velocityLaunch = 350 min (_stallSpeed * 1.2);
            private _velocityIncrease = 100 min (_maxGForce * 8);
            private _accelerationStep = 0.0001;
            private _direction = getDir _asset;

            _asset setAirplaneThrottle 1;
            _asset flyInHeight 500;

            private _velocity = 0;

            private _timeStart = serverTime;
            private _timeDelta = 0;

            while { speed _asset < _velocityLaunch } do {
                _timeDelta = serverTime - _timeStart;
                _velocity = _velocityIncrease * _timeDelta;
                _asset setVelocity [sin _direction * _velocity, cos _direction * _velocity, velocity _asset select 2];
                uiSleep _accelerationStep;
            };
        };
	},
	[],
	10,
	false,
	true,
	"",
	"[_target] call WL2_fnc_catapultActionEligibility",
    30,
	false
];

_asset setUserActionText [
    _catapultActionID,
    format ["<t color='#ff4b4b'>%1</t>", localize "STR_A3_action_useCatapult"],
    "<img size='2' color='#ff4b4b' image='\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa'/>"
];

private _rebaseAction = _asset addAction [
	format ["Return to Base (%1%2)", WL_MoneySign, WL_COST_JETRTB],
	{
        _this params ["_asset", "_caller", "_actionId"];
        [_asset] spawn {
            params ["_asset"];
            private _airfieldSectors = (BIS_WL_sectorsArray # 2) select {
                private _services = _x getVariable ["WL2_services", []];
                "A" in _services;
            };

            if (count _airfieldSectors == 0) exitWith {
                ["No friendly airfields available!"] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
            };

            private _airfieldsByDistance = [_airfieldSectors, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
            private _closestAirfield = _airfieldsByDistance # 0;
            private _sectorName = _closestAirfield getVariable ["WL2_name", "sector"];
            private _message = format ["Are you sure you want to return to %1 for %2%3?<br/>Make sure your landing gear is functional!", _sectorName, WL_MoneySign, WL_COST_JETRTB];
            private _result = [_message, "Return to Nearest Airfield", "Rebase", "Cancel"] call BIS_fnc_guiMessage;

            if (!_result) exitWith {
                playSoundUI ["AddItemFailed"];
            };

            private _spawnParams = [_closestAirfield] call WL2_fnc_getAirSectorSpawn;
            _spawnParams params ["_spawnPos", "_dir"];
            if (count _spawnPos == 0) exitWith {
                ["No valid spawn position found at airfield!"] call WL2_fnc_smoothText;
                playSoundUI ["AddItemFailed"];
            };

            player action ["LandGear", _asset];

            titleCut ["", "BLACK OUT", 1];

            uiSleep 1;

            private _startWaitTime = serverTime;
            ["Returning to base..."] call WL2_fnc_smoothText;
            while { (serverTime - _startWaitTime) < 5 } do {
                _asset setAirplaneThrottle 0;
                _asset engineOn false;
                _asset setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
                _asset setVelocity [0, 0, 0];
                uiSleep 0.1;
            };

            _asset setVehiclePosition [_spawnPos, [], 0, "CAN_COLLIDE"];
            _asset setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
            _asset setDir _dir;
            _asset setVelocity [0, 0, 0];

            [player, "jetRTB"] remoteExec ["WL2_fnc_handleClientRequest", 2];

            titleCut ["", "BLACK IN", 1];
        };
	},
	[],
	10,
	false,
	true,
	"",
	"[_target] call WL2_fnc_rebaseActionEligibility",
    30,
	false
];

_asset setUserActionText [
    _rebaseAction,
    format ["<t color='#4bafff'>Return to Base (%1%2)</t>", WL_MoneySign, WL_COST_JETRTB],
    "<img size='2' color='#4bafff' image='\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa'/>"
];