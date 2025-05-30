params ["_textLabel", "_action", "_actionClose", ["_actionCondition", ""], ["_costCondition", []]];
// _costCondition = [amount, name, category]

scopeName "targetButtonScope";
private _actionTarget = uiNamespace getVariable ["WL2_assetTargetSelected", objNull];
if (_actionCondition != "") then {
    private _result = [_actionTarget, _actionCondition] call WL2_fnc_mapButtonConditions;
    if (!_result) then {
        breakOut "targetButtonScope";
    };
};
private _buttonEnabled = true;
if (count _costCondition > 0) then {
    private _amount = _costCondition # 0;
    private _name = _costCondition # 1;
    private _category = _costCondition # 2;
    private _checker = [_name, [], "", "", "", [], _amount, _category] call WL2_fnc_purchaseMenuAssetAvailability;
    if !(_checker # 0) then {
        _buttonEnabled = false;
        // breakOut "targetButtonScope";
    };
};

private _dialog = WL2_TargetButtonSetup # 0;
private _menuButtons = WL2_TargetButtonSetup # 1;
private _offsetX = WL2_TargetButtonSetup # 2;
private _offsetY = WL2_TargetButtonSetup # 3;

private _costText = if (count _costCondition > 0) then {
    private _cost = _costCondition # 0;
    if (_cost > 0) then {
        private _moneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;
        format [" (%1%2)", _moneySign, _costCondition # 0];
    } else {
        " (FREE)";
    };
} else {
    "";
};

private _button = _dialog ctrlCreate ["WLRscButtonMenu", -1];
_button ctrlSetPosition [_offsetX, _offsetY + (count _menuButtons * 0.05), 0.5, 0.05];
_button ctrlSetStructuredText parseText format ["<t align='center' font='PuristaBold'>%1%2</t>", _textLabel, _costText];
_button ctrlCommit 0;
// Can't disable or we won't get error messages
if (_buttonEnabled) then {
    _button ctrlSetTextColor [1, 1, 1, 1];
    _button ctrlSetActiveColor [1, 1, 1, 1];
} else {
    _button ctrlSetTextColor [1, 1, 1, 0.2];
    _button ctrlSetActiveColor [1, 1, 1, 0.2];
};
_menuButtons pushBack _button;

_button setVariable ["WL2_targetButtonSetupAction", _action];
_button setVariable ["WL2_targetButtonSetupActionClose", _actionClose];
_button setVariable ["WL2_targetButtonSetupActionCondition", _actionCondition];
_button setVariable ["WL2_targetButtonSetupCostCondition", _costCondition];
_button ctrlAddEventHandler ["MouseButtonDown", {
    params ["_control", "_button"];
    scopeName "buttonClickScope";
    private _actionTarget = uiNamespace getVariable ["WL2_assetTargetSelected", objNull];
    private _targetButtonSetupActionClose = _control getVariable "WL2_targetButtonSetupActionClose";
    private _costCondition = _control getVariable "WL2_targetButtonSetupCostCondition";
    private _actionCondition = _control getVariable "WL2_targetButtonSetupActionCondition";
    private _actionSelectTime = uiNamespace setVariable ["WL2_assetTargetSelectedTime", -1];

    if (count _costCondition > 0) then {
        private _amount = _costCondition # 0;
        private _name = _costCondition # 1;
        private _category = _costCondition # 2;
        private _checker = [_name, [], "", "", "", [], _amount, _category] call WL2_fnc_purchaseMenuAssetAvailability;
        if !(_checker # 0) then {
            playSoundUI ["AddItemFailed"];
            systemChat ((_checker # 1) joinString ", ");
            breakOut "buttonClickScope";
        };
    };

    if (_actionCondition != "" && serverTime - _actionSelectTime > 5) then {
        private _result = [_actionTarget, _actionCondition] call WL2_fnc_mapButtonConditions;
        if (!_result) then {
            playSoundUI ["AddItemFailed"];
            systemChat "Action expired.";
            breakOut "buttonClickScope";
        };
    };

    if !(isNull _actionTarget) then {
        private _targetButtonSetupAction = _control getVariable "WL2_targetButtonSetupAction";
        if (typeName _targetButtonSetupAction == "ARRAY") then {
            _targetButtonSetupAction = _targetButtonSetupAction # _button;
        };
        if (_targetButtonSetupActionClose) then {
            [_actionTarget] spawn _targetButtonSetupAction;
        } else {
            private _actionResult = [_actionTarget] call _targetButtonSetupAction;
            _control ctrlSetStructuredText parseText format ["<t align='center' font='PuristaBold'>%1</t>", _actionResult];
        };
        ctrlSetFocus controlNull;
        playSoundUI ["\A3\ui_f\data\sound\RscButtonMenu\soundClick.wss", 0.1];
    };

    if (_targetButtonSetupActionClose) then {
        uiNamespace setVariable ["WL2_assetTargetSelected", objNull];
        private _dialog = ctrlParent _control;
        _dialog closeDisplay 1;
    };
}];

WL2_TargetButtonSetup = [_dialog, _menuButtons, _offsetX, _offsetY];