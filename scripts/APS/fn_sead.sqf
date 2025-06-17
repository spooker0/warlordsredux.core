#include "includes.inc"
params ["_projectile", "_unit"];

if (isNull (missileTarget _projectile)) then {
    private _extendedSamLauncher = _unit getVariable ["WL_incomingExtendedSam", objNull];
    if (alive _extendedSamLauncher) exitWith {
        [_projectile, _extendedSamLauncher] call APS_fnc_setSeadTarget;
    };

    private _advancedThreat = _unit getVariable ["WL2_advancedThreat", objNull];
    if (alive _advancedThreat) exitWith {
        [_projectile, _advancedThreat] call APS_fnc_setSeadTarget;
    };

    // fire on launcher
    private _launcher = _unit getVariable ["WL_incomingLauncherLastKnown", objNull];
    if (alive _launcher) exitWith {
        if (_launcher isKindOf "Man") then {
            _projectile setMissileTarget [_launcher, true];

            [_projectile] spawn {
                params ["_projectile"];
                sleep 2;
                _projectile setMissileTarget objNull;
            };
        } else {
            [_projectile, _launcher] call APS_fnc_setSeadTarget;
        };
    };

    private _samTargets = [];
    // locking SAMs
    private _sensorThreats = getSensorThreats _unit;
    {
        _x params ["_threat", "_type", "_sensors"];
        private _isInAngle = [getPosATL _projectile, getDir _projectile, 120, getPosATL _threat] call WL2_fnc_inAngleCheck;
        if (_isInAngle && _type in ["locked", "marked"] && "radar" in _sensors) then {
            _samTargets pushBack (vehicle _threat);
        };
    } forEach _sensorThreats;
    if (count _samTargets > 0) exitWith {
        private _sortedSamTargets = [_samTargets, [], { _unit distance _x }, "ASCEND"] call BIS_fnc_sortBy;
        [_projectile, _sortedSamTargets # 0] call APS_fnc_setSeadTarget;
    };

    // radar on sensor
    private _allAssetTargets = getSensorTargets _unit;
    {
        _x params ["_target", "_type", "_relationship", "_detectionSource"];
        private _isInAngle = [getPosATL _projectile, getDir _projectile, 120, getPosATL _target] call WL2_fnc_inAngleCheck;
        if (_isInAngle && _type == "ground" && _relationship != "friendly" && "passiveradar" in _detectionSource) then {
            _samTargets pushBack (_x # 0);
        };
    } forEach _allAssetTargets;
    if (count _samTargets > 0) then {
        private _sortedSamTargets = [_samTargets, [], { _unit distance _x }, "ASCEND"] call BIS_fnc_sortBy;
        [_projectile, _sortedSamTargets # 0] call APS_fnc_setSeadTarget;
    };
};