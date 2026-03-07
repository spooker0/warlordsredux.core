params ["_sender", "_side", "_forwardBase", "_level"];

if (_level > 4) exitWith {};

private _fobDome = _forwardBase getVariable ["WL2_forwardBaseDome", objNull];
if (_level == 3) then {
    private _hangarType = "Land_TentHangar_V1_F";

    private _backHangar = if (isNull _fobDome) then {
        private _position = _forwardBase modelToWorld [0, 0, 0];
        private _direction = getDir _forwardBase;
        [_hangarType, _hangarType, _position, _direction, false, false] call WL2_fnc_createVehicleCorrectly;
    } else {
        private _position = _fobDome modelToWorldWorld [0, 20, -2.5];
        private _vectorDirAndUp = [vectorDir _fobDome, vectorUp _fobDome];
        [_hangarType, _hangarType, _position, _vectorDirAndUp, false, false] call WL2_fnc_createVehicleCorrectly;
    };
    _backHangar allowDamage false;

    private _railPosition = _backHangar modelToWorld [0, 26, 0];
    private _catapultRail = [_sender, _railPosition, "Land_CraneRail_01_F", getDir _forwardBase, false, false] call WL2_fnc_orderGround;

    private _scoutPlaneType = if (_side == west) then {
        "B_Scout_Falcon"
    } else {
        "O_Scout_Falcon"
    };

    private _planePosition = _forwardBase modelToWorld [0, -30, 0];
    private _scoutPlane = [_sender, _planePosition, _scoutPlaneType, getDir _backHangar, false, false] call WL2_fnc_orderGround;

    private _assetChildren = _forwardBase getVariable ["WL2_children", []];
    _assetChildren pushBack _backHangar;
    _assetChildren pushBack _catapultRail;
    _forwardBase setVariable ["WL2_children", _assetChildren];
} else {
    if (!isNull _fobDome) then {
        deleteVehicle _fobDome;
    };

    private _position = _forwardBase modelToWorld [0, 0, 0];
    private _direction = getDir _forwardBase;
    private _domeType = switch (_level) do {
        case 0 : { "Land_Dome_Small_WIP_F" };
        case 1 : { "Land_Dome_Small_WIP2_F" };
        case 2 : { "Land_Dome_Small_F" };
        default { "Land_Dome_Small_F" };
    };
    private _newDome = [_domeType, _domeType, _position, _direction, false, false] call WL2_fnc_createVehicleCorrectly;
    _newDome allowDamage false;
    _forwardBase setVariable ["WL2_forwardBaseDome", _newDome, true];

    private _assetChildren = _forwardBase getVariable ["WL2_children", []];
    _assetChildren pushBack _newDome;
    _forwardBase setVariable ["WL2_children", _assetChildren];
};