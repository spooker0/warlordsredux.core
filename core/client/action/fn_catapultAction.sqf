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

// if (_asset animationPhase "tailhook" == 0) exitWith {};

// [_asset] spawn {
//     params ["_asset"];
//     while { alive _asset } do {
//         if (cameraOn != _asset) then {
//             uiSleep 1;
//             continue;
//         };

//         private _tailhookDown = _asset animationPhase "tailhook" < 0.1;
//         if (!_tailhookDown) then {
//             uiSleep 1;
//             continue;
//         };

//         private _cablesNearby = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select {
//             WL_ISUP(_x)
//         } select {
//             _x distance _asset < 100
//         } select {
//             typeof _x == "Land_CraneRail_01_F"
//         };
//         if (count _cablesNearby == 0) then {
//             uiSleep 0.1;
//             continue;
//         };

//         private _cable = _cablesNearby # 0;

//         private _positionStart = [0, 0, 0];
//         private _positionEnd = [0, 0, 0];

//         private _velocityStart = 0;
//         private _vectorDirStart = [0, 0, 0];
//         private _vectorUpStart = [0, 0, 0];

//         private _startTime = 0;
//         private _duration = 2;
//         private _interval = 0;

//         _asset setAirplaneThrottle 0;
//         _asset engineOn false;

//         private _arrestCables = [];
//         private _lastDistance = 300;

//         while { alive _asset && _interval < 1 } do {
//             private _distanceToCable = _asset distance _cable;
//             if (count _arrestCables == 0) then {
//                 if (_distanceToCable < 100 && _distanceToCable > _lastDistance) then {
//                     _positionStart = getPosASL _asset;
//                     _positionEnd = _asset modelToWorld [0, 50, 0];
//                     _positionEnd set [2, 1.5];
//                     _positionEnd = AGLtoASL _positionEnd;

//                     _velocityStart = velocity _asset;
//                     _vectorDirStart = vectorDir _asset;
//                     _vectorUpStart = vectorUp _asset;

//                     _arrestCables = [
//                         ropeCreate [_asset, [0, 0, 0], _cable, [5, 5, 0], 50],
//                         ropeCreate [_asset, [0, 0, 0], _cable, [5, -5, 0], 50],
//                         ropeCreate [_asset, [0, 0, 0], _cable, [-5, 5, 0], 50],
//                         ropeCreate [_asset, [0, 0, 0], _cable, [-5, -5, 0], 50]
//                     ];
//                     _startTime = serverTime;

//                     playSoundUI ["a3\sounds_f\air\sfx\sl_4hookslock.wss"];
//                     playSoundUI ["a3\sounds_f_jets\vehicles\air\shared\fx_plane_jet_trap_wire.wss"];

//                     _asset setVelocity [0, 0, -1];
//                 };
//                 _lastDistance = _distanceToCable;
//             } else {
//                 _interval = (serverTime - _startTime) / _duration;
//                 _asset setVelocityTransformation [
//                     _positionStart, _positionEnd,
//                     _velocityStart, [0, 0, 0],
//                     _vectorDirStart, _vectorDirStart,
//                     _vectorUpStart, [0, 0, 1],
//                     _interval
//                 ];
//             };

//             uiSleep 0.01;
//         };
//         {
//             ropeDestroy _x;
//         } forEach _arrestCables;

//         _asset setAirplaneThrottle 0;
//         _asset engineOn false;

//         waitUntil {
//             uiSleep 1;
//             !alive _asset || _asset animationPhase "tailhook" > 0.1;
//         };
//     };
// };