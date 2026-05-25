#include "includes.inc"
params ["_asset", "_target", "_avoidable"];

private _targetPos = getPosASL _target;
private _distanceToTop = _targetPos # 1;
private _distanceToBottom = worldSize - _distanceToTop;
private _distanceToLeft = _targetPos # 0;
private _distanceToRight = worldSize - _distanceToLeft;

private _projectileAltitude = 15000;
private _projectilePos = if (_distanceToTop < _distanceToBottom) then {
    if (_distanceToLeft < _distanceToRight) then {
        if (_distanceToTop < _distanceToLeft) then {
            [_targetPos # 0, 0, _projectileAltitude]
        } else {
            [0, _targetPos # 1, _projectileAltitude]
        };
    } else {
        if (_distanceToTop < _distanceToRight) then {
            [_targetPos # 0, 0, _projectileAltitude]
        } else {
            [worldSize, _targetPos # 1, _projectileAltitude]
        };
    };
} else {
    if (_distanceToLeft < _distanceToRight) then {
        if (_distanceToBottom < _distanceToLeft) then {
            [_targetPos # 0, worldSize, _projectileAltitude]
        } else {
            [0, _targetPos # 1, _projectileAltitude]
        };
    } else {
        if (_distanceToBottom < _distanceToRight) then {
            [_targetPos # 0, worldSize, _projectileAltitude]
        } else {
            [worldSize, _targetPos # 1, _projectileAltitude]
        };
    };
};

private _projectile = createVehicle ["ammo_Missile_AMRAAM_D", _projectilePos, [], 0, "NONE"];
_projectile setVariable ["APS_ammoOverride", "ammo_Missile_CAP"];

private _targetOwner = if (typeof _target == "RuggedTerminal_01_communications_hub_F") then {
    _target getVariable ["WL2_forwardBaseOwner", independent];
} else {
    _target getVariable ["BIS_WL_owner", independent];
};
private _combatAirRequesterUid = _target getVariable ["WL2_combatAirRequester", "123"];
private _combatAirRequester = _combatAirRequesterUid call BIS_fnc_getUnitByUid;

private _missileName = if (_targetOwner == west) then {
    "AIM-260";
} else {
    "PL-15";
};
_projectile setVariable ["WL2_missileNameOverride", _missileName, true];
if (!isNull _combatAirRequester) then {
    [_projectile, [objNull, _combatAirRequester]] remoteExec ["setShotParents", 2];
};
[_asset, objNull, _projectile] call WL2_fnc_warnIncomingMissile;

while { alive _projectile && alive _asset } do {
    _projectile setMissileTarget [_asset, true];

    _projectile setVelocityModelSpace [0, 1800, 0];
    private _currentPosition = getPosASL _projectile;
    private _finalPosition = getPosASL _asset;

    private _assetVectorDirAndUp = [_currentPosition, _finalPosition] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _assetVectorDirAndUp;

    private _projectileAGL = _projectile modelToWorld [0, 0, 0];
    if (_projectileAGL # 2 < WL_COMBAT_AIR_MINALT && _avoidable) then {
        triggerAmmo _projectile;
        break;
    };

    if (_asset distance _projectile < 100) then {
        private _detonationPoint = getPosASL _asset;
        _detonationPoint set [2, _detonationPoint # 2 + 22];
        _projectile setPosASL _detonationPoint;
        triggerAmmo _projectile;
        break;
    };

    uiSleep 0.01;
};

uiSleep 3;
deleteVehicle _projectile;