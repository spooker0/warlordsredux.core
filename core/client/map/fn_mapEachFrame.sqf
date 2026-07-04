#include "includes.inc"
params ["_map"];
private _mapScale = ctrlMapScale _map;

private _radius = (_mapScale * 500) max 5;
private _mousePosition = getMousePosition;
private _pos = _map ctrlMapScreenToWorld _mousePosition;

private _drawIconsSelectable = uiNamespace getVariable ["WL2_drawIconsSelectable", []];
private _nearbyAssets = _drawIconsSelectable inAreaArray [_pos, _radius, _radius, 0, false];
WL_AssetActionTargets = _nearbyAssets;

private _serverTime = serverTime % 1;
private _targetVote = BIS_WL_targetVote;

private _nearbyArea = [_pos, _radius, _radius, 0, false];
private _nearbySectors = [];

private _timedMarkerSize = -1;
{
    private _marker = (_x getVariable "BIS_WL_markers") # 0;
    private _currentMarkerSize = if (_x getVariable ["WL2_sectorSelectionAvailable", false]) then {
        if (_timedMarkerSize == -1) then {
            private _timer = if (_serverTime <= 0.5) then {
                _serverTime
            } else {
                1 - _serverTime
            };
            private _markerSize = linearConversion [0, 0.5, _timer, 1, 1.5];
            _timedMarkerSize = _markerSize;
        };

        [_timedMarkerSize, _timedMarkerSize];
    } else {
        if (_mapScale > 0.4) then {
            [0.75, 0.75];
        } else {
            [1, 1];
        };
    };

    if (_x == _targetVote) then {
        _currentMarkerSize = _currentMarkerSize vectorMultiply 1.5;
    };

    if (_x in WL_BASES) then {
        _currentMarkerSize = _currentMarkerSize vectorMultiply 1.3;
    };

    _marker setMarkerSizeLocal _currentMarkerSize;

    if (_x inArea _nearbyArea) then {
        _nearbySectors pushBack _x;
    };
} forEach BIS_WL_allSectors;
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

private _sectorClickSingletonScriptHandle = uiNamespace getVariable ["WL2_mapSectorIconSingleton", scriptNull];
if (!isNull _sectorClickSingletonScriptHandle) exitWith {};

private _singletonScriptHandle = uiNamespace getVariable ["WL2_mapMouseActionSingleton", scriptNull];
if (!isNull _singletonScriptHandle) exitWith {};

private _singletonScriptHandle = [_map, _mousePosition] spawn {
    params ["_map", "_mousePosition"];
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
        _assetActionTargets = [_assetActionTargets, [_mousePosition], {
            if (_x isKindOf "RuggedTerminal_01_communications_hub_F") then { 0 } else {
                _input0 distance _x
            }
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
        [_display, _mousePosition] call WL2_fnc_addMapButtonsDisplay;
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