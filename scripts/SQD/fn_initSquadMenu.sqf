#include "includes.inc"

if (isDedicated) exitWith {};

private _existingDisplay = findDisplay SQD_MENU_IDD;
if (!isNull _existingDisplay) exitWith {};

// private _display = createDialog ["SQD_Menu", true];
private _display = (findDisplay 46) createDisplay "SQD_Menu";

uiNamespace setVariable ["SQD_Menu", _display];

private _dynamicBlurHandle = ppEffectCreate ["DynamicBlur", SQD_LAYOUT_BLUR_ID];
_dynamicBlurHandle ppEffectEnable true;
_dynamicBlurHandle ppEffectAdjust [3];
_dynamicBlurHandle ppEffectCommit 0;

_display setVariable ["SQD_dynamicBlurHandle", _dynamicBlurHandle];

_display displayAddEventHandler ["Unload", {
    params ["_display"];

    private _dynamicBlurHandle = _display getVariable ["SQD_dynamicBlurHandle", -1];
    if (_dynamicBlurHandle != -1) then {
        ppEffectDestroy _dynamicBlurHandle;
        _display setVariable ["SQD_dynamicBlurHandle", -1];
    };
}];

[_display] call SQD_fnc_renderSquads;
[_display] call SQD_fnc_renderSpawns;
[_display] call SQD_fnc_renderStatus;
[_display] call SQD_fnc_renderVehicles;

_display displayAddEventHandler ["KeyDown", WL2_fnc_timedPromptKeyHandler];

private _spawnCamButton = _display displayCtrl SQD_SPAWN_SCREEN_BUTTON_IDC;
private _camFeedState = missionNamespace getVariable ["SQD_menuCamFeedEnabled", true];
if (_camFeedState) then {
    _spawnCamButton ctrlSetText "DISABLE FEED";
} else {
    _spawnCamButton ctrlSetText "ENABLE FEED";
};
_spawnCamButton setVariable ["SQD_controlState", _camFeedState];
_spawnCamButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _controlState = _control getVariable ["SQD_controlState", false];
    _controlState = !_controlState;
    missionNamespace setVariable ["SQD_menuCamFeedEnabled", _controlState];
    _control setVariable ["SQD_controlState", _controlState];
    if (_controlState) then {
        private _selectedSpawnTarget = missionNamespace getVariable ["SQD_selectedSpawnTarget", objNull];
        private _selectedSpecialSpawnTarget = missionNamespace getVariable ["SQD_selectedSpecialSpawnTarget", [objNull, ""]];
        [_selectedSpawnTarget, _selectedSpecialSpawnTarget] call SQD_fnc_setSpawnCam;

        _control ctrlSetText "DISABLE FEED";
    } else {
        [objNull, [objNull, ""]] call SQD_fnc_setSpawnCam;

        _control ctrlSetText "ENABLE FEED";
    };

    private _display = ctrlParent _control;
    private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
    ctrlSetFocus _dummyButton;
}];

private _spawnCamTIButton = _display displayCtrl SQD_SPAWN_SCREEN_TI_BUTTON_IDC;
private _camTIState = missionNamespace getVariable ["SQD_menuCamTIEnabled", false];
if (_camTIState) then {
    _spawnCamTIButton ctrlSetText "DISABLE TI";
} else {
    _spawnCamTIButton ctrlSetText "ENABLE TI";
};
_spawnCamTIButton setVariable ["SQD_controlState", _camTIState];
_spawnCamTIButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _controlState = _control getVariable ["SQD_controlState", false];
    _controlState = !_controlState;
    missionNamespace setVariable ["SQD_menuCamTIEnabled", _controlState];
    _control setVariable ["SQD_controlState", _controlState];
    if (_controlState) then {
        _control ctrlSetText "DISABLE TI";
        "spawncam" setPiPEffect [2];
    } else {
        _control ctrlSetText "ENABLE TI";
        "spawncam" setPiPEffect [0];
    };

    private _display = ctrlParent _control;
    private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
    ctrlSetFocus _dummyButton;
}];

private _selectedSpawnTarget = missionNamespace getVariable ["SQD_selectedSpawnTarget", objNull];
private _selectedSpecialSpawnTarget = missionNamespace getVariable ["SQD_selectedSpecialSpawnTarget", [objNull, ""]];
[_selectedSpawnTarget, _selectedSpecialSpawnTarget] call SQD_fnc_setSpawnCam;

_display setVariable ["SQD_startMenuTime", time];
_display displayAddEventHandler ["KeyUp", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    private _squadNameEdit = _display getVariable ["SQD_squadNameEdit", controlNull];
    if (!isNull _squadNameEdit) exitWith {};

    private _startMenuTime = _display getVariable ["SQD_startMenuTime", 0];
    if (time < _startMenuTime + 0.5) exitWith {};

    private _isPressed = false;
    {
        _isPressed = _isPressed || [_x, _key, _shift, _ctrl, _alt] call WL2_fnc_isKeyPressed;
    } forEach actionKeys ["watch"];
    if (_isPressed) then {
        _display closeDisplay 0;
    };
}];

_display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

    private _menuToUse = _display getVariable ["SQD_squadNameEdit", controlNull];
    if (isNull _menuToUse) then {
        _menuToUse = _display getVariable ["SQD_contextMenu", controlNull];
    };

    if (isNull _menuToUse) exitWith {};

    private _menuPosition = ctrlPosition _menuToUse;

    private _controlClass = ctrlClassName _menuToUse;
    if (_controlClass == "SquadBar_Name_Edit") then {
        private _squadBarGroup = ctrlParentControlsGroup _menuToUse;
        private _squadListGroup = ctrlParentControlsGroup _squadBarGroup;
        private _parentPosition = ctrlPosition _squadListGroup;
        _menuPosition set [0, _menuPosition # 0 + _parentPosition # 0];
        _menuPosition set [1, _menuPosition # 1 + _parentPosition # 1];
    };

    private _menuMinX = _menuPosition # 0;
    private _menuMaxX = _menuMinX + (_menuPosition # 2);
    private _menuMinY = _menuPosition # 1;
    private _menuMaxY = _menuMinY + (_menuPosition # 3);

    if (_xPos < _menuMinX || _xPos > _menuMaxX || _yPos < _menuMinY || _yPos > _menuMaxY) then {
        if (_controlClass == "SquadBar_Name_Edit") then {
            _display setVariable ["SQD_squadNameEdit", controlNull];
            [_display] call SQD_fnc_renderSquads;
        } else {
            ctrlDelete _menuToUse;
        };
    };
}];

private _refreshConfig = [
    [SQD_fnc_renderStatus, 0.05, 0],
    [SQD_fnc_renderSquads, 0.05, 0],
    [SQD_fnc_renderSpawns, 1, 0],
    [SQD_fnc_renderVehicles, 0.2, 0]
];

while { !isNull _display } do {
    {
        _x params ["_refreshFunction", "_interval", "_lastCall"];
        if (time > _lastCall + _interval) then {
            [_display] call _refreshFunction;
            _x set [2, time];
        };
    } forEach _refreshConfig;
    uiSleep 0.01;
};

ppEffectDestroy _dynamicBlurHandle;
private _spawnCamera = uiNamespace getVariable ["SQD_spawnCamera", objNull];
if (alive _spawnCamera) then {
    _spawnCamera cameraEffect ["Terminate", "BACK TOP", "spawncam"];
    camDestroy _spawnCamera;
};