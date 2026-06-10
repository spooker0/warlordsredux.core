#include "includes.inc"
params ["_display"];

private _side = BIS_WL_playerSide;

private _gridBackgroundColor = [SQD_RGBA_DARKER];

private _spawnListY = 0;
private _spawnTileH = SQD_LAYOUT_SPAWN_TILE_H;
private _spawnTileW = _spawnTileH * 0.75;
private _spawnTileStepX = _spawnTileW + SQD_LAYOUT_GRID_BORDER;
private _spawnTileStepY = _spawnTileH + SQD_LAYOUT_GRID_BORDER;

private _spawns = [];

private _travelPriorityResult = [false] call WL2_fnc_travelTeamPriority;
private _alreadyShownSectors = [];
private _alreadyShownPlayers = [];

private _generateSectorSpawns = {
    params ["_sector"];
    _alreadyShownSectors pushBack _sector;

    private _sectorName = _sector getVariable ["WL2_name", "SECTOR"];
    private _sectorAssets = [_sector, [], true] call WL2_fnc_getSectorFTAsset;

    private _specialSpawnables = [];

    private _vehicleAssets = [];
    {
        if (_x isKindOf "Man") then {
            _specialSpawnables pushBack [_x, "squadmate"];
            _alreadyShownPlayers pushBack _x;
        } else {
            _vehicleAssets pushBack _x;
        };
    } forEach _sectorAssets;

    private _canAirAssault = ([_sector, "airAssault"] call WL2_fnc_mapButtonConditions) == "ok";
    if (_canAirAssault) then {
        _specialSpawnables pushBack [_sector, "airAssault"];
    };

    private _canTravelStronghold = ([_sector, "fastTravelStrongholdTarget"] call WL2_fnc_mapButtonConditions) == "ok";
    if (_canTravelStronghold) then {
        _specialSpawnables pushBack [_sector, "stronghold"];
    };

    private _canTravelSeized = ([_sector, "fastTravelSeized"] call WL2_fnc_mapButtonConditions) == "ok";
    if (_canTravelSeized) then {
        _specialSpawnables pushBack [_sector, "seized"];
    };

    [_sectorName, _vehicleAssets, _specialSpawnables];
};

if (_travelPriorityResult) then {
    private _teamPriority = missionNamespace getVariable [format ["WL2_teamPriority_%1", _side], objNull];
    private _teamPriorityType = missionNamespace getVariable [format ["WL2_teamPriorityType_%1", _side], ""];

    switch (_teamPriorityType) do {
        case "asset": {
            _spawns pushBack ["PRIORITY", [_teamPriority] call WL2_fnc_getAssetTypeName, [_teamPriority], []];
        };
        case "fob": {
            _spawns pushBack ["PRIORITY", "FORWARD BASE", [_teamPriority], []];
        };
        case "stronghold": {
            _spawns pushBack ["PRIORITY", "STRONGHOLD", [_teamPriority], []];
        };
        case "sector": {
            private _sectorSpawns = [_teamPriority] call _generateSectorSpawns;
            _spawns pushBack ["PRIORITY", _sectorSpawns # 0, _sectorSpawns # 1, _sectorSpawns # 2];
        };
        case "home": {
            private _sectorSpawns = [_teamPriority] call _generateSectorSpawns;
            _spawns pushBack ["PRIORITY", _sectorSpawns # 0, _sectorSpawns # 1, _sectorSpawns # 2];
        };

        default {};
    };
};

if !(WL_TARGET_FRIENDLY in _alreadyShownSectors) then {
    private _sectorSpawns = [WL_TARGET_FRIENDLY] call _generateSectorSpawns;
    _spawns pushBack ["ATTACK", _sectorSpawns # 0, _sectorSpawns # 1, _sectorSpawns # 2];
};

if !(WL_TARGET_ENEMY in _alreadyShownSectors) then {
    private _sectorSpawns = [WL_TARGET_ENEMY] call _generateSectorSpawns;
    _spawns pushBack ["DEFEND", _sectorSpawns # 0, _sectorSpawns # 1, _sectorSpawns # 2];
};

private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _friendlyFOBs = _forwardBases select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
};
private _forwardBaseSpawns = _friendlyFOBs apply {
    [_x, "fob"]
};
if (count _forwardBaseSpawns > 0) then {
    _spawns pushBack ["FOB", "FORWARD BASES", [], _forwardBaseSpawns];
};

private _squadmates = ["getSquadmates", [getPlayerID player, false]] call SQD_fnc_query;
private _eligibleSquadmates = _squadmates select {
    !(_x in _alreadyShownPlayers);
} select {
    ([_x, "fastTravelSquad"] call WL2_fnc_mapButtonConditions) == "ok";
};
if (count _eligibleSquadmates > 0) then {
    private _squadmateSpawns = _eligibleSquadmates apply {
        [_x, "squadmate"]
    };
    _spawns pushBack ["SQUAD", "SQUADMATES", [], _squadmateSpawns];
};

private _homeBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
if !(_homeBase in _alreadyShownSectors) then {
    private _homeSectorName = _homeBase getVariable ["WL2_name", "SECTOR"];
    _spawns pushBack ["HOME", _homeSectorName, [], [[_homeBase, "home"]]];
};

private _spawnListGroup = _display displayCtrl SQD_SPAWN_LIST_IDC;
private _spawnListPosition = ctrlPosition _spawnListGroup;
private _spawnListW = _spawnListPosition # 2;

private _spawnControls = _display getVariable ["SQD_spawnControls", createHashMap];
_display setVariable ["SQD_spawnControls", _spawnControls];

private _seenSpawnSections = createHashMap;

private _selectedSpawnTarget = missionNamespace getVariable ["SQD_selectedSpawnTarget", objNull];
private _selectedSpecialSpawnTarget = missionNamespace getVariable ["SQD_selectedSpecialSpawnTarget", [objNull, ""]];
if (isNull _selectedSpawnTarget && isNull (_selectedSpecialSpawnTarget # 0)) then {
    _selectedSpecialSpawnTarget = [_homeBase, "home"];
    missionNamespace setVariable ["SQD_selectedSpecialSpawnTarget", _selectedSpecialSpawnTarget];
};

{
    _x params ["_action", "_sectorName", "_spawnables", "_specialSpawnables"];

    _spawnables = _spawnables select { alive _x };

    private _spawnableCount = count _spawnables + count _specialSpawnables;
    if (_spawnableCount == 0) then {
        continue;
    };

    private _sectionKey = _sectorName;
    _seenSpawnSections set [_sectionKey, true];

    private _spawnEntry = _spawnControls getOrDefault [_sectionKey, createHashMap];

    private _spawnBar = _spawnEntry getOrDefault ["bar", controlNull];

    if (isNull _spawnBar) then {
        _spawnBar = _display ctrlCreate ["SQD_Menu_SpawnBar", -1, _spawnListGroup];

        _spawnEntry set ["bar", _spawnBar];
        _spawnEntry set ["tiles", createHashMap];
        _spawnEntry set ["tileBorders", createHashMap];

        _spawnControls set [_sectionKey, _spawnEntry];
    };

    _spawnBar ctrlSetPosition [
        0,
        _spawnListY,
        SQD_LAYOUT_PANEL_W,
        SQD_LAYOUT_HEADER_H
    ];
    _spawnBar ctrlCommit 0;

    private _spawnActionText = _spawnBar controlsGroupCtrl SQD_SPAWN_ACTION_IDC;
    _spawnActionText ctrlSetText toUpper _action;

    private _spawnNameText = _spawnBar controlsGroupCtrl SQD_SPAWN_NAME_IDC;
    private _spawnNameStructured = [toUpper _sectorName, SQD_LAYOUT_LABEL_TEXT_SIZE, SQD_COLOR_TEXT, "left"] call SQD_fnc_renderText;
    _spawnNameText ctrlSetStructuredText _spawnNameStructured;

    private _maxColumns = floor ((_spawnListW - SQD_LAYOUT_GRID_BORDER) / _spawnTileStepX);
    _maxColumns = _maxColumns max 1;

    private _columnCount = _spawnableCount min _maxColumns;
    private _rowCount = ceil (_spawnableCount / _maxColumns);

    private _gridY = _spawnListY + SQD_LAYOUT_HEADER_H;
    private _gridH = SQD_LAYOUT_GRID_BORDER + (_rowCount * _spawnTileStepY);

    // Compatibility cleanup for entries pooled by the previous version,
    // which used one section-wide grid background instead of per-tile borders.
    private _oldSpawnGridBorder = _spawnEntry getOrDefault ["gridBorder", controlNull];
    if (!isNull _oldSpawnGridBorder) then {
        ctrlDelete _oldSpawnGridBorder;
        _spawnEntry deleteAt "gridBorder";
    };

    private _spawnTiles = _spawnEntry getOrDefault ["tiles", createHashMap];
    private _spawnTileBorders = _spawnEntry getOrDefault ["tileBorders", createHashMap];
    private _seenSpawnTargets = createHashMap;

    private _tileItems = [];

    {
        private _specialSpawnTarget = _x;
        _specialSpawnTarget params ["_specialSpawnObject", "_specialSpawnType"];

        private _specialSpawnObjectKey = netId _specialSpawnObject;
        private _specialSpawnTargetKey = format ["special:%1:%2", _specialSpawnObjectKey, _specialSpawnType];

        if (_specialSpawnObjectKey isEqualTo "") then {
            continue;
        };

        private _specialSpawnInfo = switch (_specialSpawnType) do {
            case "airAssault": {
                ["AIR ASSAULT", "a3\ui_f\data\map\vehicleicons\iconparachute_ca.paa"]
            };
            case "seized": {
                ["RANDOM", "a3\ui_f\data\map\markers\military\unknown_ca.paa"]
            };
            case "stronghold": {
                ["STRONGHOLD", "A3\ui_f\data\map\mapcontrol\Ruin_CA.paa"]
            };
            case "fob": {
                private _nearbySectors = BIS_WL_allSectors select {
                    _x distance2D _specialSpawnObject < WL_FOB_MIN_DISTANCE
                };
                private _icon = "A3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_requestLeadership_ca.paa";
                if (count _nearbySectors > 0) then {
                    _nearbySectors = [_nearbySectors, [_specialSpawnObject], { _x distance2D _input0 }, "ASCEND"] call BIS_fnc_sortBy;
                    private _nearestSector = _nearbySectors # 0;
                    private _nearestSectorName = _nearestSector getVariable ["WL2_name", "SECTOR"];
                    [format ["NEAR %1", toUpper _nearestSectorName], _icon]
                } else {
                    ["WILDERNESS", _icon]
                };
            };
            case "home": {
                ["HOME BASE", "A3\ui_f_orange\data\cfgmarkers\redcrystal_ca.paa"]
            };
            case "squadmate": {
                private _squadmateName = if (alive _specialSpawnObject) then {
                    toUpper name _specialSpawnObject
                } else {
                    "???"
                };
                [_squadmateName, "a3\ui_f\data\gui\rsc\rscdisplaymain\profile_player_ca.paa"]
            };
            default {
                [toUpper _specialSpawnType, "a3\ui_f\data\map\markers\military\unknown_ca.paa"]
            };
        };

        _specialSpawnInfo params ["_specialSpawnName", "_specialSpawnIcon"];

        _tileItems pushBack [
            _specialSpawnTargetKey,
            count _tileItems,
            _specialSpawnName,
            _specialSpawnIcon,
            _specialSpawnTarget isEqualTo _selectedSpecialSpawnTarget,
            objNull,
            _specialSpawnTarget
        ];
    } forEach _specialSpawnables;

    {
        private _spawnTarget = _x;

        private _spawnTargetKey = format ["asset:%1", netId _spawnTarget];
        if (_spawnTargetKey isEqualTo "asset:") then {
            continue;
        };

        private _spawnIcon = getText (configFile >> "CfgVehicles" >> typeof _spawnTarget >> "picture");
        if (_spawnIcon in ["pictureThing", "pictureStaticObject"]) then {
            _spawnIcon = getText (configFile >> "CfgVehicles" >> typeof _spawnTarget >> "editorPreview");
        };

        _tileItems pushBack [
            _spawnTargetKey,
            count _tileItems,
            [_spawnTarget] call WL2_fnc_getAssetTypeShortName,
            _spawnIcon,
            _spawnTarget isEqualTo _selectedSpawnTarget,
            _spawnTarget,
            [objNull, ""]
        ];
    } forEach _spawnables;

    {
        _x params [
            "_spawnTargetKey",
            "_tileIndex",
            "_spawnName",
            "_spawnIcon",
            "_isSelected",
            "_spawnTarget",
            "_specialSpawnTarget"
        ];

        _seenSpawnTargets set [_spawnTargetKey, true];

        private _column = _tileIndex % _maxColumns;
        private _row = floor (_tileIndex / _maxColumns);

        private _tileX = SQD_LAYOUT_GRID_BORDER + (_spawnTileStepX * _column);
        private _tileY = _gridY + SQD_LAYOUT_GRID_BORDER + (_spawnTileStepY * _row);

        private _borderX = _tileX - SQD_LAYOUT_GRID_BORDER;
        private _borderY = _tileY - (SQD_LAYOUT_GRID_BORDER * 2);
        private _borderW = _spawnTileW + (SQD_LAYOUT_GRID_BORDER * 2);
        private _borderH = _spawnTileH + (SQD_LAYOUT_GRID_BORDER * 3);

        private _spawnTileBorder = _spawnTileBorders getOrDefault [_spawnTargetKey, controlNull];
        private _spawnTile = _spawnTiles getOrDefault [_spawnTargetKey, controlNull];

        // Border must be created before the tile so it stays behind.
        if (isNull _spawnTileBorder) then {
            if (!isNull _spawnTile) then {
                ctrlDelete _spawnTile;
                _spawnTile = controlNull;
                _spawnTiles deleteAt _spawnTargetKey;
            };

            _spawnTileBorder = _display ctrlCreate ["RscText", -1, _spawnListGroup];
            _spawnTileBorder ctrlSetBackgroundColor _gridBackgroundColor;
            _spawnTileBorder ctrlCommit 0;

            _spawnTileBorders set [_spawnTargetKey, _spawnTileBorder];
        };

        if (isNull _spawnTile) then {
            _spawnTile = _display ctrlCreate ["SQD_Menu_SpawnBar_Location", -1, _spawnListGroup];
            _spawnTiles set [_spawnTargetKey, _spawnTile];
        };

        _spawnTileBorder ctrlSetPosition [
            _borderX,
            _borderY,
            _borderW,
            _borderH
        ];
        _spawnTileBorder ctrlSetBackgroundColor _gridBackgroundColor;
        _spawnTileBorder ctrlCommit 0;

        _spawnTile ctrlSetPosition [
            _tileX,
            _tileY,
            _spawnTileW,
            _spawnTileH
        ];
        _spawnTile ctrlCommit 0;

        private _spawnLocationName = _spawnTile controlsGroupCtrl SQD_LOCATION_NAME_IDC;
        _spawnLocationName ctrlSetText _spawnName;
        private _nameColor = if (_isSelected) then {
            [0.5, 0.5, 0.5, 1]
        } else {
            [SQD_RGBA_TEXT]
        };
        _spawnLocationName ctrlSetTextColor _nameColor;

        private _spawnLocationIcon = _spawnTile controlsGroupCtrl SQD_LOCATION_ICON_IDC;
        _spawnLocationIcon ctrlSetText _spawnIcon;

        private _spawnLocationBg = _spawnTile controlsGroupCtrl SQD_LOCATION_BG_IDC;
        private _spawnLocationBgColor = if (_isSelected) then {
            [SQD_RGBA_BG]
        } else {
            _gridBackgroundColor
        };
        _spawnLocationBg ctrlSetBackgroundColor _spawnLocationBgColor;

        private _spawnLocationHeader = _spawnTile controlsGroupCtrl SQD_LOCATION_HEADER_IDC;
        private _headerColor = if (_isSelected) then {
            [0.5, 1, 1, 1]
        } else {
            [SQD_RGBA_DARK]
        };
        _spawnLocationHeader ctrlSetBackgroundColor _headerColor;

        private _spawnButton = _spawnTile controlsGroupCtrl SQD_LOCATION_BUTTON_IDC;
        _spawnButton setVariable ["SQD_spawnTarget", _spawnTarget];
        _spawnButton setVariable ["SQD_specialSpawnTarget", _specialSpawnTarget];

        _spawnButton ctrlRemoveAllEventHandlers "ButtonDown";
        _spawnButton ctrlAddEventHandler ["ButtonDown", SQD_fnc_actionSpawn];
    } forEach _tileItems;

    {
        private _spawnTargetKey = _x;
        private _staleTile = _y;

        if (_spawnTargetKey in _seenSpawnTargets) then {
            continue;
        };

        if (!isNull _staleTile) then {
            ctrlDelete _staleTile;
        };

        private _staleTileBorder = _spawnTileBorders getOrDefault [_spawnTargetKey, controlNull];
        if (!isNull _staleTileBorder) then {
            ctrlDelete _staleTileBorder;
        };

        _spawnTiles deleteAt _spawnTargetKey;
        _spawnTileBorders deleteAt _spawnTargetKey;
    } forEach _spawnTiles;

    // Defensive cleanup for orphaned borders.
    {
        private _spawnTargetKey = _x;
        private _staleTileBorder = _y;

        if (_spawnTargetKey in _seenSpawnTargets) then {
            continue;
        };

        if (!isNull _staleTileBorder) then {
            ctrlDelete _staleTileBorder;
        };

        _spawnTileBorders deleteAt _spawnTargetKey;
    } forEach _spawnTileBorders;

    _spawnEntry set ["tiles", _spawnTiles];
    _spawnEntry set ["tileBorders", _spawnTileBorders];
    _spawnControls set [_sectionKey, _spawnEntry];

    _spawnListY = _gridY + _gridH + SQD_LAYOUT_SECTION_GAP_Y;
} forEach _spawns;

{
    private _sectionKey = _x;
    private _spawnEntry = _y;

    if (_sectionKey in _seenSpawnSections) then {
        continue;
    };

    private _spawnBar = _spawnEntry getOrDefault ["bar", controlNull];
    if (!isNull _spawnBar) then {
        ctrlDelete _spawnBar;
    };

    private _statusTextArea = _spawnEntry getOrDefault ["textArea", controlNull];
    if (!isNull _statusTextArea) then {
        ctrlDelete _statusTextArea;
    };

    private _spawnGridBorder = _spawnEntry getOrDefault ["gridBorder", controlNull];
    if (!isNull _spawnGridBorder) then {
        ctrlDelete _spawnGridBorder;
    };

    private _spawnTileBorders = _spawnEntry getOrDefault ["tileBorders", createHashMap];

    {
        private _spawnTileBorder = _y;

        if (!isNull _spawnTileBorder) then {
            ctrlDelete _spawnTileBorder;
        };
    } forEach _spawnTileBorders;

    private _spawnTiles = _spawnEntry getOrDefault ["tiles", createHashMap];

    {
        private _spawnTile = _y;

        if (!isNull _spawnTile) then {
            ctrlDelete _spawnTile;
        };
    } forEach _spawnTiles;

    _spawnControls deleteAt _sectionKey;
} forEach _spawnControls;

_display setVariable ["SQD_spawnControls", _spawnControls];