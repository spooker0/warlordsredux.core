#include "includes.inc"
params ["_asset"];

private _seadReady = {
	if (cameraOn != _asset) exitWith {
		false;
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		false;
	};

	private _ammoConfig = _asset getVariable ["WL2_currentAmmoConfig", createHashMap];
	_ammoConfig getOrDefault ["sead", false];
};

private _previousEligible = false;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = call _seadReady;
	if (_eligible == _previousEligible) then {
		continue;
	};

	if (_eligible) then {
		private _display = uiNamespace getVariable ["RscWLSeadTargetingMenu", displayNull];
		if (isNull _display) then {
			"seadtarget" cutRsc ["RscWLSeadTargetingMenu", "PLAIN", -1, true, true];
			_display = uiNamespace getVariable "RscWLSeadTargetingMenu";
		};
		private _texture = _display displayCtrl 5502;
		// _texture ctrlWebBrowserAction ["OpenDevConsole"];

		private _controlParams = ["SEAD CONTROLS", [
			["Select previous", "gunElevUp"],
			["Select next", "gunElevDown"]
		]];
		["SEAD", _controlParams, 10] call WL2_fnc_showHint;

		_texture ctrlAddEventHandler ["PageLoaded", {
			params ["_texture"];
			[_texture] spawn {
				params ["_texture"];
				while { !isNull _texture } do {
					private _targetList = [DIS_fnc_getSeadTarget, "TARGET: AUTO"] call DIS_fnc_getTargetList;
					[_texture, _targetList] call DIS_fnc_sendTargetData;
					sleep 1;
				};
			};
		}];
	} else {
		"seadtarget" cutText ["", "PLAIN"];
		["SEAD"] call WL2_fnc_showHint;
	};

	_previousEligible = _eligible;
};
"seadtarget" cutText ["", "PLAIN"];
["SEAD"] call WL2_fnc_showHint;