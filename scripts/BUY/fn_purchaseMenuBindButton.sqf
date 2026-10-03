#include "includes.inc"
params ["_button", ["_availabilityVariable", "BUY_buttonAvailable"]];

if (isNull _button) exitWith {};

_button setVariable ["BUY_availabilityVariable", _availabilityVariable];
_button ctrlAddEventHandler ["MouseEnter", {
    params ["_button"];
    private _availabilityVariable = _button getVariable ["BUY_availabilityVariable", "BUY_buttonAvailable"];
    private _available = uiNamespace getVariable [_availabilityVariable, true];
    if (!_available) exitWith {};

    private _color = BIS_WL_colorFriendly;
    [_button, [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3]] call WL2_fnc_purchaseMenuSetButtonColor;

    if (ctrlIDC _button == BUY_REQUEST_IDC) then {
        uiNamespace setVariable ["BIS_WL_purchaseMenuButtonHover", true];
    };

    playSound "click";
}];
_button ctrlAddEventHandler ["MouseExit", {
    params ["_button"];
    private _availabilityVariable = _button getVariable ["BUY_availabilityVariable", "BUY_buttonAvailable"];
    private _available = uiNamespace getVariable [_availabilityVariable, true];
    private _color = BIS_WL_colorFriendly;
    private _textColor = [1, 1, 1, 1];
    if (!_available) then {
        _color = [(_color # 0) * 0.5, (_color # 1) * 0.5, (_color # 2) * 0.5, _color # 3];
        _textColor = [0.5, 0.5, 0.5, 1];
    };

    [_button, _color] call WL2_fnc_purchaseMenuSetButtonColor;
    _button ctrlSetTextColor _textColor;

    if (ctrlIDC _button == BUY_REQUEST_IDC) then {
        uiNamespace setVariable ["BIS_WL_purchaseMenuButtonHover", false];
    };

}];
_button ctrlAddEventHandler ["MouseButtonDown", {
    params ["_button"];
    private _availabilityVariable = _button getVariable ["BUY_availabilityVariable", "BUY_buttonAvailable"];
    if (uiNamespace getVariable [_availabilityVariable, true]) then {
        _button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
    };

}];
_button ctrlAddEventHandler ["MouseButtonUp", {
    params ["_button"];
    private _availabilityVariable = _button getVariable ["BUY_availabilityVariable", "BUY_buttonAvailable"];
    if (uiNamespace getVariable [_availabilityVariable, true]) then {
        _button ctrlSetTextColor [1, 1, 1, 1];
    };

}];
