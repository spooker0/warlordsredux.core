#include "..\warlords_constants.inc"

private _vehicles = (nearestObjects [player, [], 20, true]) select {
    alive _x;
} select {
    (_x getVariable ["WL2_accessControl", -2]) != -2;
} select {
    !(_x getVariable ["WL2_transporting", false]);
} select {
    !(_x isKindOf "Man");
} select {
    private _access = [_x, player, "driver"] call WL2_fnc_accessControl;
    _access # 0;
};

if (count _vehicles == 0) exitWith {};
private _vehicle = _vehicles # 0;

private _class = typeOf _vehicle;
private _orderedClass = _vehicle getVariable ["WL2_orderedClass", _class];
private _offset = player worldToModel (getPosATL _vehicle);

private _deploymentResult = [_class, _orderedClass, _offset, 30, true] call WL2_fnc_deployment;

if (_deploymentResult # 0) then {
    private _position =  _deploymentResult # 1;
    private _direction = _deploymentResult # 3;
    private _uid = getPlayerUID player;

    _vehicle enableSimulation false;
    private _nearbyEntities = [_class, _position, _direction, _uid, []] call WL2_fnc_grieferCheck;
    _vehicle enableSimulation true;

    if (count _nearbyEntities > 0) then {
        private _nearbyObject = _nearbyEntities # 0;
        private _nearbyObjectName = [_nearbyObject] call WL2_fnc_getAssetTypeName;
        private _nearbyObjectPosition = getPosASL _nearbyObject;
        playSound3D ["a3\3den\data\sound\cfgsound\notificationwarning.wss", objNull, false, _nearbyObjectPosition, 5];
        systemChat format ["Too close to another %1!", _nearbyObjectName];
    } else {
        playSound "assemble_target";
        [player, "resetVehicle", _vehicle, _position, _direction] remoteExec ["WL2_fnc_handleClientRequest", 2];

        ["TaskResetVehicle"] call WLT_fnc_taskComplete;
    };
} else {
    playSound "AddItemFailed";
};