#include "includes.inc"
params ["_class", "_orderedClass", "_pos", "_direction", "_exactPosition"];
_pos params ["_posX", "_posY", "_posZ"];

if !(isServer) exitWith {};

_asset = createVehicle [_class, [_posX, _posY, _posZ - 50], [], 0, "CAN_COLLIDE"];
_asset setVectorDirAndUp _direction;

private _isInWaterSector = count (BIS_WL_allSectors select {
	_pos inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
}) > 0 || {
	{
		_pos inArea _x
	} count ["marker_USS Liberty_outline", "marker_USS Freedom_outline", "marker_USS Independence_outline"] > 0
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

sleep 0.5;
_asset;