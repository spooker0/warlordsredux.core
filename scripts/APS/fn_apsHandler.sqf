#include "includes.inc"
params ["_projectile", "_unit"];

private _firedPosition = _projectile modelToWorld [0, 0, 0];
private _minDistSqr = APS_MIN_DISTANCE_SQR;
private _maxDistSqr = APS_MAX_DISTANCE_SQR;

private _apsProjectileType = _projectile getVariable ["APS_ammoOverride", typeOf _projectile];
private _apsProjectileConfig = APS_projectileConfig getOrDefault [_apsProjectileType, createHashMap];
private _projectileAPSTypes = _apsProjectileConfig getOrDefault ["aps", []];

private _projectileAPSTypeMap = createHashMap;
{
    _projectileAPSTypeMap set [_x, true];
} forEach _projectileAPSTypes;

private _projectileAPSConsumption = _apsProjectileConfig getOrDefault ["consumption", 1];

private _radius = sqrt _maxDistSqr;
private _maxSpeed = getNumber (configFile >> "CfgAmmo" >> typeof _projectile >> "maxSpeed");
private _maxAllowedDisplacement = _radius / 4 * 3;
private _previousPos = getPosWorld _projectile;
private _safeMaxDistSqr = _maxDistSqr;

private _unitSide = side group _unit;

private _interception = {
	params ["_target"];

	private _overrideAmmoConsumption = _projectile getVariable ["APS_ammoConsumptionOverride", -1];
	if (_overrideAmmoConsumption != -1) then {
		_projectileAPSConsumption = _overrideAmmoConsumption;
	};

	private _apsAmmo = _target getVariable "apsAmmo";
	_target setVariable ["apsAmmo", (_apsAmmo - _projectileAPSConsumption) max 0, true];

	private _projectilePosition = _projectile modelToWorld [0, 0, 0];
	private _projectileDirection = _firedPosition getDir _target;
	private _relativeDirection = if (isNull _target) then {
		0;
	} else {
		[_projectileDirection, _target] call APS_fnc_relDir2;
	};

	_projectile setPosWorld [0, 0, 0];
	deleteVehicle _projectile;

	private _projectileRelDir = _target getRelDir _firedPosition;
	private _explosionPosition = _target getRelPos [(sqrt _maxDistSqr) / 2, _projectileRelDir];
	private _explosionHeight = (_projectilePosition # 2) min (sqrt _maxDistSqr);
	_explosionPosition set [2, _explosionHeight];
	[_explosionPosition, [
		["ImpactSparksSabot1", 0.1],
		["ImpactSparksSabot1", 0.1],
		["ImpactSparksSabot1", 0.1],
		["ImpactSparksSabot1", 0.1],
		["ImpactSparksSabot1", 0.1],
		["SecondaryExp", 0.5],
		["SecondarySmoke", 1]
	]] remoteExec ["WL2_fnc_particleEffect", 0];

	private _apsSounds = [
		"a3\sounds_f\arsenal\explosives\grenades\explosion_mini_grenade_01.wss",
		"a3\sounds_f\arsenal\explosives\grenades\explosion_mini_grenade_02.wss",
		"a3\sounds_f\arsenal\explosives\grenades\explosion_mini_grenade_03.wss",
		"a3\sounds_f\arsenal\explosives\grenades\explosion_mini_grenade_04.wss"
	];
	playSound3D [selectRandom _apsSounds, objNull, false, AGLtoASL _explosionPosition];

	[_target, _relativeDirection, true, _apsProjectileType, _unit] remoteExec ["APS_fnc_report", _target];

	private _ownerSide = _target getVariable ["BIS_WL_ownerAssetSide", sideUnknown];
	if (_unitSide == _ownerSide) then {
		[name player] remoteExec ["APS_fnc_friendlyWarning", _target];
		0 spawn {
			uiSleep 0.5;

			playSoundUI ["alarm", 2];
			hint localize "STR_WL_apsFriendlyWarning";
		};
	} else {
		private _actualAmmoUsed = _apsAmmo min _projectileAPSConsumption;
		[_unit, _actualAmmoUsed, _target] remoteExec ["APS_fnc_serverHandleAPS", 2];
	};
};

while { alive _projectile } do {
	if (_projectile getVariable ["WL2_jamDestroy", false]) then {
		deleteVehicle _projectile;
	};

    if (count _projectileAPSTypes == 0) then {
        uiSleep 0.001;
        continue;
    };

	private _currentPos = getPosWorld _projectile;
	private _displacement = _currentPos distance _previousPos;
	if (_displacement > _maxAllowedDisplacement) then {
		_safeMaxDistSqr = _maxSpeed * _maxSpeed;
		_maxAllowedDisplacement = _maxSpeed;
	};
	_previousPos = _currentPos;

	private _safeRadius = _radius max (sqrt _safeMaxDistSqr);

	private _eligibleNearbyVehicles = (_projectile nearEntities [["LandVehicle"], _safeRadius]) select {
		_x != _unit
    } select {  // active check
		[_x] call APS_fnc_active;
	} select {  // close radius check
		private _ownerSide = _x getVariable ["BIS_WL_ownerAssetSide", sideUnknown];
		private _isNotFriendly = _unitSide != _ownerSide;
        (_projectile distanceSqr _x) < _maxDistSqr || _isNotFriendly
	} select {  // aps type check
        private _vehicleAPSType = _x getVariable ["APS_apsType", 0];
        _vehicleAPSType in _projectileAPSTypeMap
    } select {  // deadzone check
        _firedPosition distanceSqr _x > _minDistSqr;
    } select {  // far radius check
        _x distanceSqr _projectile < _safeMaxDistSqr;
    } select {  // incoming angle check
        private _projectileVector = vectorNormalized (velocity _projectile);
        private _vectorToVehicle = (getPosASL _projectile) vectorFromTo (getPosASL _x);
        private _incomingAngle = acos (_projectileVector vectorDotProduct _vectorToVehicle);
        _incomingAngle < 30;
    };

	private _sortedEligibleList = [_eligibleNearbyVehicles, [_projectile], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    if (!alive _projectile) then {
        break;
    };
    if (count _sortedEligibleList > 0) then {
        private _closestVehicle = _sortedEligibleList # 0;
        [_closestVehicle] call _interception;
        break;
    };

	uiSleep 0.001;
};