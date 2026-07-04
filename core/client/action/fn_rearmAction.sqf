#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};
if (_asset isKindOf "Building") exitWith {};

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
	"[_target, _this] call WL2_fnc_rearmActionEligibility",
	WL_MAINTENANCE_RADIUS,
	false
];

_asset setUserActionText [
	_rearmActionId,
	format ["<t color='#4bff58'>Modify/%1</t>", localize "STR_rearm"],
	"<img size='1.5' image='a3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa'/>"
];

_asset addAction [
	"<t color='#ff0000'>Reset Vehicle</t>",
	{
		params ["_asset"];
		["You can call Reset Vehicle in the Strategy menu at any time."] call WL2_fnc_smoothText;
		0 spawn WL2_fnc_resetVehicle;
	},
	[],
	100,
	false,
	false,
	"",
	"alive _target && cameraOn != _target && _target getEntityInfo 6",
	20,
	false
];

private _assetApsType = WL_UNIT(_asset, "aps", 0);
if (_assetApsType > 0) then {
	_asset addAction [
		"<t color='#4bff58'>Reload APS</t>",
		{
			_this spawn WL2_fnc_reloadApsAction;
		},
		[],
		5,
		true,
		true,
		"",
		"cursorTarget == _target && [_target, _this] call WL2_fnc_rearmAPSEligibility",
		WL_MAINTENANCE_RADIUS,
		false
	];

	private _toggleApsText = format ["<t color='#ff0000'>Toggle APS (%1)</t>", (actionKeysNames "cycleThrownItems") regexReplace ["""", ""]];
	_asset addAction [
		_toggleApsText,
		{
			params ["_asset"];
			[_asset] call APS_fnc_toggle;
		},
		[],
		3,
		false,
		false,
		"cycleThrownItems",
		"_target == cameraOn",
		WL_MAINTENANCE_RADIUS,
		false
	];
};