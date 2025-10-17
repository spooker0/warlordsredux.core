#include "includes.inc"
params ["_asset"];

private _actionId = _asset addAction [
	"<t color='#00FF00'>Toggle Stabilize Boat</t>",
	{
		params ["_asset", "_caller", "_actionId"];
        private _previousState = _asset getVariable ["WL2_stabilizeBoat", false];
        _asset setVariable ["WL2_stabilizeBoat", !_previousState];
	},
	[],
	10,
	false,
	false,
	"",
	"cameraOn == _target && speed _target < 10",
	30,
	false
];

while { alive _asset } do {
    uiSleep 0.001;
    if (cameraOn != _asset) then {
        continue;
    };
    private _stabilized = _asset getVariable ["WL2_stabilizeBoat", false];
    if (_stabilized) then {
        _asset setVectorUp [0, 0, 1];
    };
};