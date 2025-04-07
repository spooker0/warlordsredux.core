#include "..\..\warlords_constants.inc"

params ["_position", "_dirAndUp", "_caller", "_target", "_dummy", "_isStrongholdDemolish"];

private _charge = createVehicleLocal ["DemoCharge_F", _position, [], 0, "FLY"];
_charge allowDamage false;
_charge setPosASL _position;
_charge setVectorDirAndUp _dirAndUp;
[_charge, _dummy] call BIS_fnc_attachToRelative;

hideObject _dummy;

private _objectScale = if (_isStrongholdDemolish) then {
    6
} else {
    3
};
_charge setObjectScale _objectScale;

_charge setVariable ["WL_demolishable", _target];

private _targetChildren = _target getVariable ["WL2_children", []];
_targetChildren pushBack _charge;
_target setVariable ["WL2_children", _targetChildren];

if (isDedicated) exitWith {};

private _lightToggle = false;
private _lightPos = (_charge modelToWorld [0, 0, 0]) vectorAdd [0, 0, 0.2];
private _lightPoint = createVehicle ["#lightpoint", _lightPos, [], 0, "FLY"];
_lightPoint setLightAttenuation [0.5, 0, 100, 0];
_lightPoint setLightDayLight true;
_lightPoint setLightFlareMaxDistance 500;
_lightPoint setLightColor[1, 0, 0];
_lightPoint setLightAmbient[1, 0, 0];
_lightPoint setLightIntensity 0;

private _startTime = serverTime;
private _demolishTotalTime = if (_isStrongholdDemolish) then {
    WL_DEMOLISH_FOB_TIME
} else {
    WL_DEMOLISH_TIME
};

while { alive _charge && alive _target && alive _dummy } do {
    private _sleepTime = 0.5;

    if (_lightToggle) then {
        _lightPoint setLightIntensity 200000;
    } else {
        _lightPoint setLightIntensity 0;
    };
    _lightToggle = !_lightToggle;

    playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", _charge, false, getPosASL _charge, 2, 1, 200, 0, true];

    private _timeRemaining = (_startTime + WL_DEMOLISH_TIME) - serverTime;
    private _holdChargeExplosion = _dummy getVariable ["WL_holdChargeExplosion", false];
    if (_timeRemaining <= 0 && !_holdChargeExplosion) then {
        if (local _caller) then {
            private _strongholdSector = _target getVariable ["WL_strongholdSector", objNull];
            if !(isNull _strongholdSector) then {
                private _strongholdSectorCheck = _strongholdSector getVariable ["WL_stronghold", objNull];
                if (_target == _strongholdSectorCheck) then {
                    [_strongholdSector] call WL2_fnc_removeStronghold;
                };
            };

            private _explosive = if (_isStrongholdDemolish) then {
                "Bo_Mk82"
            } else {
                "SatchelCharge_Remote_Ammo_Scripted"
            };

            [_target, _caller, _explosive, _lightPos] remoteExec ["WL2_fnc_demolishComplete", 2];
        };
        deleteVehicle _charge;
        deleteVehicle _lightPoint;
        sleep 2;
        playSound3D ["a3\sounds_f\sfx\special_sfx\building_destroy_01.wss", objNull, false, _lightPos, 2, 1, 200, 0, true];
    } else {
        _sleepTime = (_timeRemaining / WL_DEMOLISH_TIME) max 0.1;
    };

    sleep _sleepTime;
};

deleteVehicle _charge;
deleteVehicle _lightPoint;
deleteVehicle _dummy;