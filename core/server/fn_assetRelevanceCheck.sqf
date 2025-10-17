#include "includes.inc"
params ["_assets", "_parentSector"];

if (count _assets == 0) exitWith {};

while { count _assets > 0 } do {
	private _targetedSectors = [
		missionNamespace getVariable "BIS_WL_currentTarget_west",
		missionNamespace getVariable "BIS_WL_currentTarget_east"
	] select {!isNull _x};
	private _sectorIsTargeted = _parentSector in _targetedSectors;

	private _currentOwner = _parentSector getVariable ["BIS_WL_owner", sideUnknown];
	if (_currentOwner != independent || !_sectorIsTargeted) then {
		{
			private _asset = _x;
			if (!isNull _asset) then {
				deleteVehicle _asset;
			};
		} forEach _assets;
	};

	uiSleep 30;

	_assets = _assets select {
		alive _x && _x getVariable ["BIS_WL_ownerAsset", "123"] == "123"
	};
};