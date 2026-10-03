#include "includes.inc"

disableSerialization;

// A supplied display lets read-only previews reuse the live catalog without
// replacing the player's active purchase menu or its saved selection.
private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (!isNil "_this" && { _this isEqualType [] } && { count _this > 0 } && { (_this # 0) isEqualType displayNull }) then {
    _display = _this # 0;
};
if (isNull _display) exitWith {};

// Keep the established code scheme: 1..9, 01..09, 001..009, etc.
private _encodeCode = {
    params ["_index"];
    private _code = "";
    for "_zero" from 1 to floor (_index / 9) do {
        _code = _code + "0";
    };

    _code + str (_index % 9 + 1)
};

private _categoryNames = [
    localize "STR_A3_cfgmarkers_nato_inf", localize "STR_WL_lightVehicles",
    localize "STR_WL_heavyVehicles", localize "STR_WL_rotaryWing",
    localize "STR_WL_fixedWing", localize "STR_WL_remoteControl",
    localize "STR_WL_airDefense", localize "STR_WL_sectorDefense",
    localize "STR_WL_structures", localize "STR_A3_rscdisplaygarage_tab_naval",
    localize "STR_A3_rscdisplaywelcome_exp_parb_list4_title",
    localize "STR_WL_fastTravel", localize "STR_A3_WL_menu_strategy"
];
private _categoryDescriptions = [
    "", localize "STR_WL_lightVehicleInfo", localize "STR_WL_heavyVehicleInfo",
    localize "STR_WL_rotaryWingInfo", localize "STR_WL_fixedWingInfo",
    localize "STR_WL_remoteControlInfo", localize "STR_WL_airDefenseInfo",
    localize "STR_WL_sectorDefenseInfo", localize "STR_WL_structuresInfo",
    localize "STR_A3_WL_asset_naval_info", localize "STR_A3_WL_asset_gear_info", "", ""
] apply {
    // Tooltips use plain text. Preserve line breaks, then remove structured-text tags.
    (_x regexReplace ["<[bB][rR]\s*/?>", "\n"]) regexReplace ["<[^>]+>", ""]
};

private _categories = [];
private _catalog = [];
private _assetData = WL_ASSET_DATA;
{
    private _categoryIndex = _forEachIndex;
    private _categoryCode = [_categoryIndex] call _encodeCode;
    if (count _x > 0) then {
        _categories pushBack [_categoryNames # _categoryIndex, _categoryIndex, _categoryCode, _categoryDescriptions # _categoryIndex];
    };

    {
        _x params ["_className", "_cost", "_requirements", "_name", "_picture", "_text", ["_offset", [0, 0, 0]]];
        private _details = [_className, _requirements, _name, _picture, _text, _offset, _cost, WL_REQUISITION_CATEGORIES # _categoryIndex];
        private _spawnClass = WL_ASSET_FIELD(_assetData, _className, "spawn", _className);
        private _icon = getText (configFile >> "CfgVehicles" >> _spawnClass >> "picture");
        private _special = WL_ASSET_FIELD(_assetData, _className, "variant", 0) != 0 || "V" in _requirements;
        _catalog pushBack [_details, _categoryCode + ([_forEachIndex] call _encodeCode), toLower _name, _icon, _special, _categoryIndex];
    } forEach _x;
} forEach WL_PLAYER_REQUISITION_LIST;
_display setVariable ["BUY_catalog", _catalog];
_display setVariable ["BUY_categories", _categories];
