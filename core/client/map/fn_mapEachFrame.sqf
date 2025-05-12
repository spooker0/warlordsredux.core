#include "..\..\warlords_constants.inc"

if (!visibleMap) exitWith {};
private _map = uiNamespace getVariable ["BIS_WL_mapControl", controlNull];
if (isNull _map) exitWith {};

private _ctrlMap = ctrlParent _map;
private _ctrlAssetInfoBox = _ctrlMap getVariable "BIS_assetInfoBox";

private _radius = (((ctrlMapScale _map) * 500) min 30) max 3;
private _pos = _map ctrlMapScreenToWorld getMousePosition;

private _selectableBuildings = [];
{
    private _stronghold = _x getVariable ["WL_stronghold", objNull];
    private _strongholdPos = getPosATL _stronghold;
    private _strongholdDistance = (_strongholdPos distance2D _pos) < _radius;
    if (!isNull _stronghold) then {
        _selectableBuildings pushBack [_stronghold, _strongholdPos];
    };
} forEach (BIS_WL_sectorsArray # 0);

private _drawIconsSelectable = uiNamespace getVariable ["WL2_drawIconsSelectable", []];
private _nearbyAssets = (_drawIconsSelectable + _selectableBuildings) select {
    private _asset = _x # 0;
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
    _timer = (serverTime % WL_MAP_PULSE_FREQ);
    _timer = if (_timer <= (WL_MAP_PULSE_FREQ / 2)) then {_timer} else {WL_MAP_PULSE_FREQ - _timer};
    _markerSize = linearConversion [0, WL_MAP_PULSE_FREQ / 2, _timer, 1, WL_MAP_PULSE_ICON_SIZE];
    _markerSizeArr = [_markerSize, _markerSize];

    {
        _x setMarkerSizeLocal [WL_CONNECTING_LINE_AXIS * _mapScale * BIS_WL_mapSizeIndex, (markerSize _x) # 1];
    } forEach BIS_WL_sectorLinks;

    {
        if !(_x in BIS_WL_selection_availableSectors) then {
            ((_x getVariable "BIS_WL_markers") # 0) setMarkerSizeLocal [1, 1];
        } else {
            if (_x == BIS_WL_targetVote) then {
                ((_x getVariable "BIS_WL_markers") # 0) setMarkerSizeLocal [WL_MAP_PULSE_ICON_SIZE, WL_MAP_PULSE_ICON_SIZE];
            } else {
                ((_x getVariable "BIS_WL_markers") # 0) setMarkerSizeLocal _markerSizeArr;
            };
        };
    } forEach BIS_WL_allSectors;
};

private _mapMouseActionComplete = uiNamespace getVariable ["WL2_mapMouseActionComplete", true];
private _mouseClicked = inputMouse 0 > 0 || inputMouse 1 > 0;
if (_mouseClicked && _mapMouseActionComplete && inputAction "BuldTurbo" == 0) then {
    uiNamespace setVariable ["WL2_mapMouseActionComplete", false];
    0 spawn {
        waitUntil {
            inputMouse 0 == 0 && inputMouse 1 == 0
        };

        if (count WL_MapBusy > 0) exitWith {
            uiNamespace setVariable ["WL2_mapMouseActionComplete", true];
        };

        uiNamespace setVariable ["WL2_assetTargetSelectedTime", serverTime];

        if !(isNull WL_AssetActionTarget) then {
            uiNamespace setVariable ["WL2_assetTargetSelected", WL_AssetActionTarget];
            call WL2_fnc_assetMapButtons;
            playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss", 0.15, 1];
        };

        if !(isNull WL_SectorActionTarget) then {
            private _isVotingThisSector = WL_SectorActionTarget in BIS_WL_selection_availableSectors;
            if (!_isVotingThisSector) then {
                uiNamespace setVariable ["WL2_assetTargetSelected", WL_SectorActionTarget];
                call WL2_fnc_sectorMapButtons;
                playSoundUI ["a3\ui_f\data\sound\rscbutton\soundclick.wss", 0.15, 1];
            };
        };

        WL_AssetActionTarget = objNull;
        WL_SectorActionTarget = objNull;

        uiNamespace setVariable ["WL2_mapMouseActionComplete", true];
    };
};