// Fit a world-space span to the actual map viewport, with an optional screen-space anchor.
params ["_map", "_center", "_span", ["_anchor", [0.5, 0.5]]];

private _view = ctrlPosition _map;
private _topLeft = _map ctrlMapScreenToWorld [_view # 0, _view # 1];
private _bottomRight = _map ctrlMapScreenToWorld [(_view # 0) + (_view # 2), (_view # 1) + (_view # 3)];
private _width = abs ((_bottomRight # 0) - (_topLeft # 0));
private _height = abs ((_topLeft # 1) - (_bottomRight # 1));
if (_width <= 0 || _height <= 0) exitWith { false };

private _ratio = ((_span # 0) / _width) max ((_span # 1) / _height);
private _scale = ctrlMapScale _map;
if (_scale <= 0) exitWith { false };
private _zoom = ((_scale * _ratio) max 0.001) min 1.5;
_ratio = _zoom / _scale;
private _camera = _center vectorAdd [
    (0.5 - (_anchor # 0)) * _width * _ratio,
    ((_anchor # 1) - 0.5) * _height * _ratio,
    0
];
ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0, _zoom, _camera];
ctrlMapAnimCommit _map;
true;
