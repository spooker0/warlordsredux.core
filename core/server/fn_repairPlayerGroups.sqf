#include "includes.inc"
if (!isServer) exitWith {};

uiSleep 30;

while { !BIS_WL_missionEnd } do {
	private _playerList = serverNamespace getVariable ["playerList", createHashMap];
	{
		private _unit = _x;
		if (isNull _unit || !isPlayer _unit || !alive _unit) then { continue; };

		private _unitUid = _unit getVariable ["BIS_WL_ownerAsset", "123"];
		if (_unitUid != getPlayerUID _unit) then { continue; };

		private _expectedSide = _playerList getOrDefault [_unitUid, sideUnknown];
		if !(_expectedSide in [west, east]) then { continue; };

		private _currentSide = side group _unit;
		if (_currentSide != independent) then { continue; };

		private _repairGroup = createGroup [_expectedSide, true];
		if (isNull _repairGroup) then { continue; };

		[_unit] joinSilent _repairGroup;
	} forEach allPlayers;

	uiSleep 30;
};
