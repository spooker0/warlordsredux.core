params ["_targetVehicle"];

"RequestMenu_close" call WL2_fnc_setupUI;

if (!alive _targetVehicle) exitWith {
    systemChat "Cannot fast travel to a destroyed vehicle.";
    playSoundUI ["AddItemFailed"];
};

private _assetPos = getPosASL _targetVehicle;
private _altitude = _assetPos # 2;
if (_altitude < 0 && surfaceIsWater _assetPos) exitWith {
    systemChat "Cannot fast travel to a submerged vehicle.";
    playSoundUI ["AddItemFailed"];
};

titleCut ["", "BLACK OUT", 1];
openMap false;

"Fast_travel" call WL2_fnc_announcer;

sleep 1;

private _unitsToMove = (units player) select {
	_x distance2D player <= 100 &&
	isNull objectParent _x &&
	alive _x &&
	_x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
};

{
    private _unit = _x;
    if (_targetVehicle emptyPositions "cargo" >= 1) then {
        _unit moveInCargo _targetVehicle;
    } else {
        if (isNull _targetVehicle) then {
            _targetVehicle = player;
        };
        private _destination = getPosATL _targetVehicle;
        _unit setVehiclePosition [_destination, [], 3, "NONE"];
    };
} forEach _unitsToMove;

[player, "ftSupportPoints", _targetVehicle, count _unitsToMove] remoteExec ["WL2_fnc_handleClientRequest", 2];

sleep 1;
titleCut ["", "BLACK IN", 1];