#include "includes.inc"
params ["_unit", "_responsibleLeader"];

private _alreadyPunished = _unit getVariable ["WL2_alreadyPunished", false];
if (_alreadyPunished) exitWith {};
_unit setVariable ["WL2_alreadyPunished", true];

private _victimUid = _unit getVariable ["BIS_WL_ownerAsset", "123"];
private _victim = [_victimUid] call BIS_fnc_getUnitByUid;
private _owner = owner _victim;

#if WL_TEST_SERVER == 0
if (_owner <= 2) exitWith {};
if (_victimUid == "123" || _victimUid == getPlayerUID _responsibleLeader) exitWith {};
#endif

if (WL_UNIT(_unit, "obstacle", 0) > 0) exitWith {};

private _responsibleLeaderSide = side group _responsibleLeader;
private _unitSide = [_unit] call WL2_fnc_getAssetSide;
if (_responsibleLeaderSide != _unitSide) exitWith {};

if (_unit isKindOf "Man") then {
	if (isPlayer _unit) then {
		[_responsibleLeader, name _responsibleLeader, 100] remoteExec ["WL2_fnc_askForgiveness", _owner];
	} else {
		private _assetName = format ["%1's AI", name _responsibleLeader];
		[_responsibleLeader, _assetName, 100] remoteExec ["WL2_fnc_askForgiveness", _owner];
	};
} else {
	private _assetType = [_unit] call WL2_fnc_getAssetTypeName;
	private _itemCost = WL_UNIT(_unit, "cost", 100);
	private _assetTypeName = format ["%1's %2", name _responsibleLeader, _assetType];
	[_responsibleLeader, _assetTypeName, _itemCost] remoteExec ["WL2_fnc_askForgiveness", _owner];
};