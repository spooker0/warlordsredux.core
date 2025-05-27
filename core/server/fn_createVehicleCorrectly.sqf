params ["_class", "_orderedClass", "_pos", "_direction", "_exactPosition"];
_pos params ["_posX", "_posY", "_posZ"];

if !(isServer) exitWith {};

_asset = createVehicle [_class, [_posX, _posY, _posZ - 50], [], 0, "CAN_COLLIDE"];
_asset setVectorDirAndUp _direction;

private _isInCarrierSector = count (BIS_WL_allSectors select {
	_pos inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
}) > 0;
if (_isInCarrierSector) then {
	_asset setVehiclePosition [[_posX, _posY, 50], [], 0, "CAN_COLLIDE"];
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