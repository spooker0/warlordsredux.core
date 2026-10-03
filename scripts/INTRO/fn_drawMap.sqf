#include "includes.inc"
params ["_map"];

private _display = ctrlParent _map;
if (isNull _display) exitWith {};

private _scene = _display getVariable ["INTRO_scene", 0];
private _animationScale = _display getVariable ["INTRO_animationScale", 1];
private _elapsed = (diag_tickTime - (_display getVariable ["INTRO_sceneStart", diag_tickTime])) * _animationScale;
private _sectors = _display getVariable ["INTRO_sectors", createHashMap];

if (count _sectors == 0) exitWith {};
_display setVariable ["INTRO_labelCount", 0];

private _blue = [0.15, 0.56, 1, 1];
private _red = [1, 0.24, 0.22, 1];
private _green = [0.2, 0.85, 0.42, 1];
private _white = [0.94, 0.97, 1, 1];
private _solid = "#(rgb,1,1,1)color(1,1,1,1)";
private _infantry = "a3\ui_f\data\map\vehicleicons\iconman_ca.paa";

private _offsetPosition = {
    params ["_position", "_offset"];
    private _screen = _map ctrlMapWorldToScreen _position;
    _map ctrlMapScreenToWorld [(_screen # 0) + (_offset # 0), (_screen # 1) + (_offset # 1)]
};
private _text = {
    params ["_position", "_label", "_color", ["_offset", [0, 0]], ["_size", 0.045]];
    [_display, _map, _position, _label, _color, _offset, _size] call INTRO_fnc_label;
};
private _zone = {
    params ["_data", "_color"];
    private _area = _data getOrDefault ["area", []];
    private _position = _data getOrDefault ["position", []];
    if (count _area < 4 || { count _position < 2 }) exitWith {};
    private _args = [_position, _area # 0, _area # 1, _area # 2, _color, "#(rgb,1,1,1)color(1,1,1,0.12)"];
    if (_area # 3) then { _map drawRectangle _args; } else { _map drawEllipse _args; };
};
private _sector = {
    params ["_data", "_side", ["_alpha", 1], ["_offset", [0, 0]]];
    private _prefix = ["b", "o", "n"] # _side;
    private _icon = format ["\A3\ui_f\data\map\markers\nato\%1_%2.paa", _prefix, _data get "iconType"];
    private _color = +([_blue, _red, _green] # _side);
    _color set [3, _alpha];
    [_data, _color] call _zone;
    private _position = [_data get "position", _offset] call _offsetPosition;
    _map drawIcon [_icon, _color, _position, 56, 56, 0];
};

private _airbase = _sectors get "Airbase";
private _target = _airbase get "position";

switch (_scene) do {
    case 2: {
        if (_elapsed >= 0.7) then {
            private _alpha = ((_elapsed - 0.7) / 0.3) min 1;
            private _data = _sectors get "Molos";
            private _color = +_blue;
            _color set [3, _alpha];
            [_data, _color] call _zone;
            _map drawIcon ["\A3\ui_f\data\map\markers\flags\nato_ca.paa", [1, 1, 1, _alpha], _data get "position", 48, 48, 0];
        };
        if (_elapsed >= 3.65) then {
            private _alpha = ((_elapsed - 3.65) / 0.3) min 1;
            private _data = _sectors get "SkoposCastleRuins";
            private _color = +_red;
            _color set [3, _alpha];
            [_data, _color] call _zone;
            _map drawIcon ["\A3\ui_f\data\map\markers\flags\csat_ca.paa", [1, 1, 1, _alpha], _data get "position", 48, 48, 0];
        };
    };
    case 3: {
        private _capture = linearConversion [1.7, 4.55, _elapsed, 0, 1, true];
        [_airbase, if (_capture == 1) then { 0 } else { 1 }] call _sector;

        private _radius = (((_airbase get "area") # 0) min ((_airbase get "area") # 1)) * 0.65;
        for "_i" from 0 to 7 do {
            private _isInfantry = _i < 5;
            private _index = if (_isInfantry) then { _i } else { _i - 5 };
            private _at = if (_isInfantry) then { 0.8 + _index * 0.13 } else { 2.5 + _index * 0.18 };
            if (_elapsed >= _at) then {
                private _progress = linearConversion [_at, _at + 1.3, _elapsed, 0, 1, true];
                _progress = _progress * _progress * (3 - 2 * _progress);
                private _angle = if (_isInfantry) then { 290 + _index * 35 } else { 140 + _index * 40 };
                private _end = if (_isInfantry) then {
                    _target getPos [_radius, _angle]
                } else {
                    [_target, [safeZoneW * (_index - 1) * 0.08, -safeZoneH * 0.065]] call _offsetPosition
                };
                private _start = _target getPos [_radius * 5, _angle];
                private _side = if (_i % 2 == 0) then { 1 } else { -1 };
                private _control = ((_start vectorAdd _end) vectorMultiply 0.5) vectorAdd [
                    sin (_angle + 90) * _radius * 0.8 * _side,
                    cos (_angle + 90) * _radius * 0.8 * _side,
                    0
                ];
                private _remaining = 1 - _progress;
                private _position = ((_start vectorMultiply (_remaining * _remaining)) vectorAdd
                    (_control vectorMultiply (2 * _remaining * _progress))) vectorAdd
                    (_end vectorMultiply (_progress * _progress));
                private _tangent = ((_control vectorDiff _start) vectorMultiply (2 * _remaining)) vectorAdd
                    ((_end vectorDiff _control) vectorMultiply (2 * _progress));
                private _heading = if (_isInfantry) then { _position getDir (_position vectorAdd _tangent) } else { 0 };
                private _texture = if (_isInfantry) then { _infantry } else {
                    ((_display getVariable "INTRO_assets") # (_index + 1)) # 0
                };
                _map drawIcon [_texture, _blue, _position, if (_isInfantry) then { 32 } else { 75 }, if (_isInfantry) then { 32 } else { 45 }, _heading];
            };
        };

        private _screen = _map ctrlMapWorldToScreen _target;
        private _left = (_screen # 0) - safeZoneW * 0.075;
        private _right = _left + safeZoneW * 0.15;
        private _top = (_screen # 1) + safeZoneH * 0.1;
        private _bottom = _top + safeZoneH * 0.014;
        private _bar = {
            params ["_x1", "_x2", "_color"];
            private _points = [[_x1, _top], [_x2, _top], [_x2, _bottom], [_x1, _bottom]] apply { _map ctrlMapScreenToWorld _x };
            _map drawTriangle [[_points # 0, _points # 1, _points # 2], _color, _solid];
            _map drawTriangle [[_points # 0, _points # 2, _points # 3], _color, _solid];
        };
        [_left, _right, _red] call _bar;
        if (_capture > 0) then { [_left, _left + (_right - _left) * _capture, _blue] call _bar; };
    };
    case 4: {
        [_sectors get "MainPower", 2, linearConversion [0.35, 0.65, _elapsed, 0, 1, true]] call _sector;
        if (_elapsed >= 1.45) then {
            [_sectors get "LakkaFactory", 1, linearConversion [1.75, 2.1, _elapsed, 0, 1, true]] call _sector;
        };
    };
    case 6: {
        private _friendly = _sectors get "MainPower";
        [_friendly, 0] call _sector;
    };
    case 7: {
        [_airbase, 1, 1, [0, -safeZoneH * 0.12]] call _sector;
        private _assets = _display getVariable ["INTRO_assets", []];
        private _index = if (_elapsed < 2) then { 0 } else { if (_elapsed < 3.25) then { 1 } else { if (_elapsed < 4.35) then { 2 } else { 3 } } };
        (_assets # _index) params ["_picture", "_name", "_power", "_width", "_height"];
        private _changedAt = [0.5, 2, 3.25, 4.35] # _index;
        if (_index > 0) then {
            [_display, "transport", ["a3\sounds_f_tank\vehicles\armor\afv_wheeled_01\afv_wheeled_01_engine_int_start.wss", 1, 1, false]] call INTRO_fnc_soundCue;
        };
        private _appear = linearConversion [_changedAt, _changedAt + 0.2, _elapsed, 0, 1, true];
        private _pictureColor = if (_index == 0) then { +_blue } else { +_white };
        _pictureColor set [3, _appear];
        _map drawIcon [_picture, _pictureColor, _target, _width * (0.8 + 0.2 * _appear), _height * (0.8 + 0.2 * _appear), 0];
        [_target, _power, _blue, [0, safeZoneH * 0.072], 0.075] call _text;
        [_target, _name, _white, [0, safeZoneH * 0.13], 0.045] call _text;
    };
    case 8: {
        private _links = _display getVariable ["INTRO_links", []];
        private _linkPositions = _links apply { (_sectors get _x) get "position" };

        private _connectionStarts = [0, 0.45 * _animationScale, 0.9 * _animationScale];
        private _linkDuration = 0.25 * _animationScale;
        private _cutAt = _display getVariable ["INTRO_cutTime", 3.8];
        private _cut = _elapsed >= _cutAt;
        private _linkColor = if (_cut) then { [0.3, 0.34, 0.38, 0.75] } else { _blue };
        private _connectedCount = 0;

        {
            private _index = _forEachIndex;
            private _started = _connectionStarts # _index;
            if (_elapsed >= _started) then {
                private _position = _linkPositions # _index;
                private _progress = if (_index == 0) then { 1 } else {
                    linearConversion [_started, _started + _linkDuration, _elapsed, 0, 1, true]
                };
                private _end = _position vectorAdd ((_target vectorDiff _position) vectorMultiply _progress);
                _map drawLine [_position, _end, _linkColor, 10];
                if (_progress == 1) then {
                    _connectedCount = _connectedCount + 1;
                    if (!_cut) then {
                        private _mid = (_position vectorAdd _target) vectorMultiply 0.5;
                        [_mid, "+1", _blue, [0, -safeZoneH * 0.025], 0.065] call _text;
                    };
                };
                private _alpha = if (_index == 0) then { 1 } else {
                    linearConversion [_started, _started + 0.15 * _animationScale, _elapsed, 0, 1, true]
                };
                [_sectors get _x, if (_cut) then { 1 } else { 0 }, _alpha] call _sector;
            };
        } forEach _links;
        [_airbase, 1, 1, [0, -safeZoneH * 0.07]] call _sector;
        _map drawIcon [_infantry, _blue, _target, 40, 40, 0];
        private _power = if (_cut) then { "0" } else { str _connectedCount };
        [_target, _power, if (_cut) then { _red } else { _blue }, [0, safeZoneH * 0.045], 0.065] call _text;

        if (_cut) then {
            [_display, "cut-off", ["AddItemFailed", 1, 1, false]] call INTRO_fnc_soundCue;
            // Mark each severed connection, leaving the target and its zero readable.
            private _progress = linearConversion [_cutAt, _cutAt + 0.45 * _animationScale, _elapsed, 0, 1, true];
            {
                private _mid = (_x vectorAdd _target) vectorMultiply 0.5;
                private _screen = _map ctrlMapWorldToScreen _mid;
                private _halfW = safeZoneW * 0.018;
                private _halfH = safeZoneH * 0.03;
                {
                    _x params ["_from", "_to"];
                    private _end = _from vectorAdd ((_to vectorDiff _from) vectorMultiply _progress);
                    _map drawLine [_map ctrlMapScreenToWorld _from, _map ctrlMapScreenToWorld _end, _red, 10];
                } forEach [
                    [[(_screen # 0) - _halfW, (_screen # 1) - _halfH], [(_screen # 0) + _halfW, (_screen # 1) + _halfH]],
                    [[(_screen # 0) - _halfW, (_screen # 1) + _halfH], [(_screen # 0) + _halfW, (_screen # 1) - _halfH]]
                ];
            } forEach _linkPositions;
            [_target, localize "STR_WL_introCutOff", _red, [0, safeZoneH * 0.12], 0.05] call _text;
        };
    };
    case 9;
    case 10: {
        [_map, _scene, _elapsed] call INTRO_fnc_drawIncome;
    };
    case 11: {
        private _home = _display getVariable ["INTRO_homeSectorData", createHashMap];
        private _position = _home getOrDefault ["position", _display getVariable ["INTRO_homePosition", []]];
        if (count _position > 0) then {
            [_home, _display getVariable ["INTRO_homeColor", _blue]] call _zone;
            _map drawIcon [_display getVariable "INTRO_homeFlag", _white, _position, 64, 64, 0];
        };
    };
};

private _used = _display getVariable ["INTRO_labelCount", 0];
{
    if (_forEachIndex >= _used) then { _x ctrlShow false; };
} forEach (_display getVariable ["INTRO_labelPool", []]);
