#include "includes.inc"

private _cleanUp = {
	params ["_asset"];
	if (_asset isKindOf "Air") exitWith { false };

	private _assetOwner = _asset getVariable ["BIS_WL_ownerAsset", "123"];
	if (_assetOwner != "123") exitWith { false };

	private _sector = _asset getVariable ["WL2_sectorDefender", objNull];
	if (isNull _sector) exitWith { false };
	if (_sector getVariable ["WL2_name", ""] == "") exitWith { false };

	private _sectorIsTargeted = _sector in _targetedSectors;
	if (!_sectorIsTargeted) exitWith { true };

	private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
	_sectorOwner != independent
};

while { !BIS_WL_missionEnd } do {
	uiSleep 10;

	private _targetedSectors = [
		missionNamespace getVariable ["BIS_WL_currentTarget_west", objNull],
		missionNamespace getVariable ["BIS_WL_currentTarget_east", objNull]
	] select { !isNull _x };

	{
		private _cleanUp = [_x] call _cleanUp;

		if (_cleanUp) then {
			deleteVehicle _x;
		};
	} forEach BIS_WL_ownedVehicles_server;
};