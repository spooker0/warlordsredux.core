#include "includes.inc"
private _dialog = (findDisplay 12) createDisplay "WL_MapButtonDisplay";
uiNamespace setVariable ["WL2_mapButtonDisplay", _dialog];

getMousePosition params ["_mouseX", "_mouseY"];

uiNamespace setVariable ["WL2_mapMouseClickPosition", getMousePosition];

private _offsetX = _mouseX + 0.03;
private _offsetY = _mouseY + 0.04;

private _menuButtons = [];

WL2_TargetButtonSetup = [_dialog, _menuButtons, _offsetX, _offsetY];

private _asset = uiNamespace getVariable ["WL2_assetTargetSelected", objNull];

private _titleBar = _dialog ctrlCreate ["RscStructuredText", -1];
_titleBar ctrlSetPosition [_offsetX, _offsetY - 0.05, 0.5, 0.05];
_titleBar ctrlSetBackgroundColor [0.3, 0.3, 0.3, 1];
_titleBar ctrlSetTextColor [0.7, 0.7, 1, 1];
_titleBar ctrlSetStructuredText parseText "<t align='center' font='PuristaBold'>UAV CONTROL</t>";
_titleBar ctrlCommit 0;

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

        format ["TARGET ALTITUDE (%1 M)", _newAlt];
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

        format ["TARGET ALTITUDE (%1 M)", _newAlt];
    };

    private _targetAlt = _asset getVariable ["WL2_assetTargetAlt", 0];
    [
        format ["TARGET ALTITUDE (%1 M)", WL_UAV_ALT_VALUES # _targetAlt],
        [_targetAltExecuteNext, _targetAltExecuteLast],
        false,
        "setTargetAlt"
    ] call WL2_fnc_addTargetMapButton;
};

["MOVE", {
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

["ADD WAYPOINT", {
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

[_dialog, _offsetX, _offsetY, _menuButtons] spawn {
    params ["_dialog", "_originalMouseX", "_originalMouseY", "_menuButtons"];
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

    _dialog closeDisplay 1;
    WL2_TargetButtonSetup = [objNull, [], 0, 0];
};

if (count _menuButtons == 0) then {
    _dialog closeDisplay 1;
    WL2_TargetButtonSetup = [objNull, [], 0, 0];
};