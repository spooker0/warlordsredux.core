#include "..\includes.inc"
params ["_map"];

private _display = ctrlParent _map;
private _scene = _display getVariable ["TUT_scene", 0];
private _elapsed = _display getVariable ["TUT_elapsed", 0];
private _jetIcon = _display getVariable ["TUT_jetIcon", ""];
private _yellow = [1, 0.85, 0.15, 1];
private _red = [1, 0.24, 0.22, 1];
private _white = [0.94, 0.97, 1, 1];
private _blue = [0.15, 0.56, 1, 1];

private _needsFit = _display getVariable ["TUT_mapNeedsFit", false];
if (ctrlIDC _map == TUT_MAP_IDC && _needsFit) then {
    private _mapView = _display getVariable ["TUT_mapView", [[0, 0, 0], [6500, 2000], [0.5, 0.64]]];
    private _fitted = ([_map] + _mapView) call TUT_fnc_fitMap;
    _display setVariable ["TUT_mapNeedsFit", !_fitted];
};

// The canvas fills the panel; keep diagrams clear of the overlaid title and footer.
private _view = ctrlPosition _map;
_view = [
    (_view # 0) + (_view # 2) * 0.045,
    (_view # 1) + (_view # 3) * 0.095,
    (_view # 2) * 0.91,
    (_view # 3) * 0.70
];
private _width = _view # 2;
private _height = _view # 3;
private _point = {
    params ["_x", "_y"];
    _map ctrlMapScreenToWorld [(_view # 0) + _width * _x, (_view # 1) + _height * _y];
};
private _text = {
    params ["_position", "_label", "_color", ["_offset", [0, 0]], ["_size", 0.05], ["_labelWidth", 0.34]];
    [_display, _map, _position, _label, _color, _offset, _size * _height / safeZoneH, _labelWidth * _width / safeZoneW] call TUT_fnc_label;
};
private _cross = {
    params ["_position", "_progress"];
    private _screen = _map ctrlMapWorldToScreen _position;
    private _halfWidth = _width * 0.045;
    private _halfHeight = _height * 0.10;
    {
        _x params ["_from", "_to"];
        private _end = _from vectorAdd ((_to vectorDiff _from) vectorMultiply _progress);
        _map drawLine [_map ctrlMapScreenToWorld _from, _map ctrlMapScreenToWorld _end, _red, 7];
    } forEach [
        [[(_screen # 0) - _halfWidth, (_screen # 1) - _halfHeight], [(_screen # 0) + _halfWidth, (_screen # 1) + _halfHeight]],
        [[(_screen # 0) - _halfWidth, (_screen # 1) + _halfHeight], [(_screen # 0) + _halfWidth, (_screen # 1) - _halfHeight]]
    ];
};

switch (_scene) do {
    case 1;
    case 2: {
        private _launcher = _display getVariable ["TUT_launcher", [0, 0, 0]];
        private _spartanIcon = _display getVariable ["TUT_spartanIcon", ""];
        private _jet = _display getVariable ["TUT_jetPosition", _launcher];
        private _heading = _display getVariable ["TUT_jetHeading", 270];
        private _missile = _display getVariable ["TUT_missilePosition", _launcher];

        _map drawLine [_launcher, _missile, [1, 0.24, 0.22, 0.3], 6];
        _map drawIcon [_spartanIcon, _red, _launcher, 64, 64, 0];
        [_launcher, localize "STR_WL_pilotSpartan", _red, [0, _height * 0.08]] call _text;
        _map drawIcon ["\A3\ui_f\data\map\markers\military\triangle_CA.paa", _red, _missile, 30, 30, 90];
        _map drawIcon [_jetIcon, _yellow, _jet, 76, 76, _heading];
        [_jet, localize "STR_WL_pilotYou", _yellow, [0, _height * 0.09]] call _text;

        if (_scene == 1 && _elapsed >= 4) then {
            private _key = _display getVariable ["TUT_launchKey", ""];
            [[0.5, 0.57] call _point, _key, _white, [0, 0], 0.28, 0.85] call _text;
        };
    };
    case 3: {
        private _jet = [0.5, 0.58] call _point;
        private _emission = _display getVariable ["TUT_flareEmission", [1, 0.06]];
        _emission params ["_fireAt", "_interval"];

        // Draw all ten pairs together; their emission times distinguish burst from singles.
        for "_pair" from 0 to 9 do {
            private _age = _elapsed - _fireAt - _pair * _interval;
            if (_age < 0 || _age > 2.5) then {
                continue;
            };

            private _alpha = linearConversion [1.6, 2.5, _age, 1, 0, true];
            private _angle = linearConversion [0, 9, _pair, 15, 75];
            private _offsetX = 0.035 + (cos _angle) * 0.12 * _age;
            private _y = 0.592 + (sin _angle) * 0.12 * _age + 0.012 * _age * _age;
            {
                private _position = [0.5 + _x * _offsetX, _y] call _point;
                _map drawIcon ["\A3\ui_f\data\map\markers\military\dot_CA.paa", [1, 0.7, 0.2, _alpha], _position, 18, 18, 0];
            } forEach [-1, 1];
        };

        _map drawIcon [_jetIcon, _yellow, _jet, 100, 100, 0];
        private _key = _display getVariable ["TUT_modeKey", ""];
        [[0.5, 0.20] call _point, localize "STR_WL_pilotSwitchMode", _white, [0, 0], 0.05, 0.85] call _text;
        [[0.5, 0.33] call _point, _key, _white, [0, 0], 0.13, 0.85] call _text;
    };
    case 4: {
        private _bounds = ctrlPosition _map;
        _bounds params ["_left", "_top", "_viewWidth", "_viewHeight"];
        private _topLeft = _map ctrlMapScreenToWorld [_left, _top];
        private _bottomRight = _map ctrlMapScreenToWorld [_left + _viewWidth, _top + _viewHeight];
        private _center = _map ctrlMapScreenToWorld [_left + _viewWidth / 2, _top + _viewHeight / 2];
        _map drawRectangle [
            _center,
            abs ((_bottomRight # 0) - (_topLeft # 0)) / 2,
            abs ((_bottomRight # 1) - (_topLeft # 1)) / 2,
            0,
            [0.025, 0.05, 0.10, 1],
            "#(rgb,1,1,1)color(1,1,1,1)"
        ];

        for "_km" from 0 to 10 do {
            private _y = linearConversion [0, 10, _km, 0.88, 0.12];
            _map drawLine [[0.22, _y] call _point, [0.39, _y] call _point, [0.65, 1, 0.7, 1], 4];
            [[0.15, _y] call _point, format [localize "STR_WL_distanceKilometers", _km], _white, [0, 0], 0.05, 0.15] call _text;
        };
        private _sideIcon = _display getVariable ["TUT_sideJetIcon", ""];

        // Bob by up to 0.5 km every three seconds, staying within the altitude scale.
        private _altitudeOffset = (1 - cos (_elapsed * 120)) * 0.25;
        private _low = [0.48, linearConversion [0, 10, _altitudeOffset, 0.88, 0.12]] call _point;
        private _high = [0.48, linearConversion [0, 10, 10 - _altitudeOffset, 0.88, 0.12]] call _point;

        _map drawIcon [_sideIcon, _yellow, _high, 120, 90, 0];
        _map drawIcon [_sideIcon, _white, _low, 120, 90, 0];
        if (_elapsed >= 2) then {
            [_low, linearConversion [2, 2.5, _elapsed, 0, 1, true]] call _cross;
        };
        [[0.73, 0.40] call _point, localize "STR_WL_pilotHigher", _blue, [0, 0], 0.13, 0.40] call _text;
        [[0.73, 0.50] call _point, localize "STR_WL_pilotIsBetter", _white, [0, 0], 0.085, 0.40] call _text;
    };
    case 5: {
        [[0.5, 0.10] call _point, localize "STR_WL_pilotFaster", _blue, [0, 0], 0.13, 0.60] call _text;
        [[0.5, 0.20] call _point, localize "STR_WL_pilotIsBetter", _white, [0, 0], 0.085, 0.60] call _text;

        private _slowX = 0.10 + 0.08 * (_elapsed min 3);
        private _fastX = (0.90 - 0.17 * _elapsed) max 0.10;
        private _slow = [_slowX, 0.62] call _point;
        private _fast = [_fastX, 0.40] call _point;
        _map drawLine [[0.10, 0.62] call _point, _slow, [0.5, 0.5, 0.5, 0.5], 3];
        _map drawLine [[0.90, 0.40] call _point, _fast, [1, 0.85, 0.15, 0.5], 3];
        _map drawIcon [_jetIcon, _white, _slow, 90, 90, 90];
        _map drawIcon [_jetIcon, _yellow, _fast, 90, 90, 270];
        if (_elapsed >= 3) then {
            [_slow, linearConversion [3, 3.5, _elapsed, 0, 1, true]] call _cross;
        };
    };
    case 6: {
        private _sites = _display getVariable ["TUT_sites", []];
        {
            _x params ["_position", "_icon", "_name", "_radius"];
            private _age = _elapsed - _forEachIndex * 0.6;
            if (_age < 0) then {
                continue;
            };

            private _alpha = linearConversion [0, 0.25, _age, 0, 1, true];
            private _ring = linearConversion [0.25, 1.1, _age, 0, _radius, true];
            private _color = [1, 0.24, 0.22, _alpha];
            _map drawEllipse [_position, _ring, _ring, 0, [0.5, 0, 0, 0.1 * _alpha], "#(rgb,1,1,1)color(1,0,0,1)"];
            _map drawEllipse [_position, _ring, _ring, 0, [1, 0.24, 0.22, 0.6 * _alpha], ""];
            _map drawIcon [_icon, _color, _position, 48 * _alpha, 48 * _alpha, 0];
            [_position, _name, _color, [0, _height * 0.065], 0.047] call _text;
        } forEach _sites;

        private _start = _display getVariable ["TUT_routeStart", [0, 0, 0]];
        private _end = _display getVariable ["TUT_routeEnd", [0, 0, 0]];
        private _speed = (_start distance2D _end) / 12;
        private _radius = _speed / (pi / 2);
        private _turnStart = _start vectorAdd [-_speed, 0, 0];
        private _turnCenter = _turnStart vectorAdd [0, -_radius, 0];
        private _angle = linearConversion [1, 2, _elapsed, 0, 90, true];

        // Fly west, then turn left through the middle second of the three-second loop.
        private _position = if (_elapsed < 1) then {
            _start vectorAdd [-_speed * _elapsed, 0, 0];
        } else {
            _turnCenter vectorAdd [
                -_radius * (sin _angle),
                _radius * (cos _angle) - _speed * ((_elapsed - 2) max 0),
                0
            ];
        };

        private _last = _start vectorAdd [-_speed * (_elapsed min 1), 0, 0];
        private _trailColor = [1, 0.85, 0.15, 0.55];
        _map drawLine [_start, _last, _trailColor, 3];

        for "_step" from 10 to _angle step 10 do {
            private _trailPoint = _turnCenter vectorAdd [-_radius * (sin _step), _radius * (cos _step), 0];
            _map drawLine [_last, _trailPoint, _trailColor, 3];
            _last = _trailPoint;
        };

        _map drawLine [_last, _position, _trailColor, 3];
        _map drawIcon [_jetIcon, _yellow, _position, 70, 70, 270 - _angle];
        [_position, localize "STR_WL_pilotYou", _yellow, [0, _height * 0.07], 0.05] call _text;
    };
};
