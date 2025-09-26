#include "includes.inc"
params ["_asset"];

private _remoteMunitionReady = {
	if (cameraOn != _asset) exitWith {
		false;
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		false;
	};

	private _ammoConfig = _asset getVariable ["WL2_currentAmmoConfig", createHashMap];
	_ammoConfig getOrDefault ["remote", false];
};

private _targetingMenus = uiNamespace getVariable ["DIS_remoteTargetingMenus", []];
private _layerName = format ["remotetarget%1", count _targetingMenus];

_layerName cutRsc ["RscWLRemoteMunitionMenu", "PLAIN", -1, true, true];
private _display = uiNamespace getVariable ["RscWLRemoteMunitionMenu", displayNull];

_targetingMenus pushBack _display;
_targetingMenus = _targetingMenus select { !isNull _x };
uiNamespace setVariable ["DIS_remoteTargetingMenus", _targetingMenus];

private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _firstShow = true;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = call _remoteMunitionReady;
	if (_eligible) then {
		if (_firstShow) then {
			_firstShow = false;
			private _controlParams = ["REMOTE MUNITION", [
				["Previous", "gunElevUp"],
				["Next", "gunElevDown"]
			]];
			["Remote", _controlParams, 10] call WL2_fnc_showHint;
		};
		private _targetList = [] call DIS_fnc_getSquadList;
		[_texture, _targetList] call DIS_fnc_sendTargetData;
	};
    _texture ctrlWebBrowserAction ["ExecJS", format ["setVisible(%1);", _eligible]];
	_texture setVariable ["DIS_inFocus", _eligible];
};

_layerName cutText ["", "PLAIN"];