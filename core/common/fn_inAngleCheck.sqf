params ["_center", "_dir", "_sector", "_pos"];
private _dirTo = _center getDir _pos;
private _vector = [sin _dir, cos _dir, 0] vectorCos [sin _dirTo, cos _dirTo, 0];
_vector = _vector min 1;
acos _vector <= _sector / 2;