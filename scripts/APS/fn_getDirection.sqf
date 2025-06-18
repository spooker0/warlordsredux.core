#include "includes.inc"
params ["_vehicle"];
private _turrets = allTurrets [_vehicle, false];
private _direction = 0;

private _currentWeapon = currentWeapon _vehicle;
if (count _turrets > 0 && _currentWeapon != "") then {
	private _weaponDirection = _vehicle weaponDirection _currentWeapon;
	_direction = (_weaponDirection select 0) atan2 (_weaponDirection select 1);
} else {
	_direction = getDir _vehicle;
};
if (_direction < 0) then {
	_direction = (360 + _direction);
};
_direction;