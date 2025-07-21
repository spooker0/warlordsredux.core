#include "includes.inc"
private _alreadyAdded = _this getVariable ["APS_fireEventHandlerAdded", false];
if (_alreadyAdded) exitWith {};
_this setVariable ["APS_fireEventHandlerAdded", true];

_this addEventHandler ["Fired", {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

	if !(local _projectile) exitWith { true };

	if (!(local _gunner) && !(isManualFire _unit)) exitWith { true };	// Disable and restrict for cwis

	if (_projectile isKindOf "Chemlight_base") exitWith {
		[_projectile] spawn WL2_fnc_placeRespawnBag;
	};

	private _assetActualType = _unit getVariable ["WL2_orderedClass", typeOf _unit];
	private _projectileAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
	_projectileAmmoOverrides = _projectileAmmoOverrides select {
		_x # 0 == _ammo
	};
	if (count _projectileAmmoOverrides > 0) then {
		private _projectileAmmoOverride = _projectileAmmoOverrides # 0;
		_projectile setVariable ["APS_ammoOverride", _projectileAmmoOverride # 1 # 0];
	};

	private _apsProjectileType = _projectile getVariable ["APS_ammoOverride", typeOf _projectile];
	if !(_apsProjectileType in APS_projectileConfig) exitWith { true };

	private _projectileConfig = APS_projectileConfig getOrDefault [_apsProjectileType, createHashMap];
	private _projectileTV = _projectileConfig getOrDefault ["tv", false];
	if (_projectileTV) then {
		private _projectileSpeed = _projectileConfig getOrDefault ["speed", 0];
		_projectileSpeed = _projectileSpeed + (speed _unit) / 3.6;
		_projectile setVariable ["APS_speedOverride", _projectileSpeed];
		[_projectile] spawn DIS_fnc_tvMunition;
	} else {
		private _projectileMissileCamera = _projectileConfig getOrDefault ["camera", false];
		if (_projectileMissileCamera) then {
			[_projectile, _unit] call DIS_fnc_startMissileCamera;
		};
	};
	private _projectileRemote = _projectileConfig getOrDefault ["remote", false];
	private _projectileBunker = _projectileConfig getOrDefault ["bunker", false];
	if (_projectileRemote) then {
		private _remoteController = _unit getVariable ["WL2_selectedPlayerTarget", objNull];
		if (alive _remoteController) then {
			[_projectile, _unit, _projectileBunker] remoteExec ["DIS_fnc_remoteMunition", _remoteController];
		};
	};

	private _projectileGPS = _projectileConfig getOrDefault ["gps", false];
	if (_projectileGPS) then {
		private _inRangeCalculation = [_unit] call DIS_fnc_calculateInRange;
		private _inRange = _inRangeCalculation # 0;
		if (_inRange) then {
			private _coordinates = _inRangeCalculation # 3;
			_projectile setVariable ["DIS_targetCoordinates", _coordinates];
			[_projectile, _unit] spawn DIS_fnc_gpsMunition;
		} else {
			systemChat "GPS target out of range.";
		};
	};

	private _projectileESam = _projectileConfig getOrDefault ["esam", false];
	if (_projectileESam) then {
		[_projectile, _unit] spawn DIS_fnc_extendedSam;
	};

	// private _projectileCRAM = _projectileConfig getOrDefault ["cram", false];
	// if (_projectileCRAM) then {
	// 	[_projectile, local _gunner] spawn APS_fnc_cram;
	// };

	_this spawn APS_fnc_firedProjectile;

	private _projectileAsam = _projectileConfig getOrDefault ["asam", false];
	if (_projectileAsam) then {
		[_projectile, _unit] spawn DIS_fnc_advancedSam;
	};

	if (_projectileBunker) then {
		_projectile addEventHandler ["Explode", {
			_this spawn DIS_fnc_bunkerBuster;
		}];
	};

	private _projectileSam = _projectileConfig getOrDefault ["sam", false];
	if (_projectileSam) then {
		[_projectile, _unit] spawn DIS_fnc_frag;
		[_projectile, _unit] spawn DIS_fnc_maneuver;
	};

	private _projectileSead = _projectileConfig getOrDefault ["sead", false];
	if (_projectileSead) then {
		[_projectile, _unit] spawn APS_fnc_sead;
	};

	private _projectileTerminal = _projectileConfig getOrDefault ["terminal", false];
	if (_projectileTerminal) then {
		[_projectile, _unit] spawn DIS_fnc_terminalGuidance;
	};
}];