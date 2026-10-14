#include "..\includes.inc"
params ["_display", "_scene", "_animationDuration", "_timeScale"];

private _map = _display displayCtrl TUT_MAP_IDC;
private _logo = _display displayCtrl TUT_LOGO_IDC;
private _sectorData = _display getVariable ["TUT_sectors", createHashMap];
private _links = _display getVariable ["TUT_links", []];
private _connectionCutAt = _display getVariable ["TUT_connectionCutAt", 4.717];
_display setVariable ["TUT_cutTime", _connectionCutAt / _timeScale];

[_display, "hide"] call TUT_fnc_introMenuScene;
(_display displayCtrl TUT_HOLD_IDC) ctrlShow (_scene == 5);
_logo ctrlShow (_scene == 1);
(_display displayCtrl TUT_LOGO_BACKGROUND_IDC) ctrlShow (_scene == 1);
_map ctrlShow (_scene != 5);

private _animateMap = {
    params ["_seconds", "_zoom", "_position"];
    _map ctrlMapAnimAdd [_seconds * _timeScale, _zoom, _position];
};

private _molos = (_sectorData get "Molos") get "position";
private _skopos = (_sectorData get "SkoposCastleRuins") get "position";
private _airbase = (_sectorData get "Airbase") get "position";
private _green = (_sectorData get "MainPower") get "position";
private _red = (_sectorData get "LakkaFactory") get "position";
private _area = (_sectorData get "Airbase") get "area";
private _captureZoom = ((((_area # 0) max (_area # 1)) * 3) / worldSize) max 0.018;
private _captureCenter = _airbase vectorAdd [0, -(_area # 1) * 0.3, 0];

switch (_scene) do {
    case 1: {
        [0, 0.65, (_molos vectorAdd _skopos) vectorMultiply 0.5] call _animateMap;
        _logo ctrlSetFade 0;
        _logo ctrlSetPosition [safeZoneX + safeZoneW * 0.36, safeZoneY + safeZoneH * 0.32, safeZoneW * 0.28, safeZoneH * 0.22];
        _logo ctrlCommit 0;
        _logo ctrlSetPosition [safeZoneX + safeZoneW * 0.12, safeZoneY + safeZoneH * 0.12, safeZoneW * 0.76, safeZoneH * 0.62];
        _logo ctrlCommit (1.65 * _timeScale);
    };
    case 2: {
        private _overview = (_molos vectorAdd _skopos) vectorMultiply 0.5;
        // Restart the visible sequence at its own overview after preloading.
        [0, 0.65, _overview] call _animateMap;
        [0.7, 0.12, _molos] call _animateMap;
        [1.1, 0.12, _molos] call _animateMap;
        [0.65, 0.65, _overview] call _animateMap;
        [1.2, 0.12, _skopos] call _animateMap;
        [1.35, 0.12, _skopos] call _animateMap;
    };
    case 3: {
        [0.65, _captureZoom, _captureCenter] call _animateMap;
    };
    case 4: {
        [0.45, 0.045, _green] call _animateMap;
        [1, 0.045, _green] call _animateMap;
        [0.65, 0.045, _red] call _animateMap;
        [0.9, 0.045, _red] call _animateMap;
    };
    case 5: {
        [_display, "purchase"] call TUT_fnc_introMenuScene;
    };
    case 6: {
        [0.45, 0.06, _green vectorAdd [250, -100, 0]] call _animateMap;
        [_display, "travel"] call TUT_fnc_introMenuScene;
    };
    case 7: {
        [0.5, _captureZoom, _captureCenter] call _animateMap;
    };
    case 8: {
        private _positions = [_airbase] + (_links apply { (_sectorData get _x) get "position" });
        private _minX = 1e10;
        private _maxX = -1e10;
        private _minY = 1e10;
        private _maxY = -1e10;
        {
            _minX = _minX min (_x # 0);
            _maxX = _maxX max (_x # 0);
            _minY = _minY min (_x # 1);
            _maxY = _maxY max (_x # 1);
        } forEach _positions;
        private _span = ((_maxX - _minX) max (_maxY - _minY)) + 1200;
        private _center = [(_minX + _maxX) * 0.5, (_minY + _maxY) * 0.5 - 250, 0];
        [0, (_span / worldSize) max 0.07, _center] call _animateMap;
    };
    case 9: {
        private _positions = (_display getVariable ["TUT_incomeData", createHashMap]) get "positions";
        private _minX = 1e10;
        private _maxX = -1e10;
        private _minY = 1e10;
        private _maxY = -1e10;
        {
            _minX = _minX min (_x # 0);
            _maxX = _maxX max (_x # 0);
            _minY = _minY min (_x # 1);
            _maxY = _maxY max (_x # 1);
        } forEach _positions;
        private _span = ((_maxX - _minX) max (_maxY - _minY)) + 1500;
        private _center = [(_minX + _maxX) * 0.5, (_minY + _maxY) * 0.5 - 250, 0];
        [0.6, (_span / worldSize) max 0.07, _center] call _animateMap;
    };
    case 10: {
        private _data = _display getVariable ["TUT_incomeData", createHashMap];
        private _positions = _data get "positions10";
        private _departures = _data get "departures10";
        private _arrivals = _data get "arrivals10";
        [0, 0.045, _positions # 0] call _animateMap;
        {
            private _arrived = _arrivals # _forEachIndex;
            private _nextDeparture = if (_forEachIndex < (count _positions - 1)) then {
                _departures # (_forEachIndex + 1)
            } else {
                _animationDuration
            };
            if (_forEachIndex > 0) then {
                [_arrived - (_departures # _forEachIndex), 0.045, _x] call _animateMap;
            };
            private _holdFrom = if (_forEachIndex == 0) then { 0 } else { _arrived };
            [_nextDeparture - _holdFrom, 0.045, _x] call _animateMap;
        } forEach _positions;
    };
    case 11: {
        private _side = missionNamespace getVariable ["BIS_WL_playerSide", side group player];
        private _baseVariable = switch (_side) do {
            case west: { "WL2_base1" };
            case east: { "WL2_base2" };
            default { "" };
        };
        private _home = if (_baseVariable == "") then { objNull } else {
            missionNamespace getVariable [_baseVariable, objNull]
        };
        if (isNull _home && _side == independent) then {
            private _owned = (missionNamespace getVariable ["BIS_WL_allSectors", []]) select {
                private _owner = _x getVariable ["BIS_WL_owner", sideUnknown];
                _owner == _side
            };
            if (count _owned > 0) then {
                _home = _owned # 0;
            };
        };
        private _fallbackSector = if (_side == east) then { "SkoposCastleRuins" } else { "Molos" };
        private _homePosition = if (!isNull _home) then { getPosASL _home } else {
            (_sectorData get _fallbackSector) get "position"
        };
        private _fallback = _sectorData get _fallbackSector;
        private _homeSectorData = createHashMapFromArray [
            ["position", _homePosition],
            ["area", _fallback get "area"]
        ];
        private _homeArea = if (isNull _home) then { [] } else { _home getVariable ["objectAreaComplete", []] };
        if (count _homeArea >= 5) then {
            _homePosition = _homeArea # 0;
            _homeSectorData set ["position", _homePosition];
            _homeSectorData set ["area", [abs (_homeArea # 1), abs (_homeArea # 2), _homeArea # 3, _homeArea # 4]];
        };
        private _homeColor = switch (_side) do {
            case east: { [1, 0.24, 0.22, 1] };
            case independent: { [0.2, 0.85, 0.42, 1] };
            default { [0.15, 0.56, 1, 1] };
        };
        private _flag = switch (_side) do {
            case east: { "\A3\ui_f\data\map\markers\flags\csat_ca.paa" };
            case independent: { "\A3\ui_f\data\map\markers\flags\Altis_ca.paa" };
            default { "\A3\ui_f\data\map\markers\flags\nato_ca.paa" };
        };
        _display setVariable ["TUT_homePosition", _homePosition];
        _display setVariable ["TUT_homeFlag", _flag];
        _display setVariable ["TUT_homeSectorData", _homeSectorData];
        _display setVariable ["TUT_homeColor", _homeColor];
        [0.7, 0.16, _homePosition] call _animateMap;
        [1.1, 0.001, _homePosition] call _animateMap;
    };
};

