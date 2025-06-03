params ["_asset", ["_assetType", ""]];

private _cachedDisplayName = _asset getVariable ["WL2_assetDisplayName", ""];
if (_cachedDisplayName != "") exitWith {
    _cachedDisplayName;
};

if (_assetType == "") then {
    _assetType = typeOf _asset;
};
private _nameOverrides = missionNamespace getVariable ["WL2_nameOverrides", createHashMap];
private _assetActualType = _asset getVariable ["WL2_orderedClass", _assetType];
private _assetDisplayName = _nameOverrides getOrDefault [_assetActualType, getText (configFile >> "CfgVehicles" >> _assetActualType >> "displayName")];

_asset setVariable ["WL2_assetDisplayName", _assetDisplayName];

_assetDisplayName