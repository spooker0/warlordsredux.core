#include "includes.inc"

while { !BIS_WL_missionEnd } do {
	uiSleep 30;

	private _targetedSectors = [
		missionNamespace getVariable ["BIS_WL_currentTarget_west", objNull],
		missionNamespace getVariable ["BIS_WL_currentTarget_east", objNull]
	] select {!isNull _x};

	{
		private _sector = _x;

		private _sectorIsTargeted = _sector in _targetedSectors;

		private _sectorDefenders = _sector getVariable ["WL2_sectorDefenders", []];

		private _currentOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
		if (_currentOwner != independent || !_sectorIsTargeted) then {
			{
				private _asset = _x;
				if (!isNull _asset) then {
					deleteVehicle _asset;
				};
			} forEach _sectorDefenders;
		};

		{
			if (_x isKindOf "Man" && vehicle _x == _x) then {
				if (isTouchingGround _x) then {
					continue;
				};
				deleteVehicle _x;
			};
		} forEach _sectorDefenders;

		_sectorDefenders = _sectorDefenders select {
			alive _x && _x getVariable ["BIS_WL_ownerAsset", "123"] == "123"
		};
	} forEach BIS_WL_allSectors;
};