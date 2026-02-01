#include "includes.inc"
params ["_stronghold", "_sector"];

private _oldStronghold = _sector getVariable ["WL_stronghold", objNull];
if (!isNull _oldStronghold) then {
    [_sector, true] call WL2_fnc_removeStronghold;
};

_stronghold setVariable ["WL2_orderedClass", typeof _stronghold, true];
_stronghold setVariable ["BIS_WL_ownerAsset", "123", true];

private _strongholdRadius = (boundingBoxReal _stronghold) # 2;
_stronghold setVariable ["WL_strongholdRadius", _strongholdRadius, true];
_stronghold setVariable ["WL_strongholdSector", _sector, true];

_sector setVariable ["WL_stronghold", _stronghold, true];

[_stronghold] remoteExec ["WL2_fnc_prepareStronghold", 2];

private _allStrongholds = missionNamespace getVariable ["WL_strongholds", []];
_allStrongholds = _allStrongholds select {
    _x != _oldStronghold
 };
_allStrongholds pushBack _stronghold;
missionNamespace setVariable ["WL_strongholds", _allStrongholds, true];