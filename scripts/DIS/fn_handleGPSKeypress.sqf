#include "includes.inc"
params ["_key"];

private _allMenuDisplays = uiNamespace getVariable ["DIS_gpsTargetingMenus", []];
private _topMenu = _allMenuDisplays select { 
    private _display = _x;
    private _texture = _display displayCtrl 5502;
    private _inFocus = _texture getVariable ["DIS_inFocus", false];
    _inFocus
};
if (count _topMenu == 0) exitWith {};

private _targetDisplay = _topMenu select 0;
private _texture = _targetDisplay displayCtrl 5502;

private _toggle = false;
if (_key in actionKeys "gunElevUp" || _key in actionKeys "gunElevDown") then {
    _toggle = true;
};

private _currentIndex = cameraOn getVariable ["DIS_selectionIndex", 0];
if (_toggle) exitWith {
    private _newIndex = if (_currentIndex == 0) then {
        1
    } else {
        0
    };
    cameraOn setVariable ["DIS_selectionIndex", _newIndex];

    if (_newIndex == 1) then {
        cameraOn setVariable ["DIS_gpsCord", ""];
    } else {
        private _existingCord = cameraOn getVariable ["DIS_gpsCord", ""];
        while { count _existingCord < 6 } do {
            _existingCord = "0" + _existingCord;
        };
        cameraOn setVariable ["DIS_gpsCord", _existingCord];
    };

    [_texture] call DIS_fnc_sendGPSData;
    playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
};

if (_currentIndex == 0) exitWith {};

private _isNumberKey = true;
private _addToCode = switch (_key) do {
    case DIK_NUMPAD0;
    case DIK_0: {"0"};
    case DIK_NUMPAD1;
    case DIK_1: {"1"};
    case DIK_NUMPAD2;
    case DIK_2: {"2"};
    case DIK_NUMPAD3;
    case DIK_3: {"3"};
    case DIK_NUMPAD4;
    case DIK_4: {"4"};
    case DIK_NUMPAD5;
    case DIK_5: {"5"};
    case DIK_NUMPAD6;
    case DIK_6: {"6"};
    case DIK_NUMPAD7;
    case DIK_7: {"7"};
    case DIK_NUMPAD8;
    case DIK_8: {"8"};
    case DIK_NUMPAD9;
    case DIK_9: {"9"};
    default {
        _isNumberKey = false;
        ""
    };
};

if (!_isNumberKey) exitWith {};

private _existingCord = cameraOn getVariable ["DIS_gpsCord", ""];
private _newCord = _existingCord + _addToCode;
cameraOn setVariable ["DIS_gpsCord", _newCord];

if (count _newCord >= 6) then {
    cameraOn setVariable ["DIS_selectionIndex", 0];
};

[_texture] call DIS_fnc_sendGPSData;
playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];

true;