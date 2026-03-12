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
	missionNamespace setVariable ["WL2_controlledAreas", [_westArea, _eastArea], true];

	if (_westArea == 0 && _eastArea == 0) then {
		missionNamespace setVariable ["WL2_capAreaModifiers", [0, 0, 0], true];
	} else {
		_westArea = _westArea max 1;
		_eastArea = _eastArea max 1;
		private _westAreaRatio = _westArea / (_westArea + _eastArea);
		private _eastAreaRatio = 1 - _westAreaRatio;
		private _westMod = _westAreaRatio * 2;
		private _eastMod = _eastAreaRatio * 2;
		if (_westArea > _eastArea) then {
			_westMod = _westMod + 0.5;
		};
		if (_eastArea > _westArea) then {
			_eastMod = _eastMod + 0.5;
		};
		private _capAreaModifiers = [_westMod, _eastMod, 0];
		missionNamespace setVariable ["WL2_capAreaModifiers", _capAreaModifiers, true];
	};
};