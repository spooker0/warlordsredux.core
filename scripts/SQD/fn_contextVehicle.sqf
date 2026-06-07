#include "includes.inc"
params ["_control"];

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _existingMenu = _display getVariable ["SQD_contextMenu", controlNull];
if (!isNull _existingMenu) then {
    ctrlDelete _existingMenu;
};

if (WL_ISDOWN(player)) exitWith {};

private _asset = _control getVariable ["SQD_vehicle", objNull];
if (isNull _asset) exitWith {};

private _contextMenu = _display ctrlCreate ["SQD_Menu_Contextual", -1];
_display setVariable ["SQD_contextMenu", _contextMenu];

_display setVariable ["WL2_allButtonsData", []];
uiNamespace setVariable ["WL2_mapButtons", []];
uiNamespace setVariable ["WL2_assetTargetsSelected", [_asset]];

[_asset, 0] call WL2_fnc_assetMapButtons;

private _hasButtons = false;
private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", []];
{
    private _menuButtons = _x # 1;
    if (count _menuButtons > 0) then {
        _hasButtons = true;
    };
} forEach _allMenuButtons;

if (!_hasButtons) exitWith {};

private _menuButtonIconMap = uiNamespace getVariable ["WL2_mapMenuButtonIcons", createHashMap];
private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", []];

private _buttonCount = 0;
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
        _buttonCount = _buttonCount + 1;
    } forEach _menuButtons;
    _buttonsData = [_buttonsData, [], { if (_x # 4) then { _x # 0 } else { "zzz" + (_x # 0) } }, "ASCEND"] call BIS_fnc_sortBy;

    private _actionTargets = uiNamespace getVariable ["WL2_assetTargetsSelected", []];
    private _actionTarget = if (count _actionTargets > _targetId) then {
        _actionTargets # _targetId;
    } else {
        objNull;
    };
    private _mapButtonText = _actionTarget getVariable ["WL2_mapButtonText", "Asset"];

    _allButtonsData pushBack [_targetId, _mapButtonText, _buttonsData];
} forEach _allMenuButtons;

{
    _x params ["_targetId", "_targetText", "_buttonsData"];

    {
        _x params ["_buttonId", "_buttonLabel", "_buttonCost", "_buttonCanAfford", "_buttonEnabled", "_buttonIcon"];

        private _actionButton = _display ctrlCreate ["SQD_Menu_ContextualButton", -1, _contextMenu];
        _actionButton ctrlSetPosition [0, SQD_LAYOUT_CONTEXT_H * _forEachIndex, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H];
        _actionButton ctrlCommit 0;

        private _costText = if (_buttonCost > 0) then {
            format [" <t color='%1'>(%2%3)</t>", if (_buttonCanAfford) then { "#00ff00" } else { "#f00000" }, WL_MONEY_SIGN, _buttonCost];
        } else {
            "";
        };
        _actionButton ctrlSetStructuredText parseText format ["<t color='#ffffff'>%1%2</t>", _buttonLabel, _costText];

        if (_buttonEnabled) then {
            _actionButton ctrlSetBackgroundColor [0, 0, 0, 1];
        } else {
            _actionButton ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
        };
        _actionButton ctrlCommit 0;

        _actionButton setVariable ["WL2_mapButtonTargetId", _targetId];
        _actionButton setVariable ["WL2_mapButtonId", _buttonId];

        _actionButton ctrlAddEventHandler ["MouseButtonDown", SQD_fnc_actionVehicle];
    } forEach _buttonsData;
} forEach _allButtonsData;

getMousePosition params ["_mouseX", "_mouseY"];
_contextMenu ctrlSetPosition [_mouseX, _mouseY, SQD_LAYOUT_CONTEXT_W, SQD_LAYOUT_CONTEXT_H * _buttonCount];
_contextMenu ctrlCommit 0;

private _dummyButton = _display displayCtrl SQD_DUMMY_IDC;
ctrlSetFocus _dummyButton;