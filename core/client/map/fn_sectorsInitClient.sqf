#include "includes.inc"

BIS_WL_allSectors = BIS_WL_allSectors select { !isNull _x };

private _allLinks = createHashMap;
{
	private _sector = _x;

	private _owner = _sector getVariable "BIS_WL_owner";
	private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];

	private _area = _sector getVariable "objectAreaComplete";
	_area params ["_sectorPos", "_axisA", "_axisB", "_direction", "_isRectangle"];

	private _markerArea = createMarkerLocal [format ["BIS_WL_sectorMarker_%1_area", _forEachIndex], _sectorPos];
	_sector setVariable ["WL2_markerArea", _markerArea];

	private _markerShape = if (_isRectangle) then { "RECTANGLE" } else { "ELLIPSE" };
	_markerArea setMarkerShapeLocal _markerShape;
	_markerArea setMarkerDirLocal _direction;
	_markerArea setMarkerBrushLocal "Solid";
	_markerArea setMarkerAlphaLocal 1;
	_markerArea setMarkerSizeLocal [_axisA, _axisB];

	private _markerMain = createMarkerLocal [format ["BIS_WL_sectorMarker_%1_main", _forEachIndex], _sectorPos];
	_sector setVariable ["WL2_markerMain", _markerMain];

	if !(BIS_WL_playerSide in _revealedBy) then {
		private _sectorName = _sector getVariable ["WL2_name", "Sector"];
		switch (_sectorName) do {
			case "Wait": {
				_markerMain setMarkerTypeLocal "respawn_unknown";
				_markerMain setMarkerColorLocal "ColorWhite";
				_sector setVariable ["BIS_WL_revealedBy", [west, east, independent]];
			};
			case "Surrender": {
				_markerMain setMarkerTypeLocal "KIA";
				_markerMain setMarkerColorLocal "ColorWhite";
				_sector setVariable ["BIS_WL_revealedBy", [west, east, independent]];
			};
			default {
				_markerMain setMarkerTypeLocal "u_installation";
				_markerMain setMarkerColorLocal "ColorUnknown";
				_markerArea setMarkerColorLocal "ColorGrey";
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

private _menuKey = actionKeysNames ["gear", 1, "Combo"];
private _pingKey = actionKeysNames ["TacticalPing", 1, "Combo"];
private _pttKey = actionKeysNames ["pushToTalk", 1, "Combo"];
private _chatKey = actionKeysNames ["chat", 1, "Combo"];
private _infoMarkerTexts = [
	localize "STR_WL_mapInfoText3",
	localize "STR_WL_mapInfoText4",
	localize "STR_WL_mapInfoText5",
	format [localize "STR_WL_mapInfoText12", _menuKey],
	format [localize "STR_WL_mapInfoText6", _pingKey],
	format [localize "STR_WL_mapInfoText7", _pttKey, _chatKey]
];

private _flagBgColor = ["#0000ffff", "#ff0000ff"];
{
	private _base = _x;
	private _flag = _base getVariable ["WL2_flag", objNull];
	if (isNull _flag) then {
		continue;
	};
	private _welcomeText = format [
		"#(rgb,2048,2048,3)text(1,1,""PuristaBold"",0.03,""%1"",""#ffffff"",""%2"")",
		_flagBgColor select _forEachIndex,
		_infoMarkerTexts joinString "\n"
	];
	_flag setObjectTexture [0, _welcomeText];
} forEach WL_BASES;