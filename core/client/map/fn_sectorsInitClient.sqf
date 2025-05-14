#include "..\..\warlords_constants.inc"

BIS_WL_sectorLinks = [];
WL_linkSectorMarkers = createHashmap;
private _i = 0;

{
	_sector = _x;
	_sectorPos = position _sector;
	_area = _sector getVariable "objectArea";

	if (_sector in WL_BASES && ((_sector getVariable "BIS_WL_owner") == (side group player))) then {
		_sector setVariable ["BIS_WL_value", (getMissionConfigValue ["BIS_WL_baseValue", 50])];
	} else {
		_area params ["_a", "_b", "_angle", "_isRectangle"];
		_size = _a * _b * (if (_isRectangle) then {4} else {pi});
		_sector setVariable ["BIS_WL_value", round (_size / 13000)];
	};

	_mrkrArea = createMarkerLocal [format ["BIS_WL_sectorMarker_%1_area", _forEachIndex], _sectorPos];
	_mrkrArea setMarkerShapeLocal (if (_area # 3) then {"RECTANGLE"} else {"ELLIPSE"});
	_mrkrArea setMarkerDirLocal (_area # 2);
	_mrkrArea setMarkerBrushLocal "Solid";
	_mrkrArea setMarkerAlphaLocal 1;
	_mrkrArea setMarkerSizeLocal [(_area # 0), (_area # 1)];
} forEach BIS_WL_allSectors;

{
	_sector = _x;

	_owner = _sector getVariable "BIS_WL_owner";
	_revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];
	_sectorPos = position _sector;

	_mrkrArea = format ["BIS_WL_sectorMarker_%1_area", _forEachIndex];

	_mrkrMain = createMarkerLocal [format ["BIS_WL_sectorMarker_%1_main", _forEachIndex], _sectorPos];

	_sector setVariable ["BIS_WL_markers", [_mrkrMain, _mrkrArea]];

	if !(BIS_WL_playerSide in _revealedBy) then {
		if (_sector getVariable ["BIS_WL_name", "Sector"] == "Wait") then {
			_mrkrMain setMarkerTypeLocal "respawn_unknown";
			_mrkrMain setMarkerColorLocal "ColorWhite";
			_sector setVariable ["BIS_WL_revealedBy", [west, east, independent]];
		} else {
			_mrkrMain setMarkerTypeLocal "u_installation";
			_mrkrMain setMarkerColorLocal "ColorUNKNOWN";
			_mrkrArea setMarkerColorLocal "ColorOrange";
		};
	};

	[_sector] spawn WL2_fnc_sectorRevealHandle;

	_neighbors = (synchronizedObjects _sector) select {typeOf _x == "Logic"};
	_sector setVariable ["BIS_WL_pairedWith", []];
	_pairedWith = _sector getVariable "BIS_WL_pairedWith";

	{
		_neighbor = _x;
		_neighborPairedWith = +(_x getVariable ["BIS_WL_pairedWith", []]);
		if !(_sector in _neighborPairedWith) then {
			_pos1 = position _sector;
			_pos2 = position _neighbor;
			_pairedWith pushBack _neighbor;
			_center = [((_pos1 # 0) + (_pos2 # 0)) / 2, ((_pos1 # 1) + (_pos2 # 1)) / 2];
			_size = ((_pos1 distance2D _pos2) / 2) - 150;
			_dir = _pos1 getDir _pos2;
			private _linkMarker = createMarkerLocal [format ["BIS_WL_linkMrkr_%1", _i], _center];
			_linkMarker setMarkerAlphaLocal WL_CONNECTING_LINE_ALPHA_MAX;
			_linkMarker setMarkerShapeLocal "RECTANGLE";
			_linkMarker setMarkerDirLocal _dir;
			_linkMarker setMarkerSizeLocal [WL_CONNECTING_LINE_AXIS, _size];
			BIS_WL_sectorLinks pushBack _linkMarker;

			private _existingSectorMarkers = WL_linkSectorMarkers getOrDefault [hashValue _sector, []];
			_existingSectorMarkers pushBack _linkMarker;
			WL_linkSectorMarkers set [hashValue _sector, _existingSectorMarkers];

			private _existingNeighborMarkers = WL_linkSectorMarkers getOrDefault [hashValue _neighbor, []];
			_existingNeighborMarkers pushBack _linkMarker;
			WL_linkSectorMarkers set [hashValue _neighbor, _existingNeighborMarkers];

			{
				_x setVariable ["BIS_WL_linkMarkerIndex", _i];
			} forEach [_sector, _neighbor];
			_i = _i + 1;
		};
	} forEach _neighbors;

	_agentGrp = _sector getVariable "BIS_WL_agentGrp";
	_agentGrp setVariable ["BIS_WL_sector", _sector];
	_agentGrp addGroupIcon ["selector_selectable", [0, 0]];
	_agentGrp setGroupIconParams [[0,0,0,0], "", 1, FALSE];
} forEach BIS_WL_allSectors;