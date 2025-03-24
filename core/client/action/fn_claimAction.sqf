#include "..\..\warlords_constants.inc"
params ["_asset"];

[
	_asset,
	"<t color = '#ff4b4b'>Claim Vehicle</t>",
	"\a3\ui_f\data\igui\cfg\HoldActions\holdAction_unbind_ca.paa",
	"\a3\ui_f\data\igui\cfg\HoldActions\holdAction_unbind_ca.paa",
	"[_target, _this] call WL2_fnc_claimEligibility",
	"[_target, _this] call WL2_fnc_claimEligibility",
	{},
	{
		params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
		// playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", _target, false, getPosASL _target, 2, 1, 200];
		if (_frame % 10 == 1) then {
			playSound3D ["\a3\sounds_f\sfx\alarmcar.wss", _target, false, getPosASL _target, 2, 1, 200];
		};
	},
	{
		_this params ["_asset", "_caller", "_actionId"];

		private _displayName = [_asset] call WL2_fnc_getAssetTypeName;
		systemChat format ["%1 has been claimed.", _displayName];
		playSound3D ["\a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", _asset, false, getPosASL _asset, 2, 1, 200];

		_asset setVariable ["BIS_WL_ownerAsset", getPlayerUID _caller, true];
		_asset setVariable ["BIS_WL_ownerAssetSide", side group _caller, true];

		private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID _caller];
		private _vehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID _caller], []];
		_vehicles pushBack _asset;
		missionNamespace setVariable [_ownedVehicleVar, _vehicles, [2, owner _caller]];
	},
	{},
	[],
	5,
	-98,
	false,
	false
] call BIS_fnc_holdActionAdd;