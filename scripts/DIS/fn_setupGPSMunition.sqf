#include "includes.inc"
params ["_asset"];

private _gpsReady = {
	if (cameraOn != _asset) exitWith {
		false;
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		false;
	};

	private _ammoConfig = _asset getVariable ["WL2_currentAmmoConfig", createHashMap];
	_ammoConfig getOrDefault ["gps", false];
};

private _previousEligible = false;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = call _gpsReady;
	if (_eligible == _previousEligible) then {
		continue;
	};

	if (_eligible) then {
		private _display = uiNamespace getVariable ["RscWLGPSTargetingMenu", displayNull];
		if (isNull _display) then {
			"gpstarget" cutRsc ["RscWLGPSTargetingMenu", "PLAIN", -1, true, true];
			_display = uiNamespace getVariable "RscWLGPSTargetingMenu";
		};
		private _texture = _display displayCtrl 5502;
		// _texture ctrlWebBrowserAction ["OpenDevConsole"];

		_texture ctrlAddEventHandler ["PageLoaded", {
			params ["_texture"];
			[_texture] spawn {
				params ["_texture"];
				while { !isNull _texture } do {
					[_texture] call DIS_fnc_sendGPSData;
					sleep 0.5;
				};
			};
		}];
	} else {
		"gpstarget" cutText ["", "PLAIN"];
	};

	_previousEligible = _eligible;
};
"gpstarget" cutText ["", "PLAIN"];