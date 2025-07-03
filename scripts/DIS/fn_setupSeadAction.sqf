#include "includes.inc"
params ["_asset"];

private _previousEligible = false;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = [_asset] call DIS_fnc_setupSeadActionEligibility;
	if (_eligible == _previousEligible) then {
		continue;
	};

	if (_eligible) then {
		private _display = uiNamespace getVariable ["RscWLTargetingMenu", objNull];
		if !(isNull _display) then {
			_display closeDisplay 0;
		};
		"targeting" cutRsc ["RscWLTargetingMenu", "PLAIN", -1, true, true];
		_display = uiNamespace getVariable "RscWLTargetingMenu";
		private _texture = _display displayCtrl 5001;
		// _texture ctrlWebBrowserAction ["OpenDevConsole"];

		[_texture] spawn {
			params ["_texture"];
			while { !isNull _texture } do {
				private _delta = 0;
				if (inputAction "gunElevDown" > 0) then {
					waitUntil {
						sleep 0.001;
						inputAction "gunElevDown" == 0
					};
					_delta = 1;
				};

				if (inputAction "gunElevUp" > 0) then {
					waitUntil {
						sleep 0.001;
						inputAction "gunElevUp" == 0
					};
					_delta = -1;
				};

				if (_delta != 0) then {
					private _seadTargetList = call DIS_fnc_getSeadList;
					private _selectedTarget = cameraOn getVariable ["WL2_selectedTarget", objNull];
					private _targetIndex = 0;
					{
						private _target = objectFromNetId (_x # 0);
						if (_target == _selectedTarget) then {
							_targetIndex = _forEachIndex;
						};
					} forEach _seadTargetList;
					private _newIndex = (_targetIndex + _delta) % (count _seadTargetList);
					private _newSelectedTargetId = _seadTargetList select _newIndex select 0;
					cameraOn setVariable ["WL2_selectedTarget", objectFromNetId _newSelectedTargetId];

					[_texture] call DIS_fnc_sendSeadData;
					playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
				};
				sleep 0.001;
			};
		};

		_texture ctrlAddEventHandler ["PageLoaded", {
			params ["_texture"];
			[_texture] spawn {
				params ["_texture"];
				while { !isNull _texture } do {
					[_texture] call DIS_fnc_sendSeadData;
					sleep 1;
				};
			};
		}];
	} else {
		"targeting" cutText ["", "PLAIN"];
	};

	_previousEligible = _eligible;
};