#include "includes.inc"
while { !BIS_WL_missionEnd } do {
	uiSleep 60;

	private _notBlocked = allPlayers select {
		!(_x getVariable ["WL2_afk", false])
	};

	private _westIncome = [west] call WL2_fnc_income;
	private _eastIncome = [east] call WL2_fnc_income;
	private _guerIncome = [independent] call WL2_fnc_income;

	{
		private _side = side group _x;
		private _calculatedIncome = switch (_side) do {
			case west: { _westIncome};
			case east: { _eastIncome };
			case independent: { _guerIncome };
			default { 0 };
		};

		[_calculatedIncome, getPlayerUID _x, false] call WL2_fnc_fundsDatabaseWrite;
	} forEach _notBlocked;

	private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
	_forwardBases = _forwardBases select { alive _x } select {
		_x getVariable ["WL2_forwardBaseReady", false]
	};

    {
		private _supplies = _x getVariable ["WL2_forwardBaseSupplies", 0];
		_x setVariable ["WL2_forwardBaseSupplies", _supplies + 1000, true];
    } forEach _forwardBases;

	private _facesData = missionNamespace getVariable ["WL2_sectorFaces", []];
	private _westArea = 0;
	private _eastArea = 0;
	{
		_x params ["_sectorsInFace", "_area"];
		private _ownsWestFace = true;
		private _ownsEastFace = true;
		{
			private _sector = _x;
			private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
			if (_sectorOwner != west) then {
				_ownsWestFace = false;
			};
			if (_sectorOwner != east) then {
				_ownsEastFace = false;
			};
		} forEach _sectorsInFace;
		if (_ownsWestFace) then {
			_westArea = _westArea + _area;
		};
		if (_ownsEastFace) then {
			_eastArea = _eastArea + _area;
		};
	} forEach _facesData;
	missionNamespace setVariable ["WL2_westControlledArea", _westArea, true];
	missionNamespace setVariable ["WL2_eastControlledArea", _eastArea, true];
};