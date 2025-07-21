#include "includes.inc"
params ["_mrls"];

private _currentAmmo = _mrls magazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", [0]];
_currentAmmo = (_currentAmmo + 1) min WL_DESTROYER_MAXAMMO;
_mrls setMagazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", _currentAmmo, [0]];

private _newControllerImage = format [
    "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.3,""#000000"",""#ffffff"",""AMMO\n%1"")",
    _currentAmmo
];
private _controller = _mrls getVariable ["WL2_destroyerController", objNull];
_controller setObjectTextureGlobal [3, _newControllerImage];