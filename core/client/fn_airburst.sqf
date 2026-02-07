#include "includes.inc"
params ["_projectile", "_asset", "_radius"];

while { alive _projectile } do {
    private _targets = _projectile nearEntities ["Air", _radius];
    _targets = _targets select {
        _x != _asset
    };
    if (count _targets > 0) exitWith {
        triggerAmmo _projectile;
    };
    uiSleep 0.05;
};