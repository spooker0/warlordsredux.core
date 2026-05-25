#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

private _actionConditions = {
	if (vehicle _this != _target) exitWith { false };
	if (!alive _target) exitWith { false };

	private _paradrops = _target getVariable ["WL2_paradrops", 0];
	if (_paradrops <= 0) exitWith { false };

    private _accessControl = [_target, _this, "full"] call WL2_fnc_accessControl;
	if (!(_accessControl # 0)) exitWith { false };

	private _position = _target modelToWorld [0, 0, 0];
    private _altitude = _position # 2;
    if (_altitude < 200) exitWith { false };
	if (surfaceIsWater _position) exitWith { false };

    true;
};

_asset addAction [
	"<t color='#00FF00'>Call for Paradrop</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		private _paradrops = _target getVariable ["WL2_paradrops", 0];
		if (_paradrops <= 0) exitWith {
			playSoundUI ["AddItemFailed"];
			["No paradrops available!"] call WL2_fnc_smoothText;
		};
        _target setVariable ["WL2_paradrops", _paradrops - 1, true];

		playSoundUI ["AddItemOk"];
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