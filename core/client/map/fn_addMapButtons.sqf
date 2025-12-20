#include "includes.inc"
params ["_display", "_texture"];

private _menuButtonIconMap = uiNamespace getVariable ["WL2_mapMenuButtonIcons", createHashMap];
private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", []];

private _allButtonsData = [];
{
    private _targetId = _x # 0;
    private _menuButtons = _x # 1;

    private _buttonsData = [];
    {
        private _buttonId = _x;
        private _buttonLabel = _y # 0;
        private _buttonCost = _y # 1;
        private _buttonCanAfford = _y # 2;
        private _buttonEnabled = _y # 3;

        _buttonsData pushBack [
            _buttonId,
            _buttonLabel,
            _buttonCost,
            _buttonCanAfford,
            _buttonEnabled,
            _menuButtonIconMap getOrDefault [_buttonId, ""]
        ];
    } forEach _menuButtons;
    _buttonsData = [_buttonsData, [], { _x # 0 }, "ASCEND"] call BIS_fnc_sortBy;

    private _actionTargets = uiNamespace getVariable ["WL2_assetTargetsSelected", []];
    private _actionTarget = if (count _actionTargets > _targetId) then {
        _actionTargets # _targetId;
    } else {
        objNull;
    };
    private _mapButtonText = _actionTarget getVariable ["WL2_mapButtonText", "Asset"];

    _allButtonsData pushBack [_targetId, _mapButtonText, _buttonsData];
} forEach _allMenuButtons;
_texture setVariable ["WL2_allButtonsData", _allButtonsData];

private _numpadData = [];
{
    private _targetId = _x # 0;
    private _buttonsData = _x # 2;
    {
        private _buttonData = _x;
        _numpadData pushBack [_targetId, _buttonData # 0];

        if (count _numpadData >= 9) then {
            break;
        };
    } forEach _buttonsData;
} forEach _allButtonsData;
_display setVariable ["WL2_mapButtonNumpadData", _numpadData];

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    private _keyCode = switch (_key) do {
        case DIK_SPACE;
        case DIK_NUMPAD1;
        case DIK_1: {0};
        case DIK_NUMPAD2;
        case DIK_2: {1};
        case DIK_NUMPAD3;
        case DIK_3: {2};
        case DIK_NUMPAD4;
        case DIK_4: {3};
        case DIK_NUMPAD5;
        case DIK_5: {4};
        case DIK_NUMPAD6;
        case DIK_6: {5};
        case DIK_NUMPAD7;
        case DIK_7: {6};
        case DIK_NUMPAD8;
        case DIK_8: {7};
        case DIK_NUMPAD9;
        case DIK_9: {8};
        default {-1};
    };
    if (_keyCode == -1) exitWith {};

    private _numpadData = _display getVariable ["WL2_mapButtonNumpadData", []];
    private _entry = _numpadData select _keyCode;

    if (isNil "_entry") exitWith {};

    private _buttonTimeout = uiNamespace getVariable ["WL2_mapButtonLastClickTime", 0];
    if (serverTime < _buttonTimeout) exitWith {};

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    [_display, 0, _entry # 1, _entry # 0] call WL2_fnc_mapButtonClick;
    uiNamespace setVariable ["WL2_mapButtonLastClickTime", serverTime + 0.3];
}];

_display displayAddEventHandler ["KeyUp", {
    uiNamespace setVariable ["WL2_mapButtonLastClickTime", 0];
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    private _display = ctrlParent _texture;

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        _display closeDisplay 0;
    };

    private _params = fromJSON _message;
    _params params ["_clickType", "_buttonId", "_targetId"];

    [_display, _clickType, _buttonId, _targetId] spawn WL2_fnc_mapButtonClick;
    true;
}];

while { !isNull _texture } do {
    uiSleep 0.001;
    private _insertMarkerDisplay = uiNamespace getVariable ["RscDisplayInsertMarker", displayNull];
    if (!isNull _insertMarkerDisplay) then {
        _insertMarkerDisplay closeDisplay 0;
    };
};