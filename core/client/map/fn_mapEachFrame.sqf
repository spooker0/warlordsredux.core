#include "includes.inc"
if (!visibleMap) exitWith {};
private _map = uiNamespace getVariable ["BIS_WL_mapControl", controlNull];
if (isNull _map) exitWith {};

private _ctrlMap = ctrlParent _map;

private _radius = ((ctrlMapScale _map) * 500) max 5;
private _pos = _map ctrlMapScreenToWorld getMousePosition;

private _drawIconsSelectable = uiNamespace getVariable ["WL2_drawIconsSelectable", []];
private _nearbyAssets = _drawIconsSelectable select {
    private _assetPos = _x # 1;
    (_assetPos distance2D _pos) < _radius
};
_nearbyAssets = [_nearbyAssets, [_pos], { _input0 distance2D (_x # 1) }, "ASCEND"] call BIS_fnc_sortBy;

if (count _nearbyAssets > 0) then {
    WL_AssetActionTargets = _nearbyAssets apply { _x # 0 };
} else {
    WL_AssetActionTargets = [];
};

if (isNull (findDisplay 160 displayCtrl 51)) then {
    _mapScale = ctrlMapScale WL_CONTROL_MAP;
    private _pulseFrequency = 1;
    private _pulseIconSize = 1.5;
    _timer = (serverTime % _pulseFrequency);
    _timer = if (_timer <= (_pulseFrequency / 2)) then {_timer} else {_pulseFrequency - _timer};
    _markerSize = linearConversion [0, _pulseFrequency / 2, _timer, 1, _pulseIconSize];
    _markerSizeArr = [_markerSize, _markerSize];

    {
        _x setMarkerSizeLocal [40 * _mapScale * BIS_WL_mapSizeIndex, (markerSize _x) # 1];
    } forEach BIS_WL_sectorLinks;

    {
        if !(_x in BIS_WL_selection_availableSectors) then {
            ((_x getVariable "BIS_WL_markers") # 0) setMarkerSizeLocal [1, 1];
        } else {
            if (_x == BIS_WL_targetVote) then {
                ((_x getVariable "BIS_WL_markers") # 0) setMarkerSizeLocal [_pulseIconSize, _pulseIconSize];
            } else {
                ((_x getVariable "BIS_WL_markers") # 0) setMarkerSizeLocal _markerSizeArr;
            };
        };
    } forEach BIS_WL_allSectors;
};

private _nearbySectors = BIS_WL_allSectors select {
    _x distance2D _pos < _radius
};
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

    uiNamespace setVariable ["WL2_assetTargetSelectedTime", serverTime];
    uiNamespace setVariable ["WL2_mapButtons", createHashMap];

    private _targetsClicked = [];

    if (!isNull WL_SectorActionTarget) then {
        [WL_SectorActionTarget, count _targetsClicked] call WL2_fnc_sectorMapButtons;
        _targetsClicked pushBack WL_SectorActionTarget;
    };

    if (count WL_AssetActionTargets > 0) then {
        {
            [_x, count _targetsClicked] call WL2_fnc_assetMapButtons;
            _targetsClicked pushBack _x;
        } forEach WL_AssetActionTargets;
    };

    private _isDrone = [cameraOn] call WL2_fnc_isDrone;
    if (_isDrone && alive driver cameraOn) then {
        [cameraOn, count _targetsClicked] call WL2_fnc_uavMapButtons;
        _targetsClicked pushBack cameraOn;
    };

    if (cameraOn getVariable ["DIS_selectionIndex", 0] == 1 && uiNamespace getVariable ["DIS_currentTargetingMode", "none"] == "gps") then {
        playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
        private _coordinate = _map ctrlMapScreenToWorld getMousePosition;
        private _cordX = (_coordinate # 0 / 100) toFixed 0;
        private _cordY = (_coordinate # 1 / 100) toFixed 0;
        while {count _cordX < 3} do {
            _cordX = format ["0%1", _cordX];
        };
        while {count _cordY < 3} do {
            _cordY = format ["0%1", _cordY];
        };
        private _cordString = format ["%1%2", _cordX, _cordY];
        cameraOn setVariable ["DIS_gpsCord", _cordString];
    };
    uiNamespace setVariable ["WL2_assetTargetsSelected", _targetsClicked];

    private _totalButtons = 0;
    private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", createHashMap];
    {
        private _menuButtons = _y;
        _totalButtons = _totalButtons + (count _menuButtons);
    } forEach _allMenuButtons;

    if (_totalButtons > 0) then {
        playSoundUI ["clickSoft", 1];

        getMousePosition params ["_mouseX", "_mouseY"];
        private _offsetX = (_mouseX - safeZoneX) / safeZoneW * 100;
        private _offsetY = (_mouseY - safeZoneY) / safeZoneH * 100;

        [_offsetX, _offsetY] spawn WL2_fnc_addMapButtons;
    };

    // exit singleton after mouse release
    waitUntil {
        uiSleep 0.01;
        inputMouse 0 == 0
    };
};

uiNamespace setVariable ["WL2_mapMouseActionSingleton", _singletonScriptHandle];