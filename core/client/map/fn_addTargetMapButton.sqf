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

private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", []];
private _existingMenuButtons = _allMenuButtons select {
    _x # 0 == _targetId
};

private _cost = if (count _costCondition > 0) then {
    _costCondition # 0;
} else {
    -1;
};

private _funds = (missionNamespace getVariable "fundsDatabaseClients") getOrDefault [getPlayerUID player, 0];
private _canAfford = _funds >= _cost;

private _buttonData = createHashMap;
_buttonData set ["action", _action];
_buttonData set ["actionClose", _actionClose];
_buttonData set ["actionCondition", _actionCondition];
_buttonData set ["costCondition", _costCondition];

if (count _existingMenuButtons > 0) then {
    private _menuButtons = _existingMenuButtons # 0 # 1;
    _menuButtons set [_buttonId, [_textLabel, _cost, _canAfford, _buttonEnabled, _buttonData]];
} else {
    private _menuButtons = createHashMap;
    _menuButtons set [_buttonId, [_textLabel, _cost, _canAfford, _buttonEnabled, _buttonData]];
    _allMenuButtons pushBack [_targetId, _menuButtons];
};