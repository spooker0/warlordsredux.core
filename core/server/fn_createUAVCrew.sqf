#include "includes.inc"
params ["_pos", "_class", "_orderedClass", "_direction", "_exactPosition", "_sender"];

private _turrets = [_class, configNull] call BIS_fnc_getTurrets;
private _autoTurrets = _turrets select {
	getNumber (_x >> "hasDriver") > 0 || getNumber (_x >> "hasGunner") > 0
} select {
	getNumber (_x >> "dontCreateAI") == 0
};
private _crewCount = count _autoTurrets;
// private _decoy = WL_ASSET(_orderedClass, "decoy", 0);
// if (_decoy > 0) then {
// 	_crewCount = 0;
// };

_asset = [_class, _orderedClass, _pos, _direction, _exactPosition, false] call WL2_fnc_createVehicleCorrectly;

private _side = if (isNull _sender) then {
	independent;
} else {
	side group _sender;
};
private _assetGrp = createGroup _side;

private _aiUnit = switch (_side) do {
	case west: {
		"B_UAV_AI"
	};
	case east: {
		"O_UAV_AI"
	};
	case independent: {
		"I_UAV_AI"
	};
};

for "_i" from 1 to _crewCount do {
	private _unit = _assetGrp createUnit [_aiUnit, _pos, [], 0, "NONE"];
	_unit moveInAny _asset;
	if (!isNull _sender) then {
		_unit setSkill 1;
		_unit setVariable ["BIS_WL_ownerAsset", getPlayerUID _sender, true];
	};
};
_assetGrp deleteGroupWhenEmpty true;

_asset;