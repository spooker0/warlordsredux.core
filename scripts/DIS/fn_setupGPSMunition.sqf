#include "includes.inc"
params ["_asset"];

while { alive _asset && !local _asset } do {
	sleep 1;
};
if (!alive _asset) exitWith {};

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

private _targetingMenus = uiNamespace getVariable ["DIS_gpsTargetingMenus", []];
private _layerName = format ["gpstarget%1%2", systemTime # 6, count _targetingMenus];

_layerName cutRsc ["RscWLGPSTargetingMenu", "PLAIN", -1, true, true];
private _display = uiNamespace getVariable ["RscWLGPSTargetingMenu", displayNull];

_targetingMenus pushBack _display;
_targetingMenus = _targetingMenus select { !isNull _x };
uiNamespace setVariable ["DIS_gpsTargetingMenus", _targetingMenus];

private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _firstShow = true;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = call _gpsReady;
	if (_eligible) then {
		if (_firstShow) then {
			_firstShow = false;
			private _controlParams = ["GPS CONTROLS", [
				["Previous", "gunElevUp"],
				["Next", "gunElevDown"],
				["Enter coordinates", "0-9"]
			]];
			["GPS", _controlParams, 10] call WL2_fnc_showHint;
		};
		[_texture] call DIS_fnc_sendGPSData;
	};
    _texture ctrlWebBrowserAction ["ExecJS", format ["setVisible(%1);", _eligible]];
	_texture setVariable ["DIS_inFocus", _eligible];
};

_layerName cutText ["", "PLAIN"];