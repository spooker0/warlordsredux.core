params ["_sender", "_side", "_forwardBase", "_level"];

if (_level > 4) exitWith {};

private _fobDome = _forwardBase getVariable ["WL2_forwardBaseDome", objNull];

if (!isNull _fobDome) then {
    deleteVehicle _fobDome;
};

private _position = _forwardBase modelToWorld [0, 0, 0];
_position set [2, 0];
private _direction = getDir _forwardBase;
private _domeType = switch (_level) do {
    case 0 : { "Land_Dome_Small_WIP_F" };
    case 1 : { "Land_Dome_Small_WIP2_F" };
    case 2 : { "Land_Dome_Small_F" };
    case 3 : { "Land_Dome_Big_F" };
    default { "Land_Dome_Small_F" };
};
private _newDome = [_domeType, _domeType, _position, _direction, false, false] call WL2_fnc_createVehicleCorrectly;
_newDome allowDamage false;
_newDome setVariable ["WL2_doorsLocked", _side, true];
_newDome setVehiclePosition [_position, [], 0, "CAN_COLLIDE"];

_forwardBase setVariable ["WL2_forwardBaseDome", _newDome];

private _assetChildren = _forwardBase getVariable ["WL2_children", []];
_assetChildren pushBack _newDome;

if (_level == 3) then {
    private _startObject = if (isNull _fobDome) then {
        _forwardBase
    } else {
        _fobDome
    };
    private _railPosition = _startObject modelToWorld [0, 60, 0];
    private _catapultRail = [_sender, _railPosition, "Land_CraneRail_01_F", getDir _forwardBase, false, false] call WL2_fnc_orderGround;
    _catapultRail setVehiclePosition [_railPosition, [], 0, "CAN_COLLIDE"];

    _assetChildren pushBack _catapultRail;
    _forwardBase setVariable ["WL2_services", ["H", "A", "FA"], true];
};

_forwardBase setVariable ["WL2_children", _assetChildren];