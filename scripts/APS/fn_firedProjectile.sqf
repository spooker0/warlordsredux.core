params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

private _firedPosition = getPosATL _gunner;
private _minDistSqr = getMissionConfigValue ["BIS_WL_minAPSDist", 400];
private _maxDistSqr = getMissionConfigValue ["BIS_WL_maxAPSDist", 1600];

private _apsProjectileType = _projectile getVariable ["APS_ammoOverride", typeOf _projectile];
private _apsProjectileConfig = APS_projectileConfig getOrDefault [_apsProjectileType, createHashMap];
private _projectileAPSType = _apsProjectileConfig getOrDefault ["aps", 10];
private _projectileAPSConsumption = _apsProjectileConfig getOrDefault ["consumption", 1];
private _dazzleable = _apsProjectileConfig getOrDefault ["dazzleable", false];
private _isGuided = _projectileAPSType < 3;		// if stoppable by APS, always dazzleable by dazzler

private _radius = if (_dazzleable) then {125} else {sqrt _maxDistSqr};

private _maxSpeed = getNumber (configFile >> "CfgAmmo" >> typeof _projectile >> "maxSpeed");
private _maxAllowedDisplacement = (sqrt _maxDistSqr) / 4 * 3;
private _previousPos = getPosWorld _projectile;
private _safeMaxDistSqr = _maxDistSqr;

private _unitSide = side group _unit;

private _interception = {
	params ["_target", "_dazzled"];
	private _projectilePosition = getPosATL _projectile;
	private _projectileDirection = _firedPosition getDir _target;
	private _relativeDirection = if (isNull _target) then {
		0;
	} else {
		[_projectileDirection, _target] call APS_fnc_relDir2;
	};

	_projectile setPosWorld [0, 0, 0];
	deleteVehicle _projectile;

	private _projectileRelDir = _target getRelDir _firedPosition;
	private _explosionPosition = _target getRelPos [sqrt _maxDistSqr, _projectileRelDir];
	private _explosionHeight = (_projectilePosition # 2) min (sqrt _maxDistSqr);
	_explosionPosition set [2, _explosionHeight];
	createVehicle ["SmallSecondary", _explosionPosition, [], 0, "FLY"];

	[_target, _relativeDirection, true, _gunner] remoteExec ["APS_fnc_report", _target];

	private _ownerSide = _x getVariable ["BIS_WL_ownerAssetSide", sideUnknown];
	if (side group _unit == _ownerSide) then {
		0 spawn {
			sleep 0.5;

			playSoundUI ["alarm", 2];
			hint localize "STR_A3_WL_aps_friendly_warning";
		};
	} else {
		[_gunner, _dazzled] remoteExec ["APS_fnc_serverHandleAPS", 2];
	};
};

private _smokeScriptReady = true;

private _continue = alive _projectile;
while {_continue && alive _projectile} do {
	private _currentPos = getPosWorld _projectile;
	private _displacement = _currentPos distance _previousPos;
	if (_displacement > _maxAllowedDisplacement) then {
		_safeMaxDistSqr = _maxSpeed * _maxSpeed;
		_maxAllowedDisplacement = _maxSpeed;
	};
	_previousPos = _currentPos;

	private _safeRadius = _radius max (sqrt _safeMaxDistSqr);

	private _eligibleNearbyVehicles = (_projectile nearEntities [["LandVehicle"], _safeRadius]) select {
		_x != _unit &&
		[_x] call APS_fnc_active;
	};

	_eligibleNearbyVehicles = _eligibleNearbyVehicles select {
		private _ownerSide = _x getVariable ["BIS_WL_ownerAssetSide", sideUnknown];
		private _isFriendly = _unitSide == _ownerSide;
		if (_isFriendly) then {	// if friendly, disable insurance measures
			(_projectile distanceSqr _x) < _maxDistSqr;
		} else {
			true;
		};
	};

	if (_dazzleable && _smokeScriptReady) then {
		private _missileTarget = missileTarget _projectile;
		if !(isNull _missileTarget) then {
			private _smokesNear = _missileTarget nearObjects ["SmokeShellVehicle", 50];
			private _numberSmokes = count _smokesNear;
			if (_numberSmokes > 0) then {
				// 1 smoke grenade = 50% hit chance
				// 2 smoke grenades = 25% hit chance
				// 8 smoke grenades = 6.25% hit chance
				// 16 smoke grenades = 3.125% hit chance
				private _misdirect = random _numberSmokes >= 0.5;
				if (_misdirect) then {
					_projectile setMissileTarget objNull;
				};
				_smokeScriptReady = false;
			};
		};
	};

	_sortedEligibleList = [_eligibleNearbyVehicles, [_projectile], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
	{
		if (!alive _projectile || !_continue) exitWith {
			_continue = false;
		};

		private _vehicleAPSType = _x getVariable ["apsType", -1];
		if (_vehicleAPSType == 3) then {
			if (!isNull (missileTarget _projectile)) then {
				_isGuided = true;
			};

			if (_dazzleable && _isGuided) exitWith {
				_continue = false;
				private _dazzlerFuel = fuel _x;
				[_x, _projectileAPSConsumption] remoteExec ["APS_fnc_dazzle", _x];
				[_x, true] call _interception;
			};
		} else {
			if (_vehicleAPSType >= _projectileAPSType && {
					private _distanceSqr =_x distanceSqr _projectile;
					private _firedFromDeadzone = _firedPosition distanceSqr _x < _minDistSqr;
					!_firedFromDeadzone && _distanceSqr < _safeMaxDistSqr;
				} && {
					private _projectileVector = vectorNormalized (velocity _projectile);
					private _vectorToVehicle = (getPosASL _projectile) vectorFromTo (getPosASL _x);
					private _incomingAngle = acos (_projectileVector vectorDotProduct _vectorToVehicle);
					_incomingAngle < 30;
				}) exitWith {
				_continue = false;

				private _ammo = _x getVariable "apsAmmo";
				_x setVariable ["apsAmmo", _ammo - _projectileAPSConsumption, true];

				[_x, false] call _interception;
			};
		};
	} forEach _sortedEligibleList;

	sleep 0.001;
};
