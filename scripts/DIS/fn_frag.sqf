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
	uiSleep 0.1;

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
private _targetPosition = getPosASL _targetDetected;
private _detonationPoint = vectorLinearConversion [0, 1, 0.75, _projectilePosition, _targetPosition];

private _finalDistance = _targetPosition distance _detonationPoint;
systemChat format ["SAM detonation %1M away from target.", round _finalDistance];

// Burst Explosion
_projectile setPosASL _detonationPoint;
triggerAmmo _projectile;