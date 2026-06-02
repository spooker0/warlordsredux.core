#include "includes.inc"
params ["_projectile", "_unit"];

private _target = objNull;
private _frag = false;
private _projectileClass = typeOf _projectile;
private _range = getNumber (configfile >> "CfgAmmo" >> _projectileClass >> "indirectHitRange");
private _proxRange = _range * 2.5;

private _objectsNearby = [];
uiSleep 0.5;
while { alive _projectile } do {
	uiSleep 0.01;

	_objectsNearby = _projectile nearEntities ["Air", _proxRange];
	_objectsNearby = _objectsNearby select {
		[_x] call WL2_fnc_getAssetSide != side group _unit
	};
	if (count _objectsNearby > 0) then {
		break;
	};
};

// Vanilla explosion
private _projectilePosition = getPosASL _projectile;

if (count _objectsNearby == 0) exitWith {
	triggerAmmo _projectile;
};

private _responsiblePlayer = [_unit, _unit] call WL2_fnc_handleInstigator;
if (!isNull _responsiblePlayer) then {
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
		{
			_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
		} forEach (crew _x);
	} forEach _objectsNearby;
};

private _targetDetected = _objectsNearby # 0;
private _baseDamage = getNumber (configfile >> "CfgAmmo" >> _projectileClass >> "hit");
private _indirectDamage = getNumber (configfile >> "CfgAmmo" >> _projectileClass >> "indirectHit");
private _damage = if (_baseDamage > 300 || _indirectDamage >= 125) then {
	1
} else {
	private _projectileSpeed = vectorMagnitude (velocity _projectile);
	linearConversion [100, 2000, _projectileSpeed, 0.1, 1, true];
};

deleteVehicle _projectile;

// Explosion damage handler
[format ["SAM detonation! Damage to target: %1%%", round (_damage * 100)]] call WL2_fnc_smoothText;
[player, "samHit", _unit, _targetDetected, _damage, _projectilePosition] remoteExec ["WL2_fnc_handleClientRequest", 2];