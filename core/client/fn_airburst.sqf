#include "includes.inc"
params ["_projectile"];

while {alive _projectile} do {
    private _targets = _projectile nearEntities ["Air", 20];
    if (count _targets > 0) exitWith {
        triggerAmmo _projectile;
    };
    uiSleep 0.05;
};