#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _catapultActionID = _asset addAction [
	localize "STR_A3_action_useCatapult",
	{
        _this params ["_asset", "_caller", "_actionId"];

        private _allUnits = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select {
            WL_ISUP(_x)
        };
        private _unitsNearby = _allUnits inAreaArray [getPosASL _asset, 100, 100, 0, false];
        private _railsNearby = _unitsNearby select {
            typeof _x == "Land_CraneRail_01_F"
        };

        private _useRail = false;
        if (count _railsNearby > 0) then {
            _useRail = true;
            _railsNearby = [_railsNearby, [], { cameraOn distance _x }, "ASCEND"] call BIS_fnc_sortBy;
            private _railCatapult = _railsNearby # 0;
            _asset setDir (getDir _railCatapult);

            private _railPos = _railCatapult modelToWorld [0, -10, 1.5];
            _asset setPosATL _railPos;
        } else {
            private _catapultPos = getPosASL _asset;
            _catapultPos set [2, _catapultPos # 2 + 0.8];
            _asset setPosASL _catapultPos;
        };
        _asset setVelocity [0, 0, 0];

        ["Launching in 5 seconds!"] call WL2_fnc_smoothText;
        playSoundUI ["AddItemOk"];

        _asset engineOn true;
        _caller actionNow ["flapsDown", _asset];
        _caller actionNow ["flapsDown", _asset];
        _caller actionNow ["flapsDown", _asset];
        _caller actionNow ["flapsDown", _asset];

        [_asset] spawn {
            params ["_asset"];
            private _startPosition = getPosASL _asset;
            private _startTime = serverTime;
            private _vectorDir = vectorDir _asset;
            private _vectorUp = vectorUp _asset;
            while { serverTime - _startTime < 5 } do {
                _asset setVelocityTransformation [
                    _startPosition, _startPosition,
                    [0, 0, 0], [0, 0, 0],
                    _vectorDir, _vectorDir,
                    _vectorUp, _vectorUp,
                    0
                ];
                uiSleep 0.0001;
            };

            private _assetConfig = configFile >> "CfgVehicles" >> typeOf _asset;
            private _stallSpeed = getNumber (_assetConfig >> "stallSpeed");
            private _maxGForce = getNumber (_assetConfig >> "maxGForce");

            private _stallFactor = 2;
            private _velocityFactor = 20;

            private _velocityLaunch = 350 min (_stallSpeed * _stallFactor);
            private _velocityIncrease = 100 min (_maxGForce * _velocityFactor);
            private _accelerationStep = 0.0001;

            _asset setAirplaneThrottle 1;
            _asset flyInHeight 500;

            private _velocity = 0;

            private _timeStart = serverTime;
            private _timeDelta = 0;

            while { speed _asset < _velocityLaunch && serverTime - _timeStart < 10 } do {
                _timeDelta = serverTime - _timeStart;
                _velocity = _velocityIncrease * _timeDelta;
                _asset setVelocityModelSpace [0, _velocity, 1];
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
	format ["Return to Base (%1%2)", WL_MONEY_SIGN, WL_COST_JETRTB],
	{
        _this params ["_asset", "_caller", "_actionId"];
        private _eligibility = [_asset] call WL2_fnc_rebaseActionEligibility;

        private _showAction = _eligibility # 0;
        if (!_showAction) exitWith {};

        private _failReason = _eligibility # 1;
        if (_failReason != "") exitWith {
            playSoundUI ["AddItemFailed"];
            [_failReason] call WL2_fnc_smoothText;
        };

        [_asset] spawn WL2_fnc_rebase;
	},
	[],
	10,
	false,
	true,
	"",
	"([_target] call WL2_fnc_rebaseActionEligibility) # 0",
    30,
	false
];

_asset setUserActionText [
    _rebaseAction,
    format ["<t color='#4bafff'>Return to Base (%1%2)</t>", WL_MONEY_SIGN, WL_COST_JETRTB],
    "<img size='2' color='#4bafff' image='\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa'/>"
];