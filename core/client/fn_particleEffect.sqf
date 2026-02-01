#include "includes.inc"
params ["_positionAGL", "_particleClasses"];
if (isDedicated) exitWith {};
{
    private _particleClass = _x # 0;
    private _particleParam = _x # 1;
    [_positionAGL, _particleClass, _particleParam] spawn {
        params ["_positionAGL", "_particleClass", "_particleParam"];
        private _source = "#particlesource" createVehicleLocal _positionAGL;
        _source setParticleClass _particleClass;

        if (_particleParam isEqualType 0) then {
            uiSleep _particleParam;
            deleteVehicle _source;
        } else {
            if (_particleParam isEqualType []) then {
                private _timer = _particleParam # 0;
                private _actualPos = _particleParam # 1;
                _source setPosASL (AGLtoASL _actualPos);

                uiSleep _timer;
                deleteVehicle _source;
            } else {
                _source attachTo [_particleParam, [0, 0, 0]];
                waitUntil {
                    uiSleep 0.1;
                    !alive _particleParam
                };
                deleteVehicle _source;
            };
        };
    };
} forEach _particleClasses;