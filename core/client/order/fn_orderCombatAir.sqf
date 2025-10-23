#include "includes.inc"

private _spawnPos = [8941.11, 28788.2, 10000];
private _jetParams = [_spawnPos, random 360, "B_Plane_Fighter_01_F", BIS_WL_enemySide] call BIS_fnc_spawnVehicle;
_jetParams params ["_jet", "_crew", "_group"];
{
    _x call WL2_fnc_newAssetHandle;
} forEach _crew;
_jet call WL2_fnc_newAssetHandle;

private _pilot = _crew # 0;
_jet setVelocityModelSpace [0, 350, 0];

_jet removeAllMagazinesTurret [];
_jet addWeaponTurret ["weapon_AMRAAMLauncher", [-1]];
for "_i" from 1 to 8 do {
    _jet addMagazineTurret ["PylonMissile_Missile_AMRAAM_D_INT_x1", [-1]];
};

private _target = vehicle player;
_jet setVariable ["WL2_selectedTargetAA", _target];

uiSleep 3;
_pilot selectWeapon "weapon_AMRAAMLauncher";
uiSleep 5;
for "_i" from 1 to 8 do {
    _jet setVelocityModelSpace [0, 270, 0];

    private _ammoConfig = createHashMap;
    _ammoConfig set ["loal", true];
    _jet setVariable ["WL2_currentAmmoConfig", _ammoConfig];
    _pilot forceWeaponFire ["weapon_AMRAAMLauncher", "LoalDistance"];
    uiSleep 5;
};