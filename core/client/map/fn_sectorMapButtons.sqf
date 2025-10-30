#include "includes.inc"
private _display = (findDisplay 12) createDisplay "WL_MapButtonDisplay";
uiNamespace setVariable ["WL2_mapButtonDisplay", _display];

getMousePosition params ["_mouseX", "_mouseY"];

private _offsetX = _mouseX + 0.03;
private _offsetY = _mouseY + 0.04;

private _menuButtons = [];

WL2_TargetButtonSetup = [_display, _menuButtons, _offsetX, _offsetY];

private _sector = uiNamespace getVariable ["WL2_assetTargetSelected", objNull];

private _titleBar = _display ctrlCreate ["RscStructuredText", -1];
_titleBar ctrlSetPosition [_offsetX, _offsetY - 0.05, 0.5, 0.05];
_titleBar ctrlSetBackgroundColor [0.3, 0.3, 0.3, 1];
_titleBar ctrlSetTextColor [0.7, 0.7, 1, 1];
private _sectorName = _sector getVariable ["WL2_name", "Sector"];
_titleBar ctrlSetStructuredText parseText format ["<t align='center' font='PuristaBold'>%1</t>", toUpper _sectorName];
_titleBar ctrlCommit 0;

// Fast Travel Seized Button
private _fastTravelSeizedExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [0, ""] spawn WL2_fnc_executeFastTravel;
};
[
    "FAST TRAVEL",
    _fastTravelSeizedExecute,
    true,
    "fastTravelSeized",
    [
        0,
        "FTSeized",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Home Button
private _fastTravelHomeExecute = {
    params ["_sector"];
    BIS_WL_targetSector = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
    [0, ""] spawn WL2_fnc_executeFastTravel;
};
[
    "FAST TRAVEL HOME",
    _fastTravelHomeExecute,
    true,
    "fastTravelHome",
    [
        0,
        "FTHome",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Stronghold
private _fastTravelStrongholdExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [5, ""] spawn WL2_fnc_executeFastTravel;
};
[
    "FAST TRAVEL STRONGHOLD",
    _fastTravelStrongholdExecute,
    true,
    "fastTravelStrongholdTarget",
    [
        0,
        "StrongholdFT",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Conflict Button
private _fastTravelConflictExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;

    private _fastTravelConflictCall = 1 call WL2_fnc_fastTravelConflictMarker;
    private _marker = _fastTravelConflictCall # 0;
    [1, _marker] call WL2_fnc_executeFastTravel;
    deleteMarkerLocal _marker;

    private _markerText = _fastTravelConflictCall # 1;
    deleteMarkerLocal _markerText;
};
[
    "FAST TRAVEL CONTESTED",
    _fastTravelConflictExecute,
    true,
    "fastTravelConflict",
    [
        WL_COST_FTCONTESTED,
        "FTConflict",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Air Assault Button
private _airAssaultExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;

    private _fastTravelConflictCall = 2 call WL2_fnc_fastTravelConflictMarker;
    private _marker = _fastTravelConflictCall # 0;
    [2, _marker] call WL2_fnc_executeFastTravel;
    deleteMarkerLocal _marker;

    private _markerText = _fastTravelConflictCall # 1;
    deleteMarkerLocal _markerText;
};
[
    "AIR ASSAULT",
    _airAssaultExecute,
    true,
    "airAssault",
    [
        WL_COST_AIRASSAULT,
        "FTAirAssault",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Vehicle Paradrop Button
private _vehicleParadropExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [3, ""] call WL2_fnc_executeFastTravel;
};
[
    "VEHICLE PARADROP",
    _vehicleParadropExecute,
    true,
    "vehicleParadrop",
    [
        WL_COST_PARADROP,
        "FTParadropVehicle",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Scan Button
private _scanExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [player, "scan", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    "SECTOR SCAN",
    _scanExecute,
    true,
    "scan",
    [
        WL_COST_SCAN,
        "Scan",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

private _playerLevel = ["getLevel"] call WLC_fnc_getLevelInfo;
if (_playerLevel >= 50) then {
    // Mark Sector button
    private _markSectorExecuteLast = {
        params ["_sector"];
        [_sector, false] call WL2_fnc_sectorButtonMark;
    };
    private _markSectorExecuteNext = {
        params ["_sector"];
        [_sector, true] call WL2_fnc_sectorButtonMark;
    };
    [
        ([_sector, BIS_WL_playerSide] call WL2_fnc_sectorButtonMarker) # 0,
        [_markSectorExecuteNext, _markSectorExecuteLast],
        false,
        "markSector"
    ] call WL2_fnc_addTargetMapButton;
};

[_display, _offsetX, _offsetY, _menuButtons] spawn {
    params ["_display", "_originalMouseX", "_originalMouseY", "_menuButtons"];
    private _keepDialog = true;
    private _menuHeight = (count _menuButtons) * 0.05;
    private _startTime = serverTime;
    waitUntil {
        uiSleep 0.1;
        !visibleMap || inputMouse 0 == 0 || serverTime - _startTime > 1;
    };
    while { visibleMap && _keepDialog } do {
        getMousePosition params ["_mouseX", "_mouseY"];

        private _deltaX = _mouseX - _originalMouseX;
        private _deltaY = _mouseY - _originalMouseY;

        if (_deltaX < 0 || _deltaX > 0.5 || _deltaY < -0.05 || _deltaY > _menuHeight) then {
            _keepDialog = inputMouse 0 == 0 && inputMouse 1 == 0;
        };
    };

    waitUntil {
        inputMouse 0 == 0 && inputMouse 1 == 0
    };

    _display closeDisplay 1;
    WL2_TargetButtonSetup = [objNull, [], 0, 0];
};

if (count _menuButtons == 0) then {
    _display closeDisplay 1;
    WL2_TargetButtonSetup = [objNull, [], 0, 0];
};