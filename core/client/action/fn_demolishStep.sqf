#include "includes.inc"
params ["_targetObject", "_steps"];
private _maxHealth = _targetObject getVariable ["WL2_demolitionMaxHealth", 5];
private _existingHealth = _targetObject getVariable ["WL2_demolitionHealth", _maxHealth];
_existingHealth = _existingHealth - _steps;
_targetObject setVariable ["WL2_demolitionHealth", _existingHealth, true];
_targetObject setVariable ["WL_lastHitter", player, 2];

private _assetSide = [_targetObject] call WL2_fnc_getAssetSide;
if (_assetSide != BIS_WL_playerSide) then {
    [player, "demolished"] remoteExec ["WL2_fnc_handleClientRequest", 2];
};

if (_existingHealth <= 0) then {
    player setVariable ["WL2_demolishableTarget", objNull];

    private _strongholdSector = _targetObject getVariable ["WL_strongholdSector", objNull];
    if !(isNull _strongholdSector) then {
        private _strongholdSectorCheck = _strongholdSector getVariable ["WL_stronghold", objNull];
        if (_targetObject == _strongholdSectorCheck) then {
            [_strongholdSector] call WL2_fnc_removeStronghold;
            [player] remoteExec ["WL2_fnc_destroyStronghold", 2];
        };
    };

    [_targetObject, player] remoteExec ["WL2_fnc_demolishComplete", 2];
};