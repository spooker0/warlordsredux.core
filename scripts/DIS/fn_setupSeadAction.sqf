#include "includes.inc"
params ["_asset"];

_asset addAction [
	format ["<t color='#00ffcc'>SEAD Configuration (%1)</t>", actionKeysNames ["throw", 1, "Combo"]],
	{
		params ["_target", "_caller"];
		[_target, DIS_fnc_getSeadTarget] call DIS_fnc_setupTargetMenu;
	},
	[],
	100,
	true,
	false,
	"throw",
	"[_target, _this] call DIS_fnc_setupSeadActionEligibility",
	50,
	false
];

[_asset] spawn {
	params ["_asset"];
	while { alive _asset } do {
		sleep 1;
		if (cameraOn != _asset) then {
			continue;
		};

		private _selectedTarget = _asset getVariable ["WL2_selectedTarget", objNull];
		if (alive _selectedTarget) then {
			continue;
		};
		private _seadTargets = [_asset] call DIS_fnc_getSeadTarget;
		if (count _seadTargets == 0) then {
			continue;
		};
		private _topSeadTarget = _seadTargets # 0;
		_asset setVariable ["WL2_selectedTarget", _topSeadTarget # 0];
	};
};