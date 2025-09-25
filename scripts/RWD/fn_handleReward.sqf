#include "includes.inc"
params ["_rewardType", "_unitType", "_reward"];

_rewardType = toUpper _rewardType;
if (_rewardType select [0, 10] == "DESTROYED ") then {
	_rewardType = "DESTROYED";
};

private _rewardStack = missionNamespace getVariable ["WL2_rewardStack", createHashMap];
private _assetType = cameraOn getVariable ["WL2_orderedClass", typeOf cameraOn];

private _getVehicleType = {
	params ["_assetType"];
	if (_assetType isKindOf "Man") exitWith { "INFANTRY" };

	private _category = WL_ASSET(_assetType, "category", "Other");
	switch (_category) do {
		case "AirDefense": { "SAM"; };
		case "FixedWing": { "PLANE"; };
		case "HeavyVehicles": { "HEAVY"; };
		case "Infantry": { "INFANTRY"; };
		case "LightVehicles": { "LIGHT"; };
		case "Naval": { "NAVAL"; };
		case "RemoteControl": { "UAV"; };
		case "RotaryWing": { "HELO"; };
		case "SectorDefense": { "STATIC"; };
		case "Structures": { "STRUCTURE"; };
		default { "UNKNOWN"; };
	};
};

private _killerType = [_assetType] call _getVehicleType;
private _killedType = [_unitType] call _getVehicleType;

if (_rewardType == "KILL") then {
	private _currentKills = _rewardStack getOrDefault ["KILLS", 0];
	_rewardStack set ["KILLS", _currentKills + 1];

	private _currentTypeKills = _rewardStack getOrDefault [_killerType + " KILLS", 0];
	_rewardStack set [_killerType + " KILLS", _currentTypeKills + 1];
};

if (_rewardType == "DESTROYED") then {
	private _currentDestroyed = _rewardStack getOrDefault ["VEHICLE DESTROYED", 0];
	_rewardStack set ["VEHICLE DESTROYED", _currentDestroyed + 1];

	private _currentTypeDestroyed = _rewardStack getOrDefault [_killedType + " DESTROYED", 0];
	_rewardStack set [_killedType + " DESTROYED", _currentTypeDestroyed + 1];

	if (_killerType == "PLANE" && _killedType == "PLANE") then {
		private _currentPlaneVPlane = _rewardStack getOrDefault ["PLANE KILL PLANE", 0];
		_rewardStack set ["PLANE KILL PLANE", _currentPlaneVPlane + 1];
	};

	if (_killerType == "HELO" && _killedType == "PLANE") then {
		private _currentHeloVPlane = _rewardStack getOrDefault ["HELO KILL PLANE", 0];
		_rewardStack set ["HELO KILL PLANE", _currentHeloVPlane + 1];
	};

	if (_killerType == "LIGHT" && _killedType == "HEAVY") then {
		private _currentLightVHeavy = _rewardStack getOrDefault ["LIGHT KILL HEAVY", 0];
		_rewardStack set ["LIGHT KILL HEAVY", _currentLightVHeavy + 1];
	};

	if (_killerType == "HEAVY" && _killedType == "HEAVY") then {
		private _currentHeavyVHeavy = _rewardStack getOrDefault ["HEAVY KILL HEAVY", 0];
		_rewardStack set ["HEAVY KILL HEAVY", _currentHeavyVHeavy + 1];
	};

	if (_killerType == "NAVAL" && _killedType in ["LIGHT", "HEAVY"]) then {
		private _currentNavalVGround = _rewardStack getOrDefault ["NAVAL KILL GROUND", 0];
		_rewardStack set ["NAVAL KILL GROUND", _currentNavalVGround + 1];
	};
};

if (_rewardType == "ATTACKING SECTOR") then {
	private _currentAttacking = _rewardStack getOrDefault ["ATTACKING SECTOR", 0];
	_rewardStack set ["ATTACKING SECTOR", _currentAttacking + 1];
};

if (_rewardType == "DEFENDING SECTOR") then {
	private _currentDefending = _rewardStack getOrDefault ["DEFENDING SECTOR", 0];
	_rewardStack set ["DEFENDING SECTOR", _currentDefending + 1];
};

if (_rewardType in ["ACTIVE PROTECTION SYSTEM", "DAZZLER", "PROJECTILE JAMMED"]) then {
	private _currentProjectileKilled = _rewardStack getOrDefault ["PROJECTILE KILLED", 0];
	_rewardStack set ["PROJECTILE KILLED", _currentProjectileKilled + 1];
};

if (_rewardType == "REVIVED TEAMMATE") then {
	private _currentRevived = _rewardStack getOrDefault ["REVIVED", 0];
	_rewardStack set ["REVIVED", _currentRevived + 1];
};

if (_rewardType == "SPOT ASSIST") then {
	private _currentRecon = _rewardStack getOrDefault ["RECON", 0];
	_rewardStack set ["RECON", _currentRecon + 1];
};

if (_rewardType == "RECON") then {
	private _rewardAmount = (floor (_reward / 100)) max 1;
	private _currentRecon = _rewardStack getOrDefault ["RECON", 0];
	_rewardStack set ["RECON", _currentRecon + _rewardAmount];
};

missionNamespace setVariable ["WL2_rewardStack", _rewardStack];

call RWD_fnc_handleBadge;