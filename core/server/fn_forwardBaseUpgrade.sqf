params ["_sender", "_side", "_forwardBase", "_level"];

private _fobDome = _forwardBase getVariable ["WL2_forwardBaseDome", objNull];
if (_level == 3) then {
    private _hangarType = "Land_TentHangar_V1_F";

    private _backHangar = if (isNull _fobDome) then {
        private _position = _forwardBase modelToWorld [0, 0, 0];
        private _direction = getDir _forwardBase;
        [_hangarType, _hangarType, _position, _direction, false] call WL2_fnc_createVehicleCorrectly;
    } else {
        private _position = _fobDome modelToWorldWorld [0, 20, -2.5];
        private _vectorDirAndUp = [vectorDir _fobDome, vectorUp _fobDome];
        [_hangarType, _hangarType, _position, _vectorDirAndUp, true] call WL2_fnc_createVehicleCorrectly;
    };
    _backHangar allowDamage false;

    private _forwardHangarPosition = _backHangar modelToWorldWorld [0, 18, 0];
    private _vectorDirAndUp = [vectorDir _backHangar, vectorUp _backHangar];
    private _forwardHangar = [_hangarType, _hangarType, _forwardHangarPosition, _vectorDirAndUp, true] call WL2_fnc_createVehicleCorrectly;
    _forwardHangar allowDamage false;

    private _railPosition = _forwardHangar modelToWorld [0, 18, 0];
    private _catapultRail = [_sender, _railPosition, "Land_CraneRail_01_F", getDir _forwardBase, false] call WL2_fnc_orderGround;

    private _hangarPosATL = getPosATL _forwardHangar;
    if (_hangarPosATL # 2 > -1) then {
        private _scoutPlaneType = if (_side == west) then {
            "B_Plane_Fighter_01_Stealth_Unarmed_F"
        } else {
            "O_Plane_Fighter_02_Stealth_Unarmed_F"
        };

        private _planePosition = _forwardHangar modelToWorld [0, -3, 0];
        private _scoutPlane = [objNull, _planePosition, _scoutPlaneType, getDir _forwardHangar, false] call WL2_fnc_orderGround;

        private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
        _ownedVehicles pushBack _scoutPlane;
        missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];
    };

    private _assetChildren = _forwardBase getVariable ["WL2_children", []];
    _assetChildren pushBack _backHangar;
    _assetChildren pushBack _forwardHangar;
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
    private _newDome = [_domeType, _domeType, _position, _direction, false] call WL2_fnc_createVehicleCorrectly;
    _newDome allowDamage false;
    _forwardBase setVariable ["WL2_forwardBaseDome", _newDome];

    private _assetChildren = _forwardBase getVariable ["WL2_children", []];
    _assetChildren pushBack _newDome;
    _forwardBase setVariable ["WL2_children", _assetChildren];
};