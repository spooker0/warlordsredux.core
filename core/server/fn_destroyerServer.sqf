#include "includes.inc"

if (isNil "destroyerController") exitWith {};

private _assetGroup = createGroup independent;
private _unit = _assetGroup createUnit ["I_UAV_AI", getPosASL destroyerVLS, [], 0, "NONE"];
_unit moveInAny destroyerVLS;
_unit disableAI "ALL";
_assetGroup deleteGroupWhenEmpty true;

destroyerVLS removeMagazineTurret ["magazine_Missiles_Cruise_01_Cluster_x18", [0]];
destroyerVLS setMagazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", 1, [0]];

while { !BIS_WL_missionEnd } do {
    sleep 90;
    private _turretOwner = destroyerVLS turretOwner [0];
    [] remoteExec ["WL2_fnc_addMissileToMag", _turretOwner];
};