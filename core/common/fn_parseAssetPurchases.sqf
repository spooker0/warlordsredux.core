#include "includes.inc"
params ["_side"];

private _categories = WL_REQUISITION_CATEGORIES;

private _getDescription = {
    params ["_className", "_config"];
    private _libTextDesc = getText (_config >> "Library" >> "LibTextDesc");
    if (_libTextDesc select [0, 1] == "$") then {
        localize ((_libTextDesc splitString "$") # 0);
    } else {
        _libTextDesc;
    };
};

private _sideString = switch (_side) do {
    case west: {"west"};
    case east: {"east"};
    case independent: {"guer"};
    default { "none" };
};

private _sortingData = [];
{
    _sortingData pushBack [];
} forEach _categories;
private _buyableMap = createHashMap;
private _assetData = WL_ASSET_DATA;
{
    private _className = _x;
    private _classData = _y;

    private _assetSides = _classData getOrDefault ["side", []];
    if !(_sideString in _assetSides) then {
        continue;
    };

    private _category = _classData getOrDefault ["category", ""];
    private _categoryIndex = _categories find _category;
    if (_categoryIndex == -1) then {
        continue;
    };

    private _cost = _classData getOrDefault ["cost", 0];
    if (_cost <= 0) then {
        continue;
    };

    private _requirements = _classData getOrDefault ["requirements", []];
    private _offset = _classData getOrDefault ["offset", []];
    private _displayName = [objNull, _className] call WL2_fnc_getAssetTypeName;

    private _actualClassName = _classData getOrDefault ["spawn", _className];
    private _config = configFile >> "CfgVehicles" >> _actualClassName;

    private _picture = getText (_config >> "editorPreview");

    private _description = _classData getOrDefault ["description", ""];
    private _assetText = if (_description != "") then {
        _description
    } else {
        [_className, _config] call _getDescription;
    };

    private _vehicleWeapons = [_className, _actualClassName] call WL2_fnc_getVehicleWeapons;
    _assetText = format ["%1<br/>%2", _assetText, _vehicleWeapons];

    _buyableMap set [_className, [
        _className,
        _cost,
        _requirements,
        _displayName,
        _picture,
        _assetText,
        _offset
    ]];

    private _sortingCategory = _sortingData # _categoryIndex;
    _sortingCategory pushBack [
        _cost,
        _className
    ];
} forEach _assetData;

private _purchaseable = [];
{
    private _sortingCategory = _x;
    _sortingCategory sort true;

    private _buyData = _sortingCategory apply {
        _buyableMap getOrDefault [_x # 1, []];
    };
    _purchaseable pushBack _buyData;
} forEach _sortingData;

private _buildABear = [
    "BuildABear",
    300,
    [],
    "Customized Unit",
    "\A3\Data_F_Warlords\Data\preview_loadout.jpg",
    "Buy infantry with your customized loadout."
];
private _infantryIndex = _categories find "Infantry";
private _infantryArray = _purchaseable # _infantryIndex;
_infantryArray insert [0, [_buildABear]];

private _callCombatAir = [
    "NearestCombatAir",
    WL_COST_COMBATAIR,
    [],
    localize "STR_WL_combatAirPatrol",
    "a3\ui_f_jets\data\gui\cfg\hints\aircraftdamage_ca.paa",
    localize "STR_WL_combatAirPatrolInfo"
];
private _callCombatAirHome = [
    "CombatAirHome",
    WL_COST_COMBATAIR / 5,
    [],
    localize "STR_WL_combatAirPatrolHome",
    "a3\ui_f_jets\data\gui\cfg\hints\aircraftdamage_ca.paa",
    "Establish a temporary no-fly zone to assist your team's air defense over your home base."
];
private _helpAA = [
    "HelpAA",
    0,
    ["V"],
    "How does AA work?",
    "a3\ui_f_jets\data\gui\cfg\hints\aircraftdamage_ca.paa",
    "See AA help."
];
private _airDefenseIndex = _categories find "Air Defense";
private _airDefenseArray = _purchaseable # _airDefenseIndex;
_airDefenseArray pushBack _callCombatAir;
_airDefenseArray pushBack _callCombatAirHome;
_airDefenseArray insert [0, [_helpAA]];

private _arsenal = [
    "Arsenal",
    WL_COST_ARSENAL,
    [],
    localize "STR_A3_Arsenal",
    "\A3\Data_F_Warlords\Data\preview_arsenal.jpg",
    localize "STR_A3_WL_arsenal_open"
];
private _gearIndex = _categories find "Gear";
private _gearArray = _purchaseable # _gearIndex;
_gearArray insert [0, [_arsenal]];

_purchaseable;