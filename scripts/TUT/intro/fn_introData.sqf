#include "..\includes.inc"
private _sectorData = createHashMap;
{
    _sectorData set [_x, [_x] call TUT_fnc_sectorData];
} forEach ["Molos", "SkoposCastleRuins", "Airbase", "AirbaseCompound", "MainPower", "LakkaFactory", "SouthTelos", "Anthrakia", "Rodopoli", "Paros"];
if (((values _sectorData) findIf { count _x == 0 }) != -1) exitWith {
    hint localize "STR_WL_introMissingSector";
    createHashMap;
};

private _neighbors = [];
{
    _x params ["_from", "_to"];
    if (_from == "Airbase") then {
        _neighbors pushBackUnique _to;
    };
    if (_to == "Airbase") then {
        _neighbors pushBackUnique _from;
    };
} forEach getArray (missionConfigFile >> "CfgWarlordSectors" >> "connections");
private _links = ["LakkaFactory", "MainPower", "AirbaseCompound"] select { _x in _neighbors };
{
    if (count _links >= 3) then {
        break;
    };
    if (count ([_x] call TUT_fnc_sectorData) > 0) then {
        _links pushBackUnique _x;
    };
} forEach _neighbors;
if (count _links < 3) exitWith {
    hint localize "STR_WL_introMissingConnections";
    createHashMap;
};
{
    _sectorData set [_x, [_x] call TUT_fnc_sectorData];
} forEach _links;

private _assets = [
    ["a3\ui_f\data\map\vehicleicons\iconman_ca.paa", localize "STR_WL_infantry", "+1", 70, 70],
    [getText (configFile >> "CfgVehicles" >> "B_MRAP_01_hmg_F" >> "picture"), localize "STR_WL_introTransport", "+2", 180, 100],
    [getText (configFile >> "CfgVehicles" >> "O_APC_Tracked_02_cannon_F" >> "picture"), localize "STR_WL_introAPC", "+3", 180, 100],
    [getText (configFile >> "CfgVehicles" >> "B_MBT_01_cannon_F" >> "picture"), localize "STR_WL_introTank", "+5", 180, 100]
];

private _captions = [
    [2, "STR_WL_introWelcome"],
    [5, "STR_WL_introObjective"],
    [5, "STR_WL_introCapturing"],
    [3, "STR_WL_introOwners"],
    [5, "STR_WL_introPurchase"],
    [4, "STR_WL_introFastTravel"],
    [6, "STR_WL_introCapturePower"],
    [8, "STR_WL_introConnections"],
    [10, "STR_WL_introRegions"],
    [8.5, "STR_WL_introFrontlineIncome"],
    [6, "STR_WL_introGoodLuck"]
];
private _narration = [] call TUT_fnc_introNarrationData;

private _durations = _narration get "sceneDurations";
private _speechEnds = _narration get "speechEnds";
private _scenes = [];
{
    private _index = _forEachIndex;
    private _endingAt = if (_index == count _captions - 1) then {
        _narration get "endingFlashAt";
    } else {
        -1;
    };
    _scenes pushBack [_durations # _index, localize (_x # 1), _x # 0, _speechEnds # _index, _endingAt];
} forEach _captions;

createHashMapFromArray [
    ["header", localize "STR_WL_introHeader"],
    ["holdToSkip", true],
    ["scenes", _scenes],
    ["narration", [localize "STR_WL_introNarrationSound", 2, 1, false]],
    ["state", createHashMapFromArray [
        ["sectors", _sectorData],
        ["links", _links],
        ["assets", _assets],
        ["incomeData", [_sectorData] call TUT_fnc_introIncomeData],
        ["connectionCutAt", _narration get "connectionCutAt"]
    ]],
    ["enter", TUT_fnc_introEnter],
    ["draw", TUT_fnc_introDrawMap],
    ["update", {
        params ["_display"];
        [_display, "update"] call TUT_fnc_introMenuScene;
    }],
    ["cleanup", {
        params ["_display"];
        [_display, "hide"] call TUT_fnc_introMenuScene;
    }],
    ["completed", {
        0 spawn WL2_fnc_welcome;
    }]
];

