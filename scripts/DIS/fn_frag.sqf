params ["_projectile", "_unit"];

private _target = objNull;
private _frag = false;
private _projectileClass = typeOf _projectile;
private _range = getNumber (configfile >> "CfgAmmo" >> _projectileClass >> "indirectHitRange");
private _proxRange = _range * 1.5;

sleep 0.5;
while { alive _projectile } do {
	sleep 0.001;

	private _objectsNearby = _projectile nearEntities ["Air", _proxRange];
	_objectsNearby = _objectsNearby select {
		[_x] call WL2_fnc_getAssetSide != side group _unit
	};
	if (count _objectsNearby > 0) then {
		break;
	};
};

// Vanilla explosion
private _projectilePosition = getPos _projectile;
triggerAmmo _projectile;

// Burst Explosion
private _burst = createVehicle [_projectileClass, _projectilePosition, [], 50, "FLY"];
triggerAmmo _burst;