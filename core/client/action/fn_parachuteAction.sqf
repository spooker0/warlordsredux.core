#include "includes.inc"
params ["_target", "_caller", "_actionId", "_arguments"];

private _callerPos = getPosATL _caller;
private _parachute = createVehicle ["Steerable_Parachute_F", _callerPos, [], 0, "CAN_COLLIDE"];
_parachute setVariable ["BIS_WL_ownerAsset", getPlayerUID _caller, true];
_parachute allowDamage false;
_caller moveInDriver _parachute;
_parachute setDir (getDir _caller);

[_parachute, _caller] spawn {
    params ["_parachute", "_caller"];
    waitUntil {
        uiSleep 0.2;
        private _cutting = inputAction "GetOver" == 1;
        _cutting || !alive _parachute || WL_ISDOWN(_caller);
    };
    moveOut _caller;
    deleteVehicle _parachute;
    _caller allowDamage true;
};

_caller removeAction _actionId;