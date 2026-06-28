#include "includes.inc"
params ["_targetObject", "_steps"];

private _maxHealth = _targetObject getVariable ["WL2_demolitionMaxHealth", 5];
private _previousHealth = _targetObject getVariable ["WL2_demolitionHealth", _maxHealth];

private _appliedSteps = (_steps max 0) min (_previousHealth max 0);

if (_appliedSteps <= 0) exitWith {};

private _newHealth = _previousHealth - _appliedSteps;

_targetObject setVariable ["WL2_demolitionHealth", _newHealth, true];
_targetObject setVariable ["WL_lastHitter", player, 2];
_targetObject setVariable ["WL2_canRepairTime", serverTime + 60, true];

private _assetSide = [_targetObject] call WL2_fnc_getAssetSide;

if (_assetSide != BIS_WL_playerSide) then {
    [player, "demolished", _appliedSteps] remoteExec ["WL2_fnc_handleClientRequest", 2];
};

if (_newHealth <= 0) then {
    player setVariable ["WL2_demolishableTarget", objNull];

    private _damageBuilding = true;
    private _strongholdSector = _targetObject getVariable ["WL_strongholdSector", objNull];

    if !(isNull _strongholdSector) then {
        private _strongholdSectorCheck = _strongholdSector getVariable ["WL_stronghold", objNull];

        if (_targetObject == _strongholdSectorCheck) then {
            [_strongholdSector] call WL2_fnc_removeStronghold;

            _strongholdSector setVariable ["WL2_strongholdAllowTime", serverTime + 300, true];

            if (_assetSide != BIS_WL_playerSide) then {
                _damageBuilding = (_assetSide != independent);
                [player, _strongholdSector] remoteExec ["WL2_fnc_destroyStronghold", 2];
            };
        };
    };

    [_targetObject, player, _damageBuilding] remoteExec ["WL2_fnc_demolishComplete", 2];
};