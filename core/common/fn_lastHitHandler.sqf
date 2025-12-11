#include "includes.inc"
params ["_asset"];

_asset addEventHandler ["Hit", {
	params ["_unit", "_source", "_damage", "_instigator"];

	private _responsiblePlayer = [_source, _instigator] call WL2_fnc_handleInstigator;
	private _ownerSide = [_unit] call WL2_fnc_getAssetSide;
	private _responsibleSide = side group _responsiblePlayer;

	if (_ownerSide == _responsibleSide) exitWith {};
	if (!alive _unit || !isDamageAllowed _unit) exitWith {};
	if (isNull _responsiblePlayer) exitWith {};
	if !(isPlayer [_responsiblePlayer]) exitWith {};

	// only check if vehicle is driven
	if (!canMove _unit && alive driver _unit) then {
		private _wasImmobilized = _unit getVariable ["WL2_immobilized", false];
		if (!_wasImmobilized) then {
			[] remoteExec ["WL2_fnc_vehicleImmobilized", _responsiblePlayer];
			_unit setVariable ["WL2_immobilized", true, true];
		};
	};

	_unit setVariable ["WL_lastHitter", _responsiblePlayer, 2];

	private _children = _unit getVariable ["WL2_children", []];
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
	} forEach _children;

	private _crew = crew _unit;
	if (count _crew == 0) exitWith {};

	if (count _crew == 1 && _crew # 0 == _unit) exitWith {};
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
	} forEach _crew;
}];

if (isPlayer _asset) exitWith {};

_asset addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
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

	if (_projectile == "FuelExplosion") then {
		private _unitApsType = _unit call APS_fnc_getMaxAmmo;
		private _sourceApsType = _source call APS_fnc_getMaxAmmo;
		if (_unitApsType > _sourceApsType) then {
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