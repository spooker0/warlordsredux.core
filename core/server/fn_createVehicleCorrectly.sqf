#include "includes.inc"
params ["_class", "_orderedClass", "_pos", "_direction", "_exactPosition"];
_pos params ["_posX", "_posY", "_posZ"];

if !(isServer) exitWith {};

_asset = createVehicle [_class, [_posX, _posY, _posZ - 50], [], 0, "CAN_COLLIDE"];
if (_direction isEqualType 0) then {
	_asset setDir _direction;
} else {
	_asset setVectorDirAndUp _direction;
};

private _assetMass = WL_ASSET(_orderedClass, "mass", 0);
if (_assetMass > 0) then {
	_asset setVariable ["WL2_massDefault", _assetMass, true];
	_asset setMass _assetMass;
};

private _isInWaterSector = count (BIS_WL_allSectors select {
	_pos inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
}) > 0 || {
	{
		_pos inArea _x
	} count WL_DESTROYER_OUTLINES > 0
};
if (_isInWaterSector) then {
	_asset setVehiclePosition [_pos, [], 0, "CAN_COLLIDE"];
} else {
	_asset setVehiclePosition [[_posX, _posY, 0], [], 0, "CAN_COLLIDE"];
};

if (_exactPosition) then {
	_asset setVectorDirAndUp _direction;
	_asset setPosWorld _pos;
};

_asset setDamage 0;
_asset lock true;
_asset enableWeaponDisassembly false;

uiSleep 0.5;
_asset;