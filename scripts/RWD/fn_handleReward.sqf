#include "includes.inc"
params ["_rewardType", "_unitType", "_reward"];

_rewardType = toUpper _rewardType;
if (_rewardType select [0, 10] == "DESTROYED ") then {
	if (_rewardType == "DESTROYED STRONGHOLD") then {
		_rewardType = "DESTROYED STRONGHOLD";
	} else {
		_rewardType = "DESTROYED";
	};
};

private _rewardStack = missionNamespace getVariable ["WL2_rewardStack", createHashMap];
private _assetActualType = WL_ASSET_TYPE(cameraOn);

private _getVehicleType = {
	params ["_assetType"];
	if (_assetType isKindOf "Man") exitWith { "INFANTRY" };

	private _category = WL_ASSET(_assetType, "category", "Other");
	switch (_category) do {
		case "Air Defense": { "SAM"; };
		case "Fixed Wing": { "PLANE"; };
		case "Heavy Vehicles": { "HEAVY"; };
		case "Infantry": { "INFANTRY"; };
		case "Light Vehicles": { "LIGHT"; };
		case "Naval": { "NAVAL"; };
		case "Remote Control": { "UAV"; };
		case "Rotary Wing": { "HELO"; };
		case "Sector Defense": { "STATIC"; };
		case "Structures": { "STRUCTURE"; };
		default { "UNKNOWN"; };
	};
};

private _killerType = [_assetActualType] call _getVehicleType;
private _killedType = [_unitType] call _getVehicleType;

if (_rewardType in ["KILL", "PLAYER KILL"]) then {
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

	if (_killerType == "INFANTRY" && _killedType == "HEAVY") then {
		private _currentInfantryVHeavy = _rewardStack getOrDefault ["INFANTRY KILL HEAVY", 0];
		_rewardStack set ["INFANTRY KILL HEAVY", _currentInfantryVHeavy + 1];
	};

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

	if (_killerType == "SAM" && _killedType == "PLANE") then {
		private _currentSAMVPlane = _rewardStack getOrDefault ["SAM KILL PLANE", 0];
		_rewardStack set ["SAM KILL PLANE", _currentSAMVPlane + 1];
	};

	if (_killerType == "STATIC" && _killedType == "HEAVY") then {
		private _currentStaticVHeavy = _rewardStack getOrDefault ["STATIC KILL HEAVY", 0];
		_rewardStack set ["STATIC KILL HEAVY", _currentStaticVHeavy + 1];
	};
};

if (_rewardType == "DESTROYED STRONGHOLD") then {
	private _currentStrongholds = _rewardStack getOrDefault ["STRONGHOLDS DESTROYED", 0];
	_rewardStack set ["STRONGHOLDS DESTROYED", _currentStrongholds + 1];
};

if (_rewardType == "ATTACKING SECTOR") then {
	private _currentAttacking = _rewardStack getOrDefault ["ATTACKING SECTOR", 0];
	_rewardStack set ["ATTACKING SECTOR", _currentAttacking + 1];
};

if (_rewardType == "DEFENDING SECTOR") then {
	private _currentDefending = _rewardStack getOrDefault ["DEFENDING SECTOR", 0];
	_rewardStack set ["DEFENDING SECTOR", _currentDefending + 1];
};

if (_rewardType == "ACTIVE PROTECTION SYSTEM") then {
	private _rewardAmount = (floor (_reward / 50)) max 1;
	private _currentAPS = _rewardStack getOrDefault ["ACTIVE PROTECTION SYSTEM", 0];
	_rewardStack set ["ACTIVE PROTECTION SYSTEM", _currentAPS + 1];
};

if (_rewardType == "DAZZLER") then {
	private _rewardAmount = (floor (_reward / 10)) max 1;
	private _currentDazzler = _rewardStack getOrDefault ["DAZZLER", 0];
	_rewardStack set ["DAZZLER", _currentDazzler + 1];
};

if (_rewardType == "PROJECTILE JAMMED") then {
	private _currentProjectileJammed = _rewardStack getOrDefault ["PROJECTILE JAMMED", 0];
	_rewardStack set ["PROJECTILE JAMMED", _currentProjectileJammed + 1];
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

if (_rewardType == "DEMOLITION") then {
	private _rewardAmount = (floor (_reward / 20)) max 1;
	private _currentDemolitions = _rewardStack getOrDefault ["DEMOLITIONS", 0];
	_rewardStack set ["DEMOLITIONS", _currentDemolitions + _rewardAmount];
};

if (_rewardType == "VEHICLE DISABLED") then {
	private _currentImmobilizations = _rewardStack getOrDefault ["IMMOBILIZATIONS", 0];
	_rewardStack set ["IMMOBILIZATIONS", _currentImmobilizations + 1];
};

missionNamespace setVariable ["WL2_rewardStack", _rewardStack];

call RWD_fnc_handleBadge;