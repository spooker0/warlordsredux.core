#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _removeActionID = _asset addAction [
	"",
	{
		private _asset = _this # 0;
		[_asset] spawn WL2_fnc_removeAsset;
	},
	[],
	-98,
	false,
	true,
	"",
	"vehicle _this != _target && {getPlayerUID _this == (_target getVariable ['BIS_WL_ownerAsset', '123'])}",
	30,
	false
];

_asset setUserActionText [
	_removeActionID,
	format ["<t color='#ff4b4b'>%1</t>", localize "STR_xbox_hint_remove"],
	"<img size='2' color='#ff4b4b' image='\a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca'/>"
];