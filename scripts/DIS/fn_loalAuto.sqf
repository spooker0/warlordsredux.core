#include "includes.inc"
params ["_asset"];

private _gunner = gunner _asset;
private _range = 14000;

(group _gunner) setCombatMode "BLUE";

while { alive _asset && alive _gunner } do {
    uiSleep 5;

    if (cameraOn == _asset) then {
        continue;
    };

    private _targets = [_asset] call DIS_fnc_getSamTarget;
    _targets = _targets select {
        (_x # 0) distance _asset <= _range
    };
    _targets = [_targets, [_asset], { _input0 distance (_x # 0) }, "ASCEND"] call BIS_fnc_sortBy;

    private _selectedTarget = if (count _targets > 0) then {
        _targets # 0 # 0
    } else {
        objNull
    };
    if (isNull _selectedTarget) then {
        continue;
    };

    systemChat str _selectedTarget;
    _gunner lookAt _selectedTarget;

    _asset setVariable ["WL2_selectedTargetAA", _selectedTarget];

    private _weaponState = weaponState [_asset, [0]];
    _gunner forceWeaponFire [_weaponState # 1, _weaponState # 2];

    systemChat format ["%1, %2", _weaponState # 1, _weaponState # 2];
};