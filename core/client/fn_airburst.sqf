#include "includes.inc"
params ["_projectile", "_asset"];

while {alive _projectile} do {
    private _targets = _projectile nearEntities ["Air", 20];
    _targets = _targets select {
        _x != _asset
    };
    if (count _targets > 0) exitWith {
        triggerAmmo _projectile;
    };
    uiSleep 0.05;
};