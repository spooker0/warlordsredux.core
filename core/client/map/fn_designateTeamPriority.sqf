#include "includes.inc"
params ["_asset", "_type"];

private _side = BIS_WL_playerSide;

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
missionNamespace setVariable [_teamPriorityVar, _asset, true];

private _teamPriorityTypeVar = format ["WL2_teamPriorityType_%1", _side];
missionNamespace setVariable [_teamPriorityTypeVar, _type, true];

private _sectorName = _asset getVariable ["WL2_name", "Not Sector"];
private _assetName = if (_sectorName == "Not Sector") then {
    private _isStronghold = !isNull (_asset getVariable ["WL_strongholdSector", objNull]);
    if (_isStronghold) then {
        "Stronghold";
    } else {
        [_asset] call WL2_fnc_getAssetTypeName;
    };
} else {
    _sectorName
};
[format ["Team priority set to %1.", _assetName]] call WL2_fnc_smoothText;

playSoundUI ["AddItemOK"];