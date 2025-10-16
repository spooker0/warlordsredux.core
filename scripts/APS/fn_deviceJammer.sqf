#include "includes.inc"
params ["_asset", "_turret"];

private _assetSide = [_asset] call WL2_fnc_getAssetSide;

while { alive _asset } do {
    sleep 0.2;

    if (!local _asset) then {
        sleep 3;
        continue;
    };

    private _laserTarget = _asset laserTarget _turret;
    if (isNull _laserTarget) then {
        sleep 1;
        continue;
    };

    private _vehiclesInRange = (_laserTarget nearEntities 50) select {
        _x getVariable ["apsType", -1] > -1 &&
        [_x] call WL2_fnc_getAssetSide != _assetSide
    };

    if (count _vehiclesInRange == 0) then {
        continue;
    };

    {
        private _deviceTarget = _x;
        if (_deviceTarget getVariable ["WL2_apsActivated", false]) then {
            _deviceTarget setVariable ["WL2_apsActivated", false, true];
            [["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true]] remoteExec ["playSoundUI", [_asset, _deviceTarget]];
        };
    } forEach _vehiclesInRange;
};