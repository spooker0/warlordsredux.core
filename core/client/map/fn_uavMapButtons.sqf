#include "includes.inc"
private _menuButtons = createHashMap;
uiNamespace setVariable ["WL2_mapButtons", _menuButtons];

getMousePosition params ["_mouseX", "_mouseY"];
uiNamespace setVariable ["WL2_mapMouseClickPosition", getMousePosition];
private _asset = uiNamespace getVariable ["WL2_assetTargetSelected", objNull];

if (_asset isKindOf "Air") then {
    private _targetAltExecuteNext = {
        params ["_asset"];
        private _currentAlt = _asset getVariable ["WL2_assetTargetAlt", 0];
        private _newAlt = (_currentAlt + 1) % count WL_UAV_ALT_VALUES;
        _asset setVariable ["WL2_assetTargetAlt", _newAlt];

        _newAlt = WL_UAV_ALT_VALUES # _newAlt;
        [_asset, _newAlt] spawn {
            params ["_asset", "_newAlt"];
            waitUntil {
                uiSleep 5;
                private _position = _asset modelToWorld [0, 0, 0];
                _position # 2 > 50 || !alive _asset;
            };

            _asset flyInHeight [_newAlt, true];
        };

        {
            private _waypointPosition = waypointPosition _x;
            _waypointPosition set [2, _newAlt];
            _x setWaypointPosition [AGLtoASL _waypointPosition, -1];
        } forEach (waypoints group _asset);

        format ["Target altitude: %1m", _newAlt];
    };
    private _targetAltExecuteLast = {
        params ["_asset"];
        private _currentAlt = _asset getVariable ["WL2_assetTargetAlt", 0];
        private _newAlt = _currentAlt - 1;
        if (_newAlt < 0) then {
            _newAlt = (count WL_UAV_ALT_VALUES) - 1;
        };
        _asset setVariable ["WL2_assetTargetAlt", _newAlt];

        _newAlt = WL_UAV_ALT_VALUES # _newAlt;
        [_asset, _newAlt] spawn {
            params ["_asset", "_newAlt"];
            waitUntil {
                uiSleep 5;
                private _position = _asset modelToWorld [0, 0, 0];
                _position # 2 > 50 || !alive _asset;
            };

            _asset flyInHeight [_newAlt, true];
        };

        {
            private _waypointPosition = waypointPosition _x;
            _waypointPosition set [2, _newAlt];
            _x setWaypointPosition [AGLtoASL _waypointPosition, -1];
        } forEach (waypoints group _asset);

        format ["Target altitude: %1m", _newAlt];
    };

    private _targetAlt = _asset getVariable ["WL2_assetTargetAlt", 0];
    [
        "target-altitude",
        format ["Target altitude: %1m", WL_UAV_ALT_VALUES # _targetAlt],
        [_targetAltExecuteNext, _targetAltExecuteLast],
        false,
        "setTargetAlt"
    ] call WL2_fnc_addTargetMapButton;
};

["move", "Move", {
    params ["_asset"];
    [_asset] spawn {
        params ["_asset"];
        private _mouseClickPos = uiNamespace getVariable ["WL2_mapMouseClickPosition", [0.5, 0.5]];
        private _worldPos = WL_CONTROL_MAP ctrlMapScreenToWorld _mouseClickPos;

        private _altIndex = _asset getVariable ["WL2_assetTargetAlt", 0];
        private _assetTargetAlt = WL_UAV_ALT_VALUES # _altIndex;
        _worldPos set [2, _assetTargetAlt];

        private _assetGroup = group _asset;
        private _waypoints = waypoints _assetGroup;
        {
            deleteWaypoint _x;
        } forEachReversed _waypoints;

        private _newWaypoint = _assetGroup addWaypoint [_worldPos, 0];
        _newWaypoint setWaypointType "MOVE";
    };
}, true] call WL2_fnc_addTargetMapButton;

["add-waypoint", "Add waypoint", {
    params ["_asset"];
    private _mouseClickPos = uiNamespace getVariable ["WL2_mapMouseClickPosition", [0.5, 0.5]];
    private _worldPos = WL_CONTROL_MAP ctrlMapScreenToWorld _mouseClickPos;

    private _altIndex = _asset getVariable ["WL2_assetTargetAlt", 0];
    private _assetTargetAlt = WL_UAV_ALT_VALUES # _altIndex;
    _worldPos set [2, _assetTargetAlt];

    private _assetGroup = group _asset;

    private _newWaypoint = _assetGroup addWaypoint [_worldPos, 0];
    _newWaypoint setWaypointType "MOVE";
}, true] call WL2_fnc_addTargetMapButton;

if (count _menuButtons > 0) then {
    private _offsetX = (_mouseX - safeZoneX) / safeZoneW * 100;
    private _offsetY = (_mouseY - safeZoneY) / safeZoneH * 100;

    ["UAV CONTROL", _offsetX, _offsetY] spawn WL2_fnc_addMapButtons;
};