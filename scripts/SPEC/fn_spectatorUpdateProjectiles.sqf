params ["_cameraPos", "_maxDistance"];

private _projectiles = uiNamespace getVariable ["WL2_projectiles", []];
_projectiles = _projectiles select {
    alive _x && _x distance _cameraPos <= _maxDistance
};
uiNamespace setVariable ["WL2_spectatorDrawProjectiles", _projectiles];