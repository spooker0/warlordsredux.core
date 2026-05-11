#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _actionConditions = {
	if (vehicle _this != _target) exitWith { false };
	if (!alive _target) exitWith { false };

    private _accessControl = [_target, _this, "full"] call WL2_fnc_accessControl;
	if (!(_accessControl # 0)) exitWith { false };

    private _altitude = (_target modelToWorld [0, 0, 0]) # 2;
    if (_altitude < 100) exitWith { false };

    true;
};

_asset addAction [
	"<t color='#00FF00'>Call for Paradrop</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
        _target removeAction _actionId;
		[player, _target] remoteExec ["WL2_fnc_conscriptVehicle", BIS_WL_playerSide];
	},
	[],
	100,
	false,
	true,
	"",
	toString _actionConditions,
	WL_MAINTENANCE_RADIUS,
	false
];