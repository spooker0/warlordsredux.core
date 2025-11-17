#include "includes.inc"
params ["_asset", "_targetId", "_buttonId", "_textLabel", "_action", "_actionClose", ["_actionCondition", ""], ["_costCondition", []]];
// _costCondition = [amount, name, category]

private _buttonEnabled = true;
private _showButton = true;
if (_actionCondition != "") then {
    private _result = [_asset, _actionCondition] call WL2_fnc_mapButtonConditions;
    if (_result != "ok") then {
        _buttonEnabled = false;
    };
    if (_result == "") then {
        _showButton = false;
    };
};
if (!_showButton) exitWith {};

if (count _costCondition > 0) then {
    private _amount = _costCondition # 0;
    private _name = _costCondition # 1;
    private _category = _costCondition # 2;
    private _checker = [_name, [], "", "", "", [], _amount, _category] call WL2_fnc_purchaseMenuAssetAvailability;
    if !(_checker # 0) then {
        _buttonEnabled = false;
    };
};

private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", createHashMap];
private _menuButtons = _allMenuButtons getOrDefault [_targetId, createHashMap];

private _costText = if (count _costCondition > 0) then {
    private _cost = _costCondition # 0;
    if (_cost > 0) then {
        format [" (Cost: %1)", _costCondition # 0];
    } else {
        " (Cost: free)";
    };
} else {
    "";
};

private _buttonLabel = format ["%1%2", _textLabel, _costText];

private _buttonData = createHashMap;
_buttonData set ["action", _action];
_buttonData set ["actionClose", _actionClose];
_buttonData set ["actionCondition", _actionCondition];
_buttonData set ["costCondition", _costCondition];

_menuButtons set [_buttonId, [_buttonLabel, _buttonEnabled, _buttonData]];
_allMenuButtons set [_targetId, _menuButtons];