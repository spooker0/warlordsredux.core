#include "includes.inc"
params ["_targetVehicle", ["_forceParadrop", false]];

"RequestMenu_close" call WL2_fnc_setupUI;

if (WL_ISDOWN(player)) exitWith {
    ["Cannot fast travel while dead."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

if (isWeaponDeployed player) exitWith {
    ["Cannot fast travel while weapon is deployed."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

if (!alive _targetVehicle) exitWith {
    ["Cannot fast travel to a destroyed vehicle."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _assetPos = _targetVehicle modelToWorld [0, 0, 0];
private _altitude = _assetPos # 2;
if (_altitude < -1 && surfaceIsWater _assetPos) exitWith {
    ["Cannot fast travel to a submerged vehicle."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

titleCut ["", "BLACK OUT", 1];
openMap false;

"Fast_travel" call WL2_fnc_announcer;

uiSleep 1;

private _unitsToMove = (units player) select {
    isNull objectParent _x
} select {
    alive _x
} select {
    _x distance player < 200
} select {
    _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
} select {
	_x getVariable ["WL2_aiFollow", true]
};

{
    private _unit = _x;
    if (_altitude > 60) then {
        private _destination = _targetVehicle modelToWorld [0, 0, -10];
		_unit setPosATL _destination;

		_unit setVelocityModelSpace [0, 30, 0];
		[_unit] spawn WL2_fnc_parachuteSetup;
        continue;
    };

    if (_forceParadrop) then {
        private _destination = _targetVehicle modelToWorld [random 50 - 25, random 50 - 25, 0];
        _destination set [2, 500];
        _unit setDir (getDir _targetVehicle);
        _unit setPosATL _destination;

        _unit setVelocityModelSpace [0, 30, 0];
		[_unit] spawn WL2_fnc_parachuteSetup;
        continue;
    };

    if (_targetVehicle emptyPositions "cargo" >= 1) then {
        _unit moveInCargo _targetVehicle;
        continue;
    };

    if (isNull _targetVehicle) then {
        _targetVehicle = player;
    };

    private _buildingPositions = _targetVehicle buildingPos -1;
    if (count _buildingPositions > 0) then {
        private _destination = selectRandom _buildingPositions;
        _unit setPosASL (AGLtoASL _destination);
    } else {
        private _destination = _targetVehicle modelToWorld [0, 0, 0];
        _unit setVehiclePosition [_destination, [], 12, "CAN_COLLIDE"];
    };
} forEach _unitsToMove;

[player, "rewardTransport", _targetVehicle, _unitsToMove] remoteExec ["WL2_fnc_handleClientRequest", 2];

uiSleep 1;
titleCut ["", "BLACK IN", 1];

private _position = getPosASL player;
private _playersToPlay = allPlayers select {
	_x distance2D _position < WL_ENEMIES_NEAR_RADIUS
} select {
    side group _x != BIS_WL_playerSide
};
[_position] remoteExec ["WL2_fnc_playArrival", _playersToPlay];