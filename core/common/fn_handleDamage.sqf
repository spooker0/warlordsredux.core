#include "includes.inc"
params ["_asset"];

_asset addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
	[_unit, _source, _instigator] call WL2_fnc_lastHitHandler;

	if (isPlayer [_unit]) exitWith {};

	if (cameraOn == _unit && _projectile != "" && _context == 2) then {
		private _existingProjectiles = uiNamespace getVariable ["WL2_damagedProjectiles", createHashMap];
		_existingProjectiles set [diag_tickTime, _projectile];
		uiNamespace setVariable ["WL2_damagedProjectiles", _existingProjectiles];
		uiNamespace setVariable ["WL2_damageSource", _source];
		uiNamespace setVariable ["WL2_damagedWeapon", currentWeapon _source];
	};

	if (_selection == "") then {
		if (_projectile == "ammo_Bomb_SDB") then {
			_damage = 1;
		};
	};

	if (_unit isKindOf "Man" && side group _unit != independent) then {
		_damage = _this call WL2_fnc_handleAIDamage;
	};

	if (_projectile isKindOf "FuelExplosion") then {
		private _unitApsType = _unit call APS_fnc_getMaxAmmo;
		if (_unitApsType > 0) then {
			_damage = _unit getHit _selection;
		};
	};

	if (_projectile isKindOf "MineCore" || _projectile isKindOf "TimeBombCore") then {
		private _instigator = [_source, _instigator] call WL2_fnc_handleInstigator;
		if (side group _instigator == side group _unit) then {
			_damage = _unit getHit _selection;
		};
	};

	_damage;
}];