#include "includes.inc"
params ["_targetObject", "_steps"];
private _existingHealth = _targetObject getVariable ["WL2_demolitionHealth", 10];
_existingHealth = _existingHealth - _steps;
_targetObject setVariable ["WL2_demolitionHealth", _existingHealth, true];

if (_existingHealth <= 0) then {
    private _strongholdSector = _targetObject getVariable ["WL_strongholdSector", objNull];
    if !(isNull _strongholdSector) then {
        private _strongholdSectorCheck = _strongholdSector getVariable ["WL_stronghold", objNull];
        if (_targetObject == _strongholdSectorCheck) then {
            [_strongholdSector] call WL2_fnc_removeStronghold;
        };
    };

    [_targetObject, player] remoteExec ["WL2_fnc_demolishComplete", 2];
};