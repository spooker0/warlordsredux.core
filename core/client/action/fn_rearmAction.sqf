#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};
if (_asset isKindOf "Building") exitWith {};

private _actionConditions = {
	if (vehicle _this != _this) exitWith { false };
	if (!alive _target) exitWith { false };
	private _accessControl = [_target, _this, "full"] call WL2_fnc_accessControl;
	if (!(_accessControl # 0)) exitWith { false };
	[getPosASL player, getDir player, 180, getPosASL _target] call WL2_fnc_inAngleCheck
};

private _rearmActionId = _asset addAction [
	format ["Modify/%1", localize "STR_rearm"],
	{
		params ["_asset"];
		_asset spawn WLM_fnc_initMenu;
	},
	[],
	5,
	false,
	false,
	"",
	toString _actionConditions,
	WL_MAINTENANCE_RADIUS,
	false
];

_asset setUserActionText [_rearmActionId, format ["<t color = '#4bff58'>Modify/%1</t>", localize "STR_rearm"], "<img size='1.5' image='a3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa'/>"];