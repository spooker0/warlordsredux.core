#include "includes.inc"
params ["_key"];

private _display = uiNamespace getVariable ["RscWLTargetingMenu", displayNull];
if (isNull _display) exitWith {};

private _delta = 0;
if (_key in actionKeys "gunElevUp") then {
    _delta = -1;
};

if (_key in actionKeys "gunElevDown") then {
    _delta = 1;
};

private _currentIndex = cameraOn getVariable ["DIS_selectionIndex", 0];
if (_delta != 0) then {
    private _savedCords = cameraOn getVariable ["DIS_savedGPSCoordinates", []];
    private _countCords = count _savedCords;

    private _newIndex = (_currentIndex + _delta) mod (_countCords + 2);
    if (_newIndex < 0) then {
        _newIndex = _countCords + 1;
    };
    cameraOn setVariable ["DIS_selectionIndex", _newIndex];

    if (_newIndex > 1) then {
        private _newCord = _savedCords select (_newIndex - 2);
        cameraOn setVariable ["DIS_gpsCord", _newCord];
    };

    playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];
};

if (_currentIndex != 1) exitWith {};

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
if (count _newCord > 6) then {
    _newCord = _newCord select [count _newCord - 6, 6];
};
cameraOn setVariable ["DIS_gpsCord", _newCord];

playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 2];

true;