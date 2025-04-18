params ["_start"];

if (speed player > 5) exitWith {
    false;
};

if (_start) then {
    private _cursorObject = cursorObject;
    private _target = _cursorObject getVariable ["WL_demolishable", objNull];
    if !(isNull _target) then {
        true;
    } else {
        private _nearbyCharges = player nearObjects ["DemoCharge_F", 5];
        if (count _nearbyCharges > 0) then {
            private _charge = _nearbyCharges # 0;
            private _targetIntersections = lineIntersectsSurfaces [
                AGLToASL positionCameraToWorld [0, 0, 0],
                getPosASL _charge,
                player,
                _charge,
                true,
                1,
                "FIRE",
                "",
                true
            ];
            count _targetIntersections == 0 || {
                (_targetIntersections # 0 # 0) distance (getPosASL _charge) < 0.1
            };
        } else {
            false;
        };
    };
} else {
    true;
};