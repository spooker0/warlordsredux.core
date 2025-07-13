#include "includes.inc"

private _currentAmmo = destroyerVLS magazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", [0]];
_currentAmmo = (_currentAmmo + 1) min 6;
destroyerVLS setMagazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", _currentAmmo, [0]];

private _newControllerImage = format [
    "#(rgb,512,512,3)text(1,1,""LucidaConsoleB"",0.15,""#000000"",""#ffffff"",""AMMO: %1"")",
    _currentAmmo
];
destroyerController setObjectTextureGlobal [3, _newControllerImage];