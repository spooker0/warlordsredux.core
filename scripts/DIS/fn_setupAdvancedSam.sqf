#include "includes.inc"
params ["_asset"];

private _targetingMenus = uiNamespace getVariable ["DIS_samTargetingMenus", []];
private _layerName = format ["samtarget%1", count _targetingMenus];

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
	private _eligible = cameraOn == _asset;
	if (_eligible) then {
		if (_firstShow) then {
			_firstShow = false;
			private _controlParams = ["ADVANCED SAM CONTROLS", [
				["Previous", "gunElevUp"],
				["Next", "gunElevDown"]
			]];
			["AdvancedSam", _controlParams, 10] call WL2_fnc_showHint;
		};
		private _targetList = [DIS_fnc_getSamTarget, "NO TARGET", "WL2_selectedTargetAA"] call DIS_fnc_getTargetList;
		[_texture, _targetList] call DIS_fnc_sendTargetData;
	};
    _texture ctrlWebBrowserAction ["ExecJS", format ["setVisible(%1);", _eligible]];
	_texture setVariable ["DIS_inFocus", _eligible];
};

_layerName cutText ["", "PLAIN"];