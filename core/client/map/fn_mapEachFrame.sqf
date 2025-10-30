#include "includes.inc"
if (!visibleMap) exitWith {};
private _map = uiNamespace getVariable ["BIS_WL_mapControl", controlNull];
if (isNull _map) exitWith {};

private _ctrlMap = ctrlParent _map;
private _ctrlAssetInfoBox = _ctrlMap getVariable "BIS_assetInfoBox";

private _radius = ((ctrlMapScale _map) * 500) max 3;
private _pos = _map ctrlMapScreenToWorld getMousePosition;

private _drawIconsSelectable = uiNamespace getVariable ["WL2_drawIconsSelectable", []];
private _nearbyAssets = _drawIconsSelectable select {
    private _assetPos = _x # 1;
    (_assetPos distance2D _pos) < _radius
};
_nearbyAssets = [_nearbyAssets, [_pos], { _input0 distance2D (_x # 1) }, "ASCEND"] call BIS_fnc_sortBy;

if (count _nearbyAssets > 0) then {
    WL_AssetActionTarget = _nearbyAssets # 0 # 0;
    _ctrlAssetInfoBox ctrlSetPosition [(getMousePosition # 0) + safeZoneW / 100, (getMousePosition # 1) + safeZoneH / 50, safeZoneW, safeZoneH];
    _ctrlAssetInfoBox ctrlCommit 0;
    _ctrlAssetInfoBox ctrlSetStructuredText parseText format [
        "<t shadow='2' size='%1'>%2</t>",
        1 call WL2_fnc_purchaseMenuGetUIScale,
        format [
            "Click for options:<br/><t color='#ff4b4b'>%1</t>",
            if (isPlayer WL_AssetActionTarget) then {
                name WL_AssetActionTarget
            } else {
                [WL_AssetActionTarget] call WL2_fnc_getAssetTypeName
            }
        ]
    ];
    _ctrlAssetInfoBox ctrlShow true;
    _ctrlAssetInfoBox ctrlEnable true;
} else {
    WL_AssetActionTarget = objNull;
    _ctrlAssetInfoBox ctrlShow false;
    _ctrlAssetInfoBox ctrlEnable false;
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

private _mapButtonDisplay = uiNamespace getVariable ["WL2_mapButtonDisplay", displayNull];
if (!isNull _mapButtonDisplay) exitWith {};

private _mapMouseActionComplete = uiNamespace getVariable ["WL2_mapMouseActionComplete", true];
private _mouseClicked = inputMouse 0 > 0;
if (_mouseClicked && _mapMouseActionComplete && inputAction "BuldTurbo" == 0) then {
    uiNamespace setVariable ["WL2_mapMouseActionComplete", false];
    0 spawn {
        waitUntil {
            inputMouse 0 == 0
        };

        if (count WL_MapBusy > 0) exitWith {
            uiNamespace setVariable ["WL2_mapMouseActionComplete", true];
        };

        uiNamespace setVariable ["WL2_assetTargetSelectedTime", serverTime];

        private _showUavMenu = true;

        if !(isNull WL_AssetActionTarget) then {
            _showUavMenu = false;
            uiNamespace setVariable ["WL2_assetTargetSelected", WL_AssetActionTarget];
            call WL2_fnc_assetMapButtons;
            playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss", 0.15, 1];
        };

        if !(isNull WL_SectorActionTarget) then {
            _showUavMenu = false;
            private _isVotingThisSector = WL_SectorActionTarget in BIS_WL_selection_availableSectors;
            if (!_isVotingThisSector) then {
                uiNamespace setVariable ["WL2_assetTargetSelected", WL_SectorActionTarget];
                call WL2_fnc_sectorMapButtons;
                playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss", 0.15, 1];
            };
        };

        if (_showUavMenu && unitIsUAV cameraOn && alive driver cameraOn) then {
            uiNamespace setVariable ["WL2_assetTargetSelected", cameraOn];
            call WL2_fnc_uavMapButtons;
            playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss", 0.15, 1];
        };

        WL_AssetActionTarget = objNull;
        WL_SectorActionTarget = objNull;

        uiNamespace setVariable ["WL2_mapMouseActionComplete", true];
    };
};