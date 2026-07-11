#include "includes.inc"
params ["_projectile", "_unit", "_damage", ["_rangeOverride", -1]];

private _responsiblePlayer = [_unit, _unit] call WL2_fnc_handleInstigator;
private _projectileConfig = configfile >> "CfgAmmo" >> typeOf _projectile;
private _range = getNumber (_projectileConfig >> "indirectHitRange");
private _proxRange = _range * 2.5;

if (_rangeOverride > -1) then {
	_proxRange = _rangeOverride;
} else {
	uiSleep 0.5;
};

private _objectsNearby = [];
private _playerSide = side group _unit;
while { alive _projectile } do {
	uiSleep 0.01;

	private _enemyUnits = switch (_playerSide) do {
        case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
        default { [] };
    };
	_objectsNearby = _enemyUnits select {
		_x isKindOf "Air"
	} select {
		_x distance _projectile < _proxRange
	} select {
		alive _x
	};

	if (count _objectsNearby > 0) then {
		break;
	};
};

if (count _objectsNearby == 0) exitWith {};

if (!isNull _responsiblePlayer) then {
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
		{
			_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
		} forEach (crew _x);
	} forEach _objectsNearby;
};

private _targetDetected = _objectsNearby # 0;
deleteVehicle _projectile;

// Explosion damage handler
if (isDedicated) then {
	[_unit, _targetDetected, _damage, getPlayerUID _responsiblePlayer] call WL2_fnc_handleSamHit;
} else {
	[format ["Proximity detonation! Damage to target: %1%%", round (_damage * 100)]] call WL2_fnc_smoothText;
	[player, "samHit", _unit, _targetDetected, _damage] remoteExec ["WL2_fnc_handleClientRequest", 2];
};