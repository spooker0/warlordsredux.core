params ["_startPos", "_target", "_endPos", "_unit"];

if (isNull _target) then {
    _target = createVehicleLocal ["LaserTargetC", _endPos, [], 0, "FLY"];
    _target setPosASL _endPos;
    [_target] spawn {
        params ["_target"];
        sleep 20;
        deleteVehicle _target;
    };
};

_startPos set [2, _startPos # 2 - 10];
private _ammo = createVehicle ["M_Scalpel_AT", _startPos, [], 0, "FLY"];
_ammo setShotParents [_unit, _unit];
_ammo setPosASL _startPos;
_ammo setMissileTarget [_target, true];