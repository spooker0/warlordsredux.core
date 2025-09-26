#include "includes.inc"
params ["_asset"];

while { alive _asset && !local _asset } do {
	sleep 1;
};
if (!alive _asset) exitWith {};

_asset setVariable ["DIS_advancedSamRange", 30000];

private _bvrReady = {
	if (cameraOn != _asset) exitWith {
		false;
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		false;
	};

	private _ammoConfig = _asset getVariable ["WL2_currentAmmoConfig", createHashMap];
	_ammoConfig getOrDefault ["loal", false];
};

private _targetingMenus = uiNamespace getVariable ["DIS_samTargetingMenus", []];
private _layerName = format ["samtarget%1%2", systemTime # 6, count _targetingMenus];

_layerName cutRsc ["RscWLSamTargetingMenu", "PLAIN", -1, true, true];
private _display = uiNamespace getVariable ["RscWLSamTargetingMenu", displayNull];

_targetingMenus pushBack _display;
_targetingMenus = _targetingMenus select { !isNull _x };
uiNamespace setVariable ["DIS_samTargetingMenus", _targetingMenus];

private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _firstShow = true;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = call _bvrReady;
	if (_eligible) then {
		if (_firstShow) then {
			_firstShow = false;
			private _controlParams = ["LOAL CONTROLS", [
				["Previous", "gunElevUp"],
				["Next", "gunElevDown"]
			]];
			["Loal", _controlParams, 10] call WL2_fnc_showHint;
		};	
		private _targetList = [DIS_fnc_getSamTarget, "NO TARGET", "WL2_selectedTargetAA"] call DIS_fnc_getTargetList;
		[_texture, _targetList] call DIS_fnc_sendTargetData;
	};
    _texture ctrlWebBrowserAction ["ExecJS", format ["setVisible(%1);", _eligible]];
	_texture setVariable ["DIS_inFocus", _eligible];
};

_layerName cutText ["", "PLAIN"];