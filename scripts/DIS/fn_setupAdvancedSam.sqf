#include "includes.inc"
params ["_asset"];

private _previousEligible = false;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = cameraOn == _asset;
	if (_eligible == _previousEligible) then {
		continue;
	};

	if (_eligible) then {
		private _display = uiNamespace getVariable ["RscWLSamTargetingMenu", displayNull];
		if (isNull _display) then {
			"samtarget" cutRsc ["RscWLSamTargetingMenu", "PLAIN", -1, true, true];
			_display = uiNamespace getVariable "RscWLSamTargetingMenu";
		};
		private _texture = _display displayCtrl 5502;
		// _texture ctrlWebBrowserAction ["OpenDevConsole"];

		_texture ctrlAddEventHandler ["PageLoaded", {
			params ["_texture"];
			[_texture] spawn {
				params ["_texture"];
				while { !isNull _texture } do {
					private _targetList = [DIS_fnc_getSamTarget, "NO TARGET"] call DIS_fnc_getTargetList;
					[_texture, _targetList] call DIS_fnc_sendTargetData;
					sleep 1;
				};
			};
		}];
	} else {
		"samtarget" cutText ["", "PLAIN"];
	};

	_previousEligible = _eligible;
};
"samtarget" cutText ["", "PLAIN"];