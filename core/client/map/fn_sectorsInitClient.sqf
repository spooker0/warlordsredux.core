#include "includes.inc"

BIS_WL_allSectors = BIS_WL_allSectors select { !isNull _x };

{
	private _sector = _x;

	private _sectorPos = position _sector;
	private _area = _sector getVariable "WL2_objectArea";

	private _mrkrArea = createMarkerLocal [format ["BIS_WL_sectorMarker_%1_area", _forEachIndex], _sectorPos];
	_mrkrArea setMarkerShapeLocal (if (_area # 3) then {"RECTANGLE"} else {"ELLIPSE"});
	_mrkrArea setMarkerDirLocal (_area # 2);
	_mrkrArea setMarkerBrushLocal "Solid";
	_mrkrArea setMarkerAlphaLocal 1;
	_mrkrArea setMarkerSizeLocal [(_area # 0), (_area # 1)];
} forEach BIS_WL_allSectors;

private _allLinks = createHashMap;
{
	private _sector = _x;

	private _owner = _sector getVariable "BIS_WL_owner";
	private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];
	private _sectorPos = position _sector;

	private _mrkrArea = format ["BIS_WL_sectorMarker_%1_area", _forEachIndex];
	private _mrkrMain = createMarkerLocal [format ["BIS_WL_sectorMarker_%1_main", _forEachIndex], _sectorPos];

	_sector setVariable ["BIS_WL_markers", [_mrkrMain, _mrkrArea]];

	if !(BIS_WL_playerSide in _revealedBy) then {
		private _sectorName = _sector getVariable ["WL2_name", "Sector"];
		switch (_sectorName) do {
			case "Wait": {
				_mrkrMain setMarkerTypeLocal "respawn_unknown";
				_mrkrMain setMarkerColorLocal "ColorWhite";
				_sector setVariable ["BIS_WL_revealedBy", [west, east, independent]];
			};
			case "Surrender": {
				_mrkrMain setMarkerTypeLocal "KIA";
				_mrkrMain setMarkerColorLocal "ColorWhite";
				_sector setVariable ["BIS_WL_revealedBy", [west, east, independent]];
			};
			default {
				_mrkrMain setMarkerTypeLocal "u_installation";
				_mrkrMain setMarkerColorLocal "ColorUnknown";
				_mrkrArea setMarkerColorLocal "ColorUnknown";
			};
		};
	};

	[_sector] spawn WL2_fnc_sectorRevealHandle;

	private _links = _x getVariable ["WL2_connectedSectors", []];
	{
		private _link = _x;
		private _pairKey1 = hashValue _sector + hashValue _link;
		private _pairKey2 = hashValue _link + hashValue _sector;
		if ((_pairKey1 in _allLinks) || (_pairKey2 in _allLinks)) then {
			continue;
		};

		private _linkPos = getPosASL _link;
		private _direction = _sectorPos getDir _link;
		private _startPos = _sectorPos getPos [150, _direction];
		private _endPos = _link getPos [150, _direction + 180];

		_allLinks set [_pairKey1, [_startPos, _endPos, _sector, _link]];
	} forEach _links;
} forEach BIS_WL_allSectors;

missionNamespace setVariable ["WL2_linkSectorMarkers", _allLinks];