#include "includes.inc"
params ["_sender", "_pos", "_orderedClass"];

if !(isServer) exitWith {};

private _class = WL_ASSET(_orderedClass, "spawn", _orderedClass);

private _position = _pos vectorAdd [0, 0, 1];
private _asset = createVehicle [_class, _position, [], 0, "CAN_COLLIDE"];
_asset setDir (getDir _sender);
_asset setPosASL _position;

private _drone = WL_ASSET(_orderedClass, "drone", 0);
if (_drone > 0) then {
    private _side = if (isNull _sender) then {
        independent;
    } else {
        side group _sender;
    };
    private _assetGrp = createGroup _side;

    private _aiUnit = switch (_side) do {
        case west: { "B_UAV_AI" };
        case east: { "O_UAV_AI" };
        case independent: { "I_UAV_AI" };
    };

    for "_i" from 1 to _drone do {
        private _unit = _assetGrp createUnit [_aiUnit, _pos, [], 0, "NONE"];
        _unit moveInAny _asset;
        if (!isNull _sender) then {
            _unit setSkill 1;
            _unit setVariable ["BIS_WL_ownerAsset", getPlayerUID _sender, true];
        };
    };

    _asset lockDriver true;
    _assetGrp deleteGroupWhenEmpty true;
};

[_asset, _sender, _orderedClass] call WL2_fnc_processOrder;

if (_sender distance2D _asset < 100) then {
    [_sender, _asset] remoteExec ["moveInDriver", _sender];
};