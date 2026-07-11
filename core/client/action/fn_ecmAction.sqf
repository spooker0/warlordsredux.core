#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _ecmEligibility = {
	if (vehicle _this != _target) exitWith { false };
	if (!alive _target) exitWith { false };
    if (fuel _target == 0) exitWith { false };
    true;
};

private _ecmActionId = _asset addAction [
	"<t color='#ff4b4b'>ECM: OFF</t>",
	{
        _this params ["_asset", "_caller", "_actionId"];

        private _ecmOn = _asset getVariable ["WL2_ecmActive", false];

        if (_ecmOn) then {
            _asset setVariable ["WL2_ecmActive", false, true];
            _asset setFuelConsumptionCoef 1;
        } else {
            _asset setVariable ["WL2_ecmActive", true, true];
            _asset setVariable ["WL2_ecmStartEffectTime", serverTime + 5, true];
            _asset setFuelConsumptionCoef 50;
        };
	},
	[],
	100,
	false,
	true,
	"cycleThrownItems",
	toString _ecmEligibility,
    30,
	false
];

private _key = (actionKeysNames "cycleThrownItems") regexReplace ["""", ""];
while { alive _asset } do {
    if (cameraOn != _asset) then {
        uiSleep 5;
        continue;
    };

    private _ecmOn = _asset getVariable ["WL2_ecmActive", false];
    private _actionText = if (_ecmOn) then {
        private _ecmStartEffectTime = _asset getVariable ["WL2_ecmStartEffectTime", 0];
        if (serverTime > _ecmStartEffectTime) then {
            "ECM: ON"
        } else {
            "ECM: STARTING"
        };
    } else {
        "ECM: OFF"
    };

    _asset setUserActionText [_ecmActionId, format ["<t color='#ff4b4b'>%1 (%2)</t>", _actionText, _key]];

    uiSleep 0.5;
};