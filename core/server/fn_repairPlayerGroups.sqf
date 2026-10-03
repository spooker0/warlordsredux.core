#include "includes.inc"
if (!isServer) exitWith {};

uiSleep 30;

while { !BIS_WL_missionEnd } do {
	private _playerList = serverNamespace getVariable ["playerList", createHashMap];
	{
		private _unit = _x;
		if (isNull _unit || !isPlayer _unit || !alive _unit) then { continue; };
		if (_unit getVariable ["WL2_playerSetupState", ""] != "Complete") then { continue; };

		private _uid = getPlayerUID _unit;
		if (_uid == "") then { continue; };

		private _expectedSide = _playerList getOrDefault [_uid, sideUnknown];
		if !(_expectedSide in [west, east]) then { continue; };

		private _currentSide = side group _unit;
		if (_currentSide != independent) then { continue; };

		private _repairGroup = createGroup [_expectedSide, true];
		if (isNull _repairGroup) then { continue; };

		[_unit] joinSilent _repairGroup;
	} forEach allPlayers;

	uiSleep 30;
};
