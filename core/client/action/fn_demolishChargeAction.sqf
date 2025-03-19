#include "..\..\warlords_constants.inc"

params ["_position", "_dirAndUp", "_timer", "_caller", "_target", "_dummy"];

private _charge = createVehicleLocal ["DemoCharge_F", _position, [], 0, "FLY"];
_charge allowDamage false;
_charge setPosASL _position;
_charge setVectorDirAndUp _dirAndUp;
[_charge, _dummy] call BIS_fnc_attachToRelative;
_charge setObjectScale 3;

_charge setVariable ["WL_demolishTime", _timer];
_charge setVariable ["WL_demolisher", _caller];
_charge setVariable ["WL_demolishable", _target];

private _targetChildren = _target getVariable ["WL2_children", []];
_targetChildren pushBack _charge;
_target setVariable ["WL2_children", _targetChildren];

if (isDedicated) exitWith {};

private _dummyTarget = attachedTo _charge;

private _lightToggle = false;
private _lightPos = getPosATL _charge;
_lightPos set [2, _lightPos # 2 + 0.2];
private _lightPoint = createVehicle ["#lightpoint", _lightPos, [], 0, "FLY"];
_lightPoint setLightAttenuation [0.5, 0, 100, 0];
_lightPoint setLightDayLight true;
_lightPoint setLightFlareMaxDistance 500;
_lightPoint setLightColor[1, 0, 0];
_lightPoint setLightAmbient[1, 0, 0];
_lightPoint setLightIntensity 0;

private _asset = _charge getVariable ["WL_demolishable", objNull];
while { alive _charge && alive _asset && alive _dummyTarget } do {
    private _sleepTime = 0.5;
    private _demolishTime = _charge getVariable ["WL_demolishTime", -1];

    if (_lightToggle) then {
        _lightPoint setLightIntensity 200000;
    } else {
        _lightPoint setLightIntensity 0;
    };
    _lightToggle = !_lightToggle;

    playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", _charge, false, getPosASL _charge, 2, 1, 200, 0, true];

    private _timeRemaining = (_demolishTime + WL_DEMOLISH_TIME) - serverTime;
    private _holdChargeExplosion = _charge getVariable ["WL_holdChargeExplosion", false];
    if (_timeRemaining <= 0 && !_holdChargeExplosion) then {
        private _demolisher = _charge getVariable ["WL_demolisher", objNull];
        if (local _demolisher) then {
            private _strongholdSector = _asset getVariable ["WL_strongholdSector", objNull];
            if !(isNull _strongholdSector) then {
                private _strongholdSectorCheck = _strongholdSector getVariable ["WL_stronghold", objNull];
                if (_asset == _strongholdSectorCheck) then {
                    [_strongholdSector] call WL2_fnc_removeStronghold;
                };
            };

            [_asset, _demolisher] remoteExec ["WL2_fnc_killRewardHandle", 2];
            private _explosion = createVehicle ["M_Air_AA", getPosASL _charge, [], 0, "FLY"];
            _explosion setPosASL getPosASL _charge;
            hideObject _explosion;
            triggerAmmo _charge;
            sleep 0.5;
            // don't call FF script, this prevents runway griefing
            _asset setDamage 1;
        };
        deleteVehicle _charge;
        deleteVehicle _dummyTarget;
        deleteVehicle _lightPoint;
        sleep 2;
        deleteVehicle _asset;
        playSound3D ["a3\sounds_f\sfx\special_sfx\building_destroy_01.wss", objNull, false, _lightPos, 2, 1, 200, 0, true];
    } else {
        _sleepTime = (_timeRemaining / WL_DEMOLISH_TIME) max 0.1;
    };

    sleep _sleepTime;
};

deleteVehicle _charge;
deleteVehicle _dummyTarget;
deleteVehicle _lightPoint;