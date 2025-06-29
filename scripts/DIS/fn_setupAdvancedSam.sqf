#include "includes.inc"
params ["_asset"];

private _actionID = _asset addAction [
	"<t color='#00ffcc'>Advanced SAM Configuration</t>",
	{
		params ["_target", "_caller"];
		private _targetFunction = {
			params ["_asset"];
			((listRemoteTargets BIS_WL_playerSide) select {
				private _target = _x # 0;
				private _targetTime = _x # 1;
				private _targetSide = [_target] call WL2_fnc_getAssetSide;
				private _targetAltitude = (ASLtoAGL (getPosASL _target)) # 2;
				private _targetDistance = _target distance _asset;
				_targetTime >= -10 && _targetSide != BIS_WL_playerSide && alive _target && _targetDistance < 14000 && _targetAltitude >= 50
			}) apply { [_x # 0, [_x # 0] call WL2_fnc_getAssetTypeName] };
		};
		[_target, _targetFunction] call DIS_fnc_setupTargetMenu;
	},
	[],
	100,
	true,
	false,
	"",
	"_target == cameraOn",
	50,
	false
];