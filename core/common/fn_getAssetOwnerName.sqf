params ["_asset"];

private _ownerName = _asset getVariable ["WL2_assetOwnerName", ""];
if (_ownerName != "") exitWith {
    _ownerName;
};

private _ownerPlayer = (_asset getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
private _ownerName = if (name _ownerPlayer == "Error: No vehicle") then {
    "";
} else {
    format ["(%1)", name _ownerPlayer];
};
_asset setVariable ["WL2_assetOwnerName", _ownerName];
_ownerName;