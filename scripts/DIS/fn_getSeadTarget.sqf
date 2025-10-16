#include "includes.inc"
params ["_asset"];
private _seadTargets = [];

private _advancedThreat = _asset getVariable ["WL2_advancedThreat", objNull];
if (alive _advancedThreat) then {
    private _name = format ["LOCKED: %1", [_advancedThreat] call WL2_fnc_getAssetTypeName];
    _seadTargets pushBack [_advancedThreat, _name];
};

private _extendedSamLauncher = _asset getVariable ["WL_incomingExtendedSam", objNull];
if (alive _extendedSamLauncher) then {
    private _name = format ["LOCKED: %1", [_extendedSamLauncher] call WL2_fnc_getAssetTypeName];
    _seadTargets pushBack [_extendedSamLauncher, _name];
};

private _launcher = _asset getVariable ["WL_incomingLauncherLastKnown", objNull];
if (alive _launcher) then {
    private _name = format ["LAUNCH: %1", [_launcher] call WL2_fnc_getAssetTypeName];
    _seadTargets pushBack [_launcher, _name];
};

{
    _x params ["_threat", "_type", "_sensors"];
    if (_type in ["locked", "marked"] && "radar" in _sensors) then {
        private _locker = vehicle _threat;
        private _name = format ["LOCKING: %1", [_locker] call WL2_fnc_getAssetTypeName];
        _seadTargets pushBack [_locker, _name];
    };
} forEach (getSensorThreats _asset);

{
    _x params ["_target", "_type", "_relationship", "_detectionSource"];
    if (_relationship == "friendly") then {
        continue;
    };
    if ("passiveradar" in _detectionSource) then {
        private _name = format ["EMITTER: %1", [_target] call WL2_fnc_getAssetTypeName];
        _seadTargets pushBack [_target, _name];
    };
} forEach (getSensorTargets _asset);

private _side = [_asset] call WL2_fnc_getAssetSide;
{
    _x params ["_target", "_lastDetected"];
    if (_lastDetected < 0) then {
        continue;
    };
    if (!alive _target) then {
        continue;
    };
    private _targetSide = [_target] call WL2_fnc_getAssetSide;
    if (_targetSide == _side) then {
        continue;
    };
    private _isDazzler = _target getVariable ["apsType", -1] == 3;
    if (_isDazzler && _target getVariable ["WL2_apsActivated", false]) then {
        private _name = format ["EMITTER: %1", [_target] call WL2_fnc_getAssetTypeName];
        _seadTargets pushBack [_target, _name];
    };
} forEach (listRemoteTargets _side);

_seadTargets;