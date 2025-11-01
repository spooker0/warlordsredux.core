#include "includes.inc"
params ["_position", "_destroyerDir", "_destroyerName", "_destroyerId"];

private _destroyerBase = createSimpleObject ["Land_Destroyer_01_base_F", _position];
_destroyerBase setDir _destroyerDir;
private _destroyerPos = getPosWorld _destroyerBase;

private _destroyerPitchBank = _destroyerBase call bis_fnc_getPitchBank;
_destroyerPitchBank params [["_destroyerPitch", 0], ["_destroyerBank", 0]];

private _destroyerParts = getArray (configFile >> "CfgVehicles" >> typeOf _destroyerBase >> "multiStructureParts");
private _destroyerPartsArray = [];

private _hullNumber = "";
{
    private _dummyClassName = _x select 0;
    private _dummyPosition = _x select 1;
    private _dummy = createVehicle [_dummyClassName, _destroyerPos, [], 0, "CAN_COLLIDE"];
    _dummy setDir _destroyerDir;

    [_dummy, _destroyerPitch, _destroyerBank] call bis_fnc_setPitchBank;

    private _destroyerPartPos = _destroyerBase modelToWorldWorld (_destroyerBase selectionPosition _dummyPosition);
    _dummy setPosWorld _destroyerPartPos;

    _destroyerPartsArray pushBack [_dummy, _dummyPosition];

    _dummy allowDamage false;

    if (_dummyClassName == "Land_Destroyer_01_hull_01_F") then {
        private _hullNum1 = round (random 9);
        private _hullNum2 = round (random 9);
        private _hullNum3 = round (random 9);

        _dummy setObjectTextureGlobal [0, format ["\A3\Boat_F_Destroyer\Destroyer_01\Data\Destroyer_01_N_0%1_co.paa", _hullNum1]];
        _dummy setObjectTextureGlobal [1, format ["\A3\Boat_F_Destroyer\Destroyer_01\Data\Destroyer_01_N_0%1_co.paa", _hullNum2]];
        _dummy setObjectTextureGlobal [2, format ["\A3\Boat_F_Destroyer\Destroyer_01\Data\Destroyer_01_N_0%1_co.paa", _hullNum3]];

        _hullNumber = format ["%1%2%3", _hullNum1, _hullNum2, _hullNum3];
    };
} foreach _destroyerParts;

private _controllerParams = ["Land_MultiScreenComputer_01_sand_F", [0.191406, -34.4709, 20.3266], 0];
private _controller = createVehicle [_controllerParams select 0, [0, 0, 0], [], 0, "CAN_COLLIDE"];
private _controllerDir = _controllerParams select 2;
private _controllerPos = _destroyerBase modelToWorldWorld (_controllerParams select 1);
_controller setDir (_controllerDir + _destroyerDir);
_controller setPosWorld _controllerPos;
_controller allowDamage false;
_controller enableSimulationGlobal false;
_controller setObjectTextureGlobal [1, "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.2,""#000000"",""#ffffff"",""MISSILE\nBATTERY\nCONTROL"")"];
_controller setObjectTextureGlobal [2, "\A3\Static_F_Destroyer\Ship_MRLS_01\Data\Ui\Ship_MRLS_01_picture_CA.paa"];
_controller setObjectTextureGlobal [3, "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.3,""#000000"",""#ffffff"",""AMMO\n1"")"];
_destroyerBase setVariable ["WL2_destroyerController", _controller, true];

private _screenParams = ["Land_FlatTV_01_F", [-0.875977, -34.217, 20.3959], 0];
private _screenDir = _screenParams select 2;
private _screenPos = _destroyerBase modelToWorldWorld (_screenParams select 1);
private _screen = createSimpleObject [_screenParams select 0, _screenPos, true];
_screen setDir (_screenDir + _destroyerDir);
_screen setPosWorld _screenPos;
_screen allowDamage false;
_screen enableSimulationGlobal false;
_screen setObjectTextureGlobal [0, format ["#(argb,512,512,1)r2t(destroyercam%1,1.0)", _destroyerId]];

private _mrls = objNull;

private _createMrls = {
    private _mrlsParams = ["B_Ship_MRLS_01_F", [0.253906, -62.4602, 11.9104], -180];
    _mrls = createVehicle [_mrlsParams select 0, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    private _mrlsDir = _mrlsParams select 2;
    private _mrlsPos = _destroyerBase modelToWorldWorld (_mrlsParams select 1);
    _mrls setDir (_mrlsDir + _destroyerDir);
    _mrls setPosWorld _mrlsPos;
    _mrls setVehicleReceiveRemoteTargets false;
    _mrls lock true;
    _destroyerBase setVariable ["WL2_destroyerVLS", _mrls, true];

    _controller setVariable ["WL2_destroyerVLS", _mrls, true];
    _mrls setVariable ["WL2_overrideRange", 30000, true];
    _mrls setVariable ["WL2_destroyerController", _controller, true];
    _mrls setVariable ["WL2_destroyerId", _destroyerId, true];
    _mrls setVariable ["WL_spawnedAsset", true, true];

    private _assetGroup = createGroup independent;
    private _unit = _assetGroup createUnit ["I_UAV_AI", [0, 0, 0], [], 0, "NONE"];
    _unit moveInAny _mrls;
    _unit disableAI "ALL";
    _assetGroup deleteGroupWhenEmpty true;

    _mrls removeMagazineTurret ["magazine_Missiles_Cruise_01_Cluster_x18", [0]];
    _mrls setMagazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", 1, [0]];

    _mrls setVariable ["WL2_accessControl", 7, true];
};

call _createMrls;

private _ropeLocations = [
    [0, -110.5, 14],
    [0, 92, 10.5],
    [11, 60, 17],
    [-11, 60, 17]
];
private _ropeDirections = [0, 180, 180, 180];
private _ropeMinLevel = [0, 0, 9, 9];

{
    private _ropeLocation = _x;

    private _ropePosition = _destroyerBase modelToWorldWorld _ropeLocation;
    private _rope = createSimpleObject ["Land_Rope_F", _ropePosition, true];
    _rope setDir (getDir _destroyerBase + _ropeDirections # _forEachIndex);
    _rope setPosASL _ropePosition;
    _rope setVariable ["WL2_rappelRopeMinLevel", _ropeMinLevel # _forEachIndex];

    private _marker = format ["destroyer%1_rappel%2", _destroyerId, _forEachIndex];
    createMarkerLocal [_marker, _ropePosition];
    _marker setMarkerTypeLocal "loc_Quay";
    _marker setMarkerAlphaLocal 0.4;
    _marker setMarkerSizeLocal [0.7, 0.7];

    private _existingRopes = missionNamespace getVariable ["WL2_rappelRopes", []];
    _existingRopes pushBack _rope;
    missionNamespace setVariable ["WL2_rappelRopes", _existingRopes];
} forEach _ropeLocations;

private _outlineMarkerLocation = _destroyerBase modelToWorld [0, -10, 0];
private _outlineMarker = createMarkerLocal [format ["marker_%1_outline", _destroyerName], _outlineMarkerLocation];
_outlineMarker setMarkerShapeLocal "RECTANGLE";
_outlineMarker setMarkerSizeLocal [20, 100];
_outlineMarker setMarkerDirLocal _destroyerDir;
_outlineMarker setMarkerColor "ColorRed";

private _destroyerMarker = createMarkerLocal [format ["marker_%1", _destroyerName], _controllerPos];
_destroyerMarker setMarkerShapeLocal "ICON";
_destroyerMarker setMarkerTypeLocal "loc_boat";
_destroyerMarker setMarkerTextLocal format ["%1 (DDG-%2)", _destroyerName, _hullNumber];
_destroyerMarker setMarkerColor "ColorWhite";

uiSleep 10;

[_destroyerBase, _mrls, _controller, true] remoteExec ["WL2_fnc_createDestroyerClient", 0, true];

while { true } do {
    uiSleep WL_DESTROYER_RELOAD;
    private _turretOwner = _mrls turretOwner [0];
    [_mrls] remoteExec ["WL2_fnc_addMissileToMag", _turretOwner];

    if (!alive _mrls) then {
        deleteVehicle _mrls;
        uiSleep WL_DESTROYER_RESPAWN;
        call _createMrls;
        [objNull, _mrls, objNull, false] remoteExec ["WL2_fnc_createDestroyerClient", 0, true];
    };
};