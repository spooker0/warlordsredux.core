#include "includes.inc"
params ["_map", "_scene", "_elapsed"];

private _display = ctrlParent _map;
if (isNull _display || !(_scene in [9, 10])) exitWith {};

private _data = _display getVariable ["INTRO_incomeData", createHashMap];
if (count _data == 0) exitWith {};

private _suffix = if (_scene == 10) then { "10" } else { "" };
private _route = _data get ("route" + _suffix);
private _sectors = _data get ("sectorData" + _suffix);
private _positions = _data get ("positions" + _suffix);
private _departures = _data get (format ["departures%1", _scene]);
private _arrivals = _data get (format ["arrivals%1", _scene]);
private _captures = _data get (format ["captures%1", _scene]);

private _blue = [0.15, 0.56, 1, 1];
private _red = [1, 0.24, 0.22, 1];
private _green = [0.2, 0.85, 0.42, 1];
private _white = [0.96, 0.99, 1, 1];
private _money = [0.55, 1, 0.68, 1];

private _solid = "#(rgb,1,1,1)color(1,1,1,1)";
private _infantry = "a3\ui_f\data\map\vehicleicons\iconman_ca.paa";
private _varsuk = getText (configFile >> "CfgVehicles" >> "O_MBT_02_cannon_F" >> "picture");

private _enemyOffsetsForCount = {
    params ["_count"];
    private _layout = if (_count == 4) then {
        [[-0.032, 0.012], [-0.011, -0.002], [0.011, -0.002], [0.064, 0.012]]
    } else {
        [[-0.018, 0.011], [0.018, 0.011]]
    };
    _layout apply { [safeZoneW * (_x # 0), safeZoneH * (_x # 1)] }
};
private _friendlyOffset = [0, safeZoneH * 0.045];

private _offsetPosition = {
    params ["_position", "_offset"];
    private _screen = _map ctrlMapWorldToScreen _position;
    _map ctrlMapScreenToWorld [(_screen # 0) + (_offset # 0), (_screen # 1) + (_offset # 1)]
};
private _text = {
    params ["_position", "_label", "_color", ["_offset", [0, 0]], ["_size", 0.055]];
    [_display, _map, _position, _label, _color, _offset, _size] call INTRO_fnc_label;
};
private _floatingMoney = {
    params ["_position", "_at", ["_offset", [0, 0]]];
    private _age = _elapsed - _at;
    if (_age < 0 || { _age > 1.15 }) exitWith {};
    private _progress = _age / 1.15;
    private _color = +_money;
    _color set [3, 1 - _progress];
    private _floatOffset = [_offset # 0, (_offset # 1) - safeZoneH * (0.035 + 0.075 * _progress)];
    [_position, "$", _color, _floatOffset, 0.06] call _text;
};
private _bar = {
    params ["_position", "_capture", "_uncapturedColor"];
    private _screen = _map ctrlMapWorldToScreen _position;
    private _left = (_screen # 0) - safeZoneW * 0.033;
    private _right = (_screen # 0) + safeZoneW * 0.033;
    private _top = (_screen # 1) + safeZoneH * 0.078;
    private _bottom = _top + safeZoneH * 0.009;
    private _fill = {
        params ["_end", "_color"];
        private _points = [
            [_left, _top], [_end, _top], [_end, _bottom], [_left, _bottom]
        ] apply { _map ctrlMapScreenToWorld _x };
        _map drawTriangle [[_points # 0, _points # 1, _points # 2], _color, _solid];
        _map drawTriangle [[_points # 0, _points # 2, _points # 3], _color, _solid];
    };
    [_right, _uncapturedColor] call _fill;
    if (_capture > 0) then {
        [_left + (_right - _left) * _capture, _blue] call _fill;
    };
};
private _cross = {
    params ["_position", "_progress", ["_vehicle", false]];
    private _screen = _map ctrlMapWorldToScreen _position;
    private _halfW = safeZoneW * (if (_vehicle) then { 0.035 } else { 0.008 });
    private _halfH = safeZoneH * (if (_vehicle) then { 0.035 } else { 0.015 });
    {
        _x params ["_from", "_to"];
        private _end = _from vectorAdd ((_to vectorDiff _from) vectorMultiply _progress);
        _map drawLine [_map ctrlMapScreenToWorld _from, _map ctrlMapScreenToWorld _end, _red, 7];
    } forEach [
        [[(_screen # 0) - _halfW, (_screen # 1) - _halfH], [(_screen # 0) + _halfW, (_screen # 1) + _halfH]],
        [[(_screen # 0) - _halfW, (_screen # 1) + _halfH], [(_screen # 0) + _halfW, (_screen # 1) - _halfH]]
    ];
};

// Use the same triangle-fan fill as the mission's map polygon renderer.
if (_scene == 9) then {
    {
        private _region = _x;
        private _capturedAt = 0;
        {
            _capturedAt = _capturedAt max (_captures # (_route find _x));
        } forEach (_region get "members");
        private _points = _region get "positions";
        private _color = if (_elapsed < _capturedAt) then {
            [0.12, 0.16, 0.2, 0.16]
        } else {
            [0.1, 0.42, 1, linearConversion [_capturedAt, _capturedAt + 0.35, _elapsed, 0.16, 0.34, true]]
        };
        private _anchor = _points # (count _points - 1);
        for "_i" from 0 to (count _points - 3) do {
            _map drawTriangle [[_points # _i, _points # (_i + 1), _anchor], _color, _solid];
        };
        if (_elapsed >= _capturedAt) then {
            private _color = +_white;
            _color set [3, linearConversion [_capturedAt, _capturedAt + 0.3, _elapsed, 0, 1, true]];
            [_region get "center", "$", _color, [0, 0], 0.085] call _text;
        };
    } forEach (_data get "regions");
};

{
    _x params ["_from", "_to"];
    private _fromIndex = _route find _from;
    private _toIndex = _route find _to;
    private _owned = _elapsed >= (_captures # _fromIndex) && { _elapsed >= (_captures # _toIndex) };
    _map drawLine [
        _positions # _fromIndex, _positions # _toIndex,
        if (_owned) then { _blue } else { [0.48, 0.52, 0.56, 0.75] }, 6
    ];
} forEach (_data get ("links" + _suffix));

{
    private _index = _forEachIndex;
    private _sector = _sectors get _x;
    private _position = _positions # _index;
    private _captured = _elapsed >= (_captures # _index);
    private _independent = _scene == 10 && { (_route # _index) == "Anthrakia" };
    private _uncapturedColor = if (_independent) then { _green } else { _red };
    private _color = if (_captured) then { _blue } else { _uncapturedColor };
    private _area = _sector get "area";
    private _zone = [_position, _area # 0, _area # 1, _area # 2, _color, "#(rgb,1,1,1)color(1,1,1,0.1)"];
    if (_area # 3) then { _map drawRectangle _zone; } else { _map drawEllipse _zone; };
    private _icon = format [
        "\A3\ui_f\data\map\markers\nato\%1_%2.paa",
        if (_captured) then { "b" } else { if (_independent) then { "n" } else { "o" } }, _sector get "iconType"
    ];
    _map drawIcon [_icon, _color, [_position, [0, -safeZoneH * 0.032]] call _offsetPosition, 42, 42, 0];
    private _capture = linearConversion [_arrivals # _index, _captures # _index, _elapsed, 0, 1, true];
    [_position, _capture, _uncapturedColor] call _bar;

    if (_scene == 10) then {
        // Each kill and each completed capture has its own short money animation.
        private _enemyCount = (_data get "enemyCounts10") # _index;
        private _enemyOffsets = [_enemyCount] call _enemyOffsetsForCount;
        private _killOffsets = (_data get "kills10") # _index;
        for "_enemy" from 0 to (_enemyCount - 1) do {
            private _isTank = (_route # _index) == "Paros" && { _enemy == 3 };
            private _offset = _enemyOffsets # _enemy;
            private _enemyPosition = [_position, _offset] call _offsetPosition;
            private _killedAt = (_arrivals # _index) + (_killOffsets # _enemy);
            private _killed = _elapsed >= _killedAt;
            private _enemyColor = +(if ((_route # _index) == "Anthrakia") then { _green } else { _red });
            if (_killed) then { _enemyColor set [3, 0.25]; };
            _map drawIcon [
                if (_isTank) then { _varsuk } else { _infantry },
                _enemyColor, _enemyPosition,
                if (_isTank) then { 112 } else { 27 },
                if (_isTank) then { 64 } else { 27 },
                if (_isTank) then { 0 } else { 180 }
            ];
            if (_killed) then {
                private _shot = if (_isTank) then {
                    "a3\sounds_f_tank\arsenal\weapons\launchers\vorona\vorona_closeshot_04.wss"
                } else {
                    "a3\sounds_f\arsenal\weapons\machineguns\mk200\silencer_mk200_03.wss"
                };
                [_display, format ["kill-%1-%2", _index, _enemy], [_shot, 1, 1, false]] call INTRO_fnc_soundCue;
                [_enemyPosition, linearConversion [_killedAt, _killedAt + 0.13, _elapsed, 0, 1, true], _isTank] call _cross;
            };
            [_position, _killedAt, _offset] call _floatingMoney;
        };
        [_position, _captures # _index, [0, -safeZoneH * 0.03]] call _floatingMoney;
    };
} forEach _route;

private _leg = 0;
{
    if (_elapsed >= _x) then { _leg = _forEachIndex; };
} forEach _departures;
private _end = _positions # _leg;

private _start = if (_leg == 0) then {
    _end vectorAdd [-700, -450, 0]
} else {
    _positions # (_leg - 1)
};

private _progress = linearConversion [_departures # _leg, _arrivals # _leg, _elapsed, 0, 1, true];
_progress = _progress * _progress * (3 - 2 * _progress);

private _travelHeading = _start getDir _end;
private _curve = (_start distance2D _end) * 0.12 * (if (_leg % 2 == 0) then { 1 } else { -1 });
private _control = ((_start vectorAdd _end) vectorMultiply 0.5) vectorAdd [
    sin (_travelHeading + 90) * _curve, cos (_travelHeading + 90) * _curve, 0
];

private _remaining = 1 - _progress;
private _troopPosition = ((_start vectorMultiply (_remaining * _remaining)) vectorAdd
    (_control vectorMultiply (2 * _remaining * _progress))) vectorAdd
    (_end vectorMultiply (_progress * _progress));
private _tangent = ((_control vectorDiff _start) vectorMultiply (2 * _remaining)) vectorAdd
    ((_end vectorDiff _control) vectorMultiply (2 * _progress));
private _heading = _troopPosition getDir (_troopPosition vectorAdd _tangent);

if (_scene == 10 && { _elapsed >= (_arrivals # _leg) }) then {
    private _friendlyPosition = [_end, _friendlyOffset] call _offsetPosition;
    private _enemyCount = (_data get "enemyCounts10") # _leg;
    private _enemyOffsets = [_enemyCount] call _enemyOffsetsForCount;
    private _enemyHeadings = _enemyOffsets apply {
        _friendlyPosition getDir ([_end, _x] call _offsetPosition)
    };
    private _turn = {
        params ["_from", "_to", "_progress"];
        _progress = _progress * _progress * (3 - 2 * _progress);
        private _delta = ((_to - _from + 540) % 360) - 180;
        (_from + _delta * _progress + 360) % 360
    };
    private _stopped = _elapsed - (_arrivals # _leg);
    private _killOffsets = (_data get "kills10") # _leg;
    private _arrivalHeading = _heading;
    {
        private _enemy = _forEachIndex;
        private _turnStart = if (_enemy == 0) then { 0 } else { (_killOffsets # (_enemy - 1)) + 0.08 };
        private _turnEnd = _x - 0.08;
        if (_stopped >= _turnStart) then {
            private _from = if (_enemy == 0) then { _arrivalHeading } else { _enemyHeadings # (_enemy - 1) };
            _heading = [_from, _enemyHeadings # _enemy, linearConversion [_turnStart, _turnEnd, _stopped, 0, 1, true]] call _turn;
        };
    } forEach _killOffsets;
};

private _squad = if (_scene == 9) then {
    [[-safeZoneW * 0.018, safeZoneH * 0.044], [0, safeZoneH * 0.025], [safeZoneW * 0.018, safeZoneH * 0.044]]
} else {
    [_friendlyOffset]
};
{
    _map drawIcon [_infantry, _blue, [_troopPosition, _x] call _offsetPosition, 32, 32, _heading];
} forEach _squad;
