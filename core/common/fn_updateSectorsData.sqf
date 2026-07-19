#include "includes.inc"
private _sectorsData = missionNamespace getVariable ["WL2_sectorsData", createHashMap];

private _westSectorsData = _sectorsData getOrDefault ["west", createHashMap];
private _eastSectorsData = _sectorsData getOrDefault ["east", createHashMap];
_sectorsData set ["west", _westSectorsData];
_sectorsData set ["east", _eastSectorsData];

private _sectorPool = missionNamespace getVariable ["BIS_WL_allSectors", []];

private _allLinkedSectors = [];
{
    private _side = _x;
    private _sectorsDataSide = if (_side == west) then {
        _westSectorsData
    } else {
        _eastSectorsData
    };

    private _base = if (_side == west) then {
        WL2_base1
    } else {
        WL2_base2
    };
    _sectorsDataSide set ["base", _base];

    private _currentTarget = missionNamespace getVariable [format ["BIS_WL_currentTarget_%1", _side], objNull];
    _sectorsDataSide set ["currentTarget", _currentTarget];

    private _owned = _sectorPool select {
        (_x getVariable ["BIS_WL_owner", sideUnknown]) == _side
    };
    _sectorsDataSide set ["owned", _owned];

    private _unlocked = _sectorPool select {
        _x == _currentTarget || _side in (_x getVariable ["WL2_capturableBySides", []])
    };
    _sectorsDataSide set ["unlocked", _unlocked];

    private _lastLinkCount = 0;
    private _linked = [_base];
    while { _lastLinkCount < count _linked } do {
        _lastLinkCount = count _linked;
        {
            {
                private _link = _x;
                if (_link in _owned) then {
                    _linked pushBackUnique _link;
                };
            } forEach (_x getVariable ["WL2_connectedSectors", []]);
        } forEach _linked;
    };
    _allLinkedSectors pushBack _linked;
    _sectorsDataSide set ["linked", _linked];

    private _facesData = missionNamespace getVariable ["WL2_sectorFaces", []];
    private _income = 50;
    {
        _x params ["_sectorsInFace", "_area"];
        private _ownsFace = true;
        {
            private _sector = _x;
            private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
            if (_sectorOwner != _side) then {
                _ownsFace = false;
                break;
            };
            private _isLinked = _sector in _linked;
            if (!_isLinked) then {
                _ownsFace = false;
                break;
            };
        } forEach _sectorsInFace;
        if (_ownsFace) then {
            _income = _income + _area * WL_INCOME_M2;
        };
    } forEach _facesData;
    _income = round _income;
    _sectorsDataSide set ["income", _income];

    private _voteable = [];
    {
        private _sector = _x;
        if (_sector getVariable ["BIS_WL_owner", sideUnknown] == _side) then {
            continue;
        };

        private _connections = _sector getVariable ["WL2_connectedSectors", []];
        private _connectedToLinks = _connections arrayIntersect _linked;
        if (count _connectedToLinks > 0) then {
            _voteable pushBack _sector;
            continue;
        };

        private _sectorName = _sector getVariable ["WL2_name", "Sector"];
        if (_sectorName == "Wait") then {
            _voteable pushBack _sector;
        };
    } forEach _sectorPool;
    _sectorsDataSide set ["voteable", _voteable];

    private _unavailable = _unlocked - _linked - _voteable;
    _sectorsDataSide set ["unavailable", _unavailable];
} forEach [west, east];

missionNamespace setVariable ["WL2_sectorsData", _sectorsData];