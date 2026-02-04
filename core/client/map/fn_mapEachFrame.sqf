#include "includes.inc"
if (!visibleMap) exitWith {};
private _map = uiNamespace getVariable ["BIS_WL_mapControl", controlNull];
if (isNull _map) exitWith {};

private _ctrlMap = ctrlParent _map;

private _radius = ((ctrlMapScale _map) * 500) max 5;
private _pos = _map ctrlMapScreenToWorld getMousePosition;

private _drawIconsSelectable = uiNamespace getVariable ["WL2_drawIconsSelectable", []];
private _nearbyAssets = _drawIconsSelectable inAreaArray [_pos, _radius, _radius, 0, false];
_nearbyAssets = [_nearbyAssets, [_pos], { _input0 distance2D _x }, "ASCEND"] call BIS_fnc_sortBy;
WL_AssetActionTargets = _nearbyAssets;

private _mapScale = ctrlMapScale WL_CONTROL_MAP;

private _surrenderWarningActive = uiNamespace getVariable ["WL2_surrenderWarningActive", false];
{
    private _marker = (_x getVariable "BIS_WL_markers") # 0;
    private _currentMarkerSize = if (_x in BIS_WL_selection_availableSectors) then {
        private _pulseFrequency = 1;
        private _pulseIconSize = 1.5;
        private _timer = (serverTime % _pulseFrequency);
        _timer = if (_timer <= (_pulseFrequency / 2)) then {_timer} else {_pulseFrequency - _timer};
        private _markerSize = linearConversion [0, _pulseFrequency / 2, _timer, 1, _pulseIconSize];
        private _markerSizeArr = [_markerSize, _markerSize];

        if (_x == BIS_WL_targetVote) then {
            _markerSizeArr vectorMultiply 1.5;
        } else {
            _markerSizeArr;
        };
    } else {
        [1, 1];
    };

    private _sectorName = _x getVariable ["WL2_name", "Sector"];
    if (_sectorName == "Surrender") then {
        if (_surrenderWarningActive) then {
            _currentMarkerSize = [5, 5];
            _marker setMarkerColorLocal "ColorRed";
        } else {
            _marker setMarkerColorLocal "ColorWhite";
        };
    };

    _marker setMarkerSizeLocal _currentMarkerSize;
} forEach BIS_WL_allSectors;

private _nearbySectors = BIS_WL_allSectors inAreaArray [_pos, _radius, _radius, 0, false];
[_nearbySectors, _map] call WL2_fnc_handleSectorIcons;

if (inputAction "BuldTurbo" > 0) exitWith {};

private _mapButtonDisplay = uiNamespace getVariable ["WL2_mapButtonDisplay", displayNull];
if (!isNull _mapButtonDisplay) exitWith {
    uiNamespace setVariable ["WL2_mapButtonDisplayFirstFrameAfterClose", true];
};
if (dialog) exitWith {};

private _firstFrameAfterClose = uiNamespace getVariable ["WL2_mapButtonDisplayFirstFrameAfterClose", true];

if (inputMouse 0 == 0) exitWith {
    if (_firstFrameAfterClose) then {
        uiNamespace setVariable ["WL2_mapButtonDisplayFirstFrameAfterClose", false];
    };
};

if (_firstFrameAfterClose) exitWith {};

if (WL_SectorActionTarget in BIS_WL_selection_availableSectors) exitWith {};

private _singletonScriptHandle = uiNamespace getVariable ["WL2_mapMouseActionSingleton", scriptNull];
if (!isNull _singletonScriptHandle) exitWith {};

private _singletonScriptHandle = [_map] spawn {
    params ["_map"];
    if (count WL_MapBusy > 0) exitWith {};

    private _display = createDialog ["WL_MapButtonDisplay", true];
    uiNamespace setVariable ["WL2_mapButtonDisplay", _display];

    _display setVariable ["WL2_allButtonsData", []];

    uiNamespace setVariable ["WL2_mapButtons", []];

    private _targetsClicked = [];

    if (!isNull WL_SectorActionTarget) then {
        [WL_SectorActionTarget, count _targetsClicked] call WL2_fnc_sectorMapButtons;
        _targetsClicked pushBack WL_SectorActionTarget;
    };

    private _assetActionTargets = WL_AssetActionTargets;
    if (count _assetActionTargets > 0) then {
        _assetActionTargets = [_assetActionTargets, [], {
            if (_x isKindOf "RuggedTerminal_01_communications_hub_F") then { 0 } else { 1 }
        }, "ASCEND"] call BIS_fnc_sortBy;

        {
            [_x, count _targetsClicked] call WL2_fnc_assetMapButtons;
            _targetsClicked pushBack _x;
        } forEach _assetActionTargets;
    };

    uiNamespace setVariable ["WL2_assetTargetsSelected", _targetsClicked];

    private _hasButtons = false;
    private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", []];
    {
        private _menuButtons = _x # 1;
        if (count _menuButtons > 0) then {
            _hasButtons = true;
        };
    } forEach _allMenuButtons;

    if (_hasButtons) then {
        playSoundUI ["clickSoft", 1];
        [_display] spawn WL2_fnc_addMapButtonsDisplay;
    } else {
        _display closeDisplay 0;
    };

    // exit singleton after mouse release
    waitUntil {
        uiSleep 0.001;
        inputMouse 0 == 0
    };
};

uiNamespace setVariable ["WL2_mapMouseActionSingleton", _singletonScriptHandle];