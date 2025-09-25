#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};
private _assetTypeName = [_asset] call WL2_fnc_getAssetTypeName;

private _actionID = _asset addAction [
	format ["<t color='#4bff58'>Refuel %1</t>", _assetTypeName],
	{
        params ["_asset"];
        playSound3D ["a3\sounds_f\sfx\ui\vehicles\vehicle_refuel.wss", _asset, false, getPosASL _asset, 2, 1, 75];
        [_asset, 1] remoteExec ["setFuel", _asset];
    },
	[],
	5,
	true,
	false,
	"",
	"cursorTarget == _target && [_target, _this] call WL2_fnc_refuelActionEligibility",
	WL_MAINTENANCE_RADIUS,
	false
];