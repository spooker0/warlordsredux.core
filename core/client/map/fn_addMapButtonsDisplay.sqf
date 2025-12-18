#include "includes.inc"
params ["_display"];

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

getMousePosition params ["_mouseX", "_mouseY"];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _buttonScale = _settingsMap getOrDefault ["mapButtonScale", 1.0];

private _xPos = _mouseX;
private _yPos = _mouseY;
private _buttonWidth = 0.5;
private _buttonHeight = 0.045 * _buttonScale;
private _iconWidth = _buttonHeight * 0.8 *  3 / 4;
private _iconHeight = _buttonHeight * 0.8;

private _dummyButton = _display ctrlCreate ["WLDummyButton", 1338];
_dummyButton ctrlCommit 0;

{
    _x params ["_targetId", "_targetText", "_buttonsData"];
    private _targetLabel = _display ctrlCreate ["RscStructuredText", -1];
    _targetLabel ctrlSetPosition [
        _xPos,
        _yPos,
        _buttonWidth,
        _buttonHeight
    ];
    _targetLabel ctrlSetStructuredText parseText format ["<t font='PuristaBold' align='center' color='#ffffff'>%1</t>", _targetText];
    _targetLabel ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _targetLabel ctrlSetFontHeight 0.035 * _buttonScale;
    _targetLabel ctrlCommit 0;
    _yPos = _yPos + _buttonHeight;

    {
        _x params ["_buttonId", "_buttonLabel", "_buttonCost", "_buttonCanAfford", "_buttonEnabled", "_buttonIcon"];

        private _button = _display ctrlCreate ["WLRscButtonMenu", -1];
        _button ctrlSetPosition [
            _xPos,
            _yPos,
            _buttonWidth,
            _buttonHeight
        ];
        private _costText = if (_buttonCost > 0) then {
            format [" <t color='%1'>(%2%3)</t>", if (_buttonCanAfford) then { "#00ff00" } else { "#f00000" }, WL_MoneySign, _buttonCost];
        } else {
            "";
        };
        _button ctrlSetStructuredText parseText format ["     <t font='PuristaBold'>%1%2</t>", _buttonLabel, _costText];
        _button ctrlSetFontHeight 0.035 * _buttonScale;

        if (_buttonEnabled) then {
            _button ctrlSetBackgroundColor [0, 0, 0, 1];
        } else {
            _button ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
        };
        _button ctrlCommit 0;

        _button setVariable ["WL2_mapButtonTargetId", _targetId];
        _button setVariable ["WL2_mapButtonId", _buttonId];

        _button ctrlAddEventHandler ["MouseButtonDown", {
            params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
            private _display = ctrlParent _control;
            playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

            private _buttonId = _control getVariable ["WL2_mapButtonId", 0];
            private _targetId = _control getVariable ["WL2_mapButtonTargetId", 0];
            private _clickType = if (_button == 0) then { _button } else { 1 };

            [_display, _control, _clickType, _buttonId, _targetId] spawn WL2_fnc_mapButtonClick;
        }];

        private _icon = _display ctrlCreate ["RscPicture", -1];
        _icon ctrlSetPosition [
            _xPos + _iconWidth * 0.1,
            _yPos + _iconHeight * 0.1,
            _iconWidth,
            _iconHeight
        ];
        _icon ctrlSetText _buttonIcon;
        _icon ctrlCommit 0;

        _yPos = _yPos + _buttonHeight;
    } forEach _buttonsData;

    _yPos = _yPos + 0.01 * _buttonScale;
} forEach _allButtonsData;

private _xMax = _xPos + _buttonWidth;
private _yMax = _yPos;
_display setVariable ["WL2_buttonsMenuMinX", _mouseX];
_display setVariable ["WL2_buttonsMenuMinY", _mouseY];
_display setVariable ["WL2_buttonsMenuMaxX", _xMax];
_display setVariable ["WL2_buttonsMenuMaxY", _yMax];

_display displayAddEventHandler  ["MouseButtonDown", {
    params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    private _minX = _control getVariable ["WL2_buttonsMenuMinX", 0];
    private _minY = _control getVariable ["WL2_buttonsMenuMinY", 0];

    if (_xPos < _minX || _yPos < _minY) exitWith {
        playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
        _control closeDisplay 0;
    };

    private _maxX = _control getVariable ["WL2_buttonsMenuMaxX", 0];
    private _maxY = _control getVariable ["WL2_buttonsMenuMaxY", 0];

    if (_xPos > _maxX || _yPos > _maxY) exitWith {
        playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
        _control closeDisplay 0;
    };
}];

while { !isNull _display } do {
    uiSleep 0.001;
    private _insertMarkerDisplay = uiNamespace getVariable ["RscDisplayInsertMarker", displayNull];
    if (!isNull _insertMarkerDisplay) then {
        _insertMarkerDisplay closeDisplay 0;
    };
};