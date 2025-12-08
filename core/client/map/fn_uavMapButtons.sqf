#include "includes.inc"
params ["_asset", "_targetId"];
_asset setVariable ["WL2_mapButtonText", [_asset] call WL2_fnc_getAssetTypeName];

getMousePosition params ["_mouseX", "_mouseY"];
uiNamespace setVariable ["WL2_mapMouseClickPosition", getMousePosition];

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
        _asset, _targetId,
        "target-altitude",
        format ["Target altitude: %1m", WL_UAV_ALT_VALUES # _targetAlt],
        [_targetAltExecuteNext, _targetAltExecuteLast],
        false,
        "setTargetAlt"
    ] call WL2_fnc_addTargetMapButton;
};

[_asset, _targetId, "move", "Move", {
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

[_asset, _targetId, "add-waypoint", "Add waypoint", {
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

[_asset, _targetId, "loiter", "Loiter", {
    params ["_asset"];
    [_asset] spawn {
        params ["_asset"];
        private _mouseClickPos = uiNamespace getVariable ["WL2_mapMouseClickPosition", [0.5, 0.5]];
        private _worldPos = WL_CONTROL_MAP ctrlMapScreenToWorld _mouseClickPos;

        private _altIndex = _asset getVariable ["WL2_assetTargetAlt", 0];
        private _assetTargetAlt = WL_UAV_ALT_VALUES # _altIndex;
        _worldPos set [2, _assetTargetAlt];

        private _loiterRadiusIndex = _asset getVariable ["WL2_assetLoiterRadius", 0];
        private _assetLoiterRadius = WL_UAV_LOITER_VALUES # _loiterRadiusIndex;

        private _assetGroup = group _asset;

        private _newWaypoint = _assetGroup addWaypoint [_worldPos, 0];
        _newWaypoint setWaypointType "LOITER";
        _newWaypoint setWaypointLoiterType "CIRCLE";
        _newWaypoint setWaypointLoiterRadius _assetLoiterRadius;
    };
}, true] call WL2_fnc_addTargetMapButton;

private _loiterRadiusExecuteNext = {
    params ["_asset"];
    private _currentLoiterRadius = _asset getVariable ["WL2_assetLoiterRadius", 0];
    private _newLoiter = (_currentLoiterRadius + 1) % count WL_UAV_LOITER_VALUES;
    _asset setVariable ["WL2_assetLoiterRadius", _newLoiter];

    _newLoiter = WL_UAV_LOITER_VALUES # _newLoiter;
    format ["Loiter radius: %1m", _newLoiter];
};
private _loiterRadiusExecuteLast = {
    params ["_asset"];
    private _currentLoiterRadius = _asset getVariable ["WL2_assetLoiterRadius", 0];
    private _newLoiter = _currentLoiterRadius - 1;
    if (_newLoiter < 0) then {
        _newLoiter = (count WL_UAV_LOITER_VALUES) - 1;
    };
    _asset setVariable ["WL2_assetLoiterRadius", _newLoiter];
};

private _targetLoiterRadius = _asset getVariable ["WL2_assetLoiterRadius", 0];
[
    _asset, _targetId,
    "target-loiter-radius",
    format ["Loiter radius: %1m", WL_UAV_LOITER_VALUES # _targetLoiterRadius],
    [_loiterRadiusExecuteNext, _loiterRadiusExecuteLast],
    false,
    "setLoiterRadius"
] call WL2_fnc_addTargetMapButton;

[_asset, _targetId, "cycle-waypoint", "Cycle waypoint", {
    params ["_asset"];
    private _mouseClickPos = uiNamespace getVariable ["WL2_mapMouseClickPosition", [0.5, 0.5]];
    private _worldPos = WL_CONTROL_MAP ctrlMapScreenToWorld _mouseClickPos;

    private _assetGroup = group _asset;

    private _newWaypoint = _assetGroup addWaypoint [_worldPos, 0];
    _newWaypoint setWaypointType "CYCLE";
}, true] call WL2_fnc_addTargetMapButton;