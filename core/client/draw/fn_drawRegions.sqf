#include "includes.inc"
if (isDedicated) exitWith {};

while { !BIS_WL_missionEnd } do {
    private _facesData = missionNamespace getVariable ["WL2_sectorFaces", []];
    if (_facesData isEqualTo []) then {
        uiSleep 1;
        continue;
    };

    private _side = BIS_WL_playerSide;

    private _neutralRGBA = [0.2, 0.2, 0.2, 0.1];
    private _sideColorRGBA = switch (_side) do {
        case west: { [0, 0.3, 0.6, 0.4] };
        case east: { [0.5, 0, 0, 0.4] };
        case independent: { _neutralRGBA };
        default { _neutralRGBA };
    };

    {
        _x setVariable ["WL2_drawRegionIds", []];
    } forEach BIS_WL_allSectors;

    private _regionMap = createHashMap;
    {
        _x params ["_sectors", "_area"];

        private _ownsFace = true;
        {
            private _sectorOwner = _x getVariable ["BIS_WL_owner", sideUnknown];
            if (WL_IsSpectator) then {
                if !(_sectorOwner in [west, east]) then {
                    _ownsFace = false;
                    break;
                };
            } else {
                if (_sectorOwner != _side) then {
                    _ownsFace = false;
                    break;
                };
            };
        } forEach _sectors;

        private _location = [0, 0, 0];
        {
            _location = _location vectorAdd (getPosASL _x);
        } forEach _sectors;
        _location = _location vectorMultiply (1 / count _sectors);

        private _showBonus = uiNamespace getVariable ["WL2_mapShowBonus", false];

        private _income = round (_area * WL_INCOME_M2);
        private _incomeText = if (_showBonus || WL_IsSpectator) then {
            format ["%1 km² (%2%3)", (_area / 1e6) toFixed 1, WL_MONEY_SIGN, _income]
        } else {
            format ["%1 km²", (_area / 1e6) toFixed 1]
        };

        private _regionText = [
            "#(rgb,1,1,1)color(1,1,1,1)",
            [1, 1, 1, 1],
            _location,
            0,
            0,
            0,
            _incomeText,
            1,
            0.06,
            "PuristaSemibold",
            "center"
        ];

        private _sectorDrawPoints = _sectors apply {
            getPosASL _x;
        };

        private _colorToUse = if (WL_IsSpectator) then {
            // private _sectorDifficulty = 0;
            // {
            // 	private _value = _x getVariable ["BIS_WL_value", 0];
            // 	_sectorDifficulty = _sectorDifficulty + _value;
            // } forEach _sectors;
            // private _efficiency = _area / (_sectorDifficulty max 1);

            // private _minEfficiency = 7000;
            // private _maxEfficiency = 700000;

            // private _colorValue = linearConversion [ln _minEfficiency, ln _maxEfficiency, ln _efficiency, 1, 0];
            // [_colorValue, _colorValue, _colorValue, 1]

            private _sectorOwnerSides = [];
            {
                private _owner = _x getVariable ["BIS_WL_owner", independent];
                _sectorOwnerSides pushBackUnique _owner;
            } forEach _sectors;
            if (count _sectorOwnerSides == 1) then {
                switch (_sectorOwnerSides # 0) do {
                    case west: { [0, 0.3, 0.6, 0.4] };
                    case east: { [0.5, 0, 0, 0.4] };
                    default { _neutralRGBA };
                };
            } else {
                _neutralRGBA
            };
        } else {
            if (_ownsFace) then {
                _sideColorRGBA
            } else {
                _neutralRGBA
            };
        };
        private _regionShape = [
            _sectorDrawPoints,
            _colorToUse,
            "#(rgb,1,1,1)color(1,1,1,1)"
        ];
        private _faceIndex = _forEachIndex;
        {
            private _sectorRegionIds = _x getVariable "WL2_drawRegionIds";
            _sectorRegionIds pushBack _faceIndex;
        } forEach _sectors;

        _regionMap set [_faceIndex, [
            _regionText,
            _regionShape
        ]];
    } forEach _facesData;
    uiNamespace setVariable ["WL2_drawRegionMap", _regionMap];

    private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
    private _mapSectorLineGrayscale = _settingsMap getOrDefault ["mapSectorLineGrayscale", 1];

    private _allLinks = missionNamespace getVariable ["WL2_linkSectorMarkers", createHashMap];
    private _neutralLinkColor = [_mapSectorLineGrayscale, _mapSectorLineGrayscale, _mapSectorLineGrayscale, 1];
    private _ownedSectorLinkColor = if (_side == west) then {
        [0, 0.3, 0.6, 1]
    } else {
        [0.5, 0, 0, 1]
    };

    private _regionLines = [];
    {
        private _pairKey = _x;
        private _linkData = _y;
        _y params ["_startPos", "_endPos", "_sector", "_link"];
        private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
        private _linkOwner = _link getVariable ["BIS_WL_owner", sideUnknown];
        private _linkColor = if (_sectorOwner == _side && _linkOwner == _side) then {
            _ownedSectorLinkColor;
        } else {
            _neutralLinkColor;
        };

        _regionLines pushBack [
            _startPos,
            _endPos,
            _linkColor,
            10
        ];
    } forEach _allLinks;
    uiNamespace setVariable ["WL2_drawRegionLines", _regionLines];

    {
        private _sectorTarget = _x;

        private _links = [_sectorTarget];
        private _linksToShow = 0;

        private _allConnections = [];
        {
            private _connections = _x getVariable ["WL2_connectedSectors", []];
            _allConnections insert [-1, _connections, true];
        } forEach _links;
        _links insert [-1, _allConnections, true];

        _sectorsInLinksShown = _links;

        private _sectorLines = [];
        private _drawnLinks = createHashMap;
        {
            private _pairKey = _x;
            private _linkData = _y;
            _y params ["_startPos", "_endPos", "_sector", "_link"];
            if !(_sector in _links) then {
                continue;
            };
            if !(_link in _links) then {
                continue;
            };
            if (_pairKey in _drawnLinks) then {
                continue;
            };
            if (_sector != _sectorTarget && _link != _sectorTarget) then {
                continue;
            };

            private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
            private _linkOwner = _link getVariable ["BIS_WL_owner", sideUnknown];
            private _linkColor = if (_sectorOwner == _side && _linkOwner == _side) then {
                _ownedSectorLinkColor;
            } else {
                _neutralLinkColor;
            };

            _sectorLines pushBack [
                _startPos,
                _endPos,
                _linkColor,
                10
            ];
            _drawnLinks set [_pairKey, true];
        } forEach _allLinks;

        _sectorTarget setVariable ["WL2_drawSectorLines", _sectorLines];
    } forEach BIS_WL_allSectors;

    uiSleep 5;
};