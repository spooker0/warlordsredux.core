#include "includes.inc"
params ["_position", "_destroyerDir", "_destroyerName", "_destroyerId"];

private _destroyerBase = createSimpleObject ["Land_Destroyer_01_base_F", _position];
_destroyerBase setDir _destroyerDir;

_destroyerBase setVariable ["WL2_destroyerId", _destroyerId, true];

_destroyerBase setVariable ["WL2_canDemolish", true, true];
_destroyerBase setVariable ["WL_spawnedAsset", true, true];
_destroyerBase setVariable ["WL2_demolitionMaxHealth", 25, true];
_destroyerBase setVariable ["WL2_demolitionHealth", 25, true];
_destroyerBase setVariable ["BIS_WL_ownerAsset", "", true];

private _hullNum1 = round (random 9);
private _hullNum2 = round (random 9);
private _hullNum3 = round (random 9);
_destroyerBase setVariable ["WL2_destroyerHullNumbers", [_hullNum1, _hullNum2, _hullNum3], true];
private _hullNumber = format ["%1%2%3", _hullNum1, _hullNum2, _hullNum3];

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

[_destroyerBase, objNull, _controller, true] remoteExec ["WL2_fnc_createDestroyerClient", 0, true];

private _nextReloadTime = serverTime + WL_DESTROYER_RELOAD;
private _nextRespawnTime = serverTime + 120;
while { alive _destroyerBase } do {
    uiSleep 1;
    if (serverTime >= _nextReloadTime) then {
        private _turretOwner = _mrls turretOwner [0];
        [_mrls] remoteExec ["WL2_fnc_addMissileToMag", _turretOwner];
        _nextReloadTime = serverTime + WL_DESTROYER_RELOAD;
    };

    if (alive _mrls) then {
        _nextRespawnTime = serverTime + WL_DESTROYER_RESPAWN;
    } else {
        if (serverTime >= _nextRespawnTime) then {
            call _createMrls;
            [_destroyerBase, _mrls, objNull, false] remoteExec ["WL2_fnc_createDestroyerClient", 0, true];
            _nextRespawnTime = serverTime + WL_DESTROYER_RESPAWN;
        };
    };
};

deleteVehicle _controller;
deleteVehicle _mrls;

_outlineMarker setMarkerColor "ColorBlack";
_destroyerMarker setMarkerTextLocal format ["%1 (DDG-%2) - SINKING", _destroyerName, _hullNumber];

uiSleep 60;

deleteMarker _outlineMarker;
deleteMarker _destroyerMarker;