#include "includes.inc"
params ["_targetVehicle"];

"RequestMenu_close" call WL2_fnc_setupUI;

if (!alive _targetVehicle) exitWith {
    ["Cannot fast travel to a destroyed vehicle."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _assetPos = getPosASL _targetVehicle;
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
};

{
    private _unit = _x;
    if (_targetVehicle emptyPositions "cargo" >= 1) then {
        _unit moveInCargo _targetVehicle;
    } else {
        if (isNull _targetVehicle) then {
            _targetVehicle = player;
        };

        private _buildingPositions = _targetVehicle buildingPos -1;
        if (count _buildingPositions > 0) then {
            private _destination = selectRandom _buildingPositions;
            _unit setPosASL (AGLtoASL _destination);
        } else {
            private _destination = _targetVehicle modelToWorld [0, 0, 0];
            _unit setVehiclePosition [_destination, [], 3, "NONE"];
        };
    };
} forEach _unitsToMove;

[player, "ftSupportPoints", _targetVehicle, count _unitsToMove] remoteExec ["WL2_fnc_handleClientRequest", 2];

uiSleep 1;
titleCut ["", "BLACK IN", 1];