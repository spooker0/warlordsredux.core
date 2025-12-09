#include "includes.inc"
params ["_asset", "_hasAirRadar"];
if (isDedicated) exitWith {};

_asset enableVehicleSensor ["ActiveRadarSensorComponent", false];

private _actionId = _asset addAction [
	"SCANNER: INITIALIZING",
	{
        params ["_asset", "_caller", "_actionId", "_args"];
		private _hasAirRadar = _args # 0;

        private _scannerOn = _asset getVariable ["WL_scannerOn", false];
        private _newScannerOn = !_scannerOn;
        _asset setVariable ["WL_scannerOn", _newScannerOn, true];
		private _consumption = if (_asset isKindOf "LandVehicle") then {
			10;
		} else {
			if (_hasAirRadar) then {
				2;
			} else {
				20;
			};
		};
        if (_newScannerOn) then {
			[_asset, _consumption] remoteExec ["setFuelConsumptionCoef", _asset];
        } else {
			[_asset, 1] remoteExec ["setFuelConsumptionCoef", _asset];
        };
		[_asset, _actionId, _hasAirRadar, 0] call WL2_fnc_scanner;
	},
	[_hasAirRadar],
	99,
	false,
	false,
	"ActiveSensorsToggle",
	"alive _target && ([_target, player, ""driver""] call WL2_fnc_accessControl) # 0",
	30,
	false
];

[_asset, _actionId, _hasAirRadar] spawn {
	params ["_asset", "_actionId", "_hasAirRadar"];
	private _iteration = 0;
	while { alive _asset } do {
        [_asset, _actionId, _hasAirRadar, _iteration] call WL2_fnc_scanner;
		if (_hasAirRadar) then {
			uiSleep 0.5;
		} else {
			uiSleep 2;
		};
		_iteration = _iteration + 1;
	};
};