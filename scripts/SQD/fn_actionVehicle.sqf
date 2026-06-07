#include "includes.inc"
params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

private _display = ctrlParent _control;
playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

private _buttonId = _control getVariable ["WL2_mapButtonId", 0];
private _targetId = _control getVariable ["WL2_mapButtonTargetId", 0];
private _clickType = if (_button == 0) then { _button } else { 1 };

private _closeFunction = {
    private _contextMenu = _display getVariable ["SQD_contextMenu", controlNull];
    if (!isNull _contextMenu) then {
        ctrlDelete _contextMenu;
    };
};

playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

private _buttonId = _control getVariable ["WL2_mapButtonId", 0];
private _targetId = _control getVariable ["WL2_mapButtonTargetId", 0];
private _clickType = if (_button == 0) then { _button } else { 1 };

private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", []];

private _menuButtons = _allMenuButtons select {
    _x # 0 == _targetId
};
_menuButtons = if (count _menuButtons > 0) then {
    _menuButtons # 0 # 1;
} else {
    createHashMap;
};

private _menuButton = _menuButtons getOrDefault [_buttonId, []];

if (count _menuButton == 0) exitWith {};
private _buttonData = _menuButton # 4;

scopeName "buttonClickScope";
private _actionTargets = uiNamespace getVariable ["WL2_assetTargetsSelected", []];
private _actionTarget = if (count _actionTargets > _targetId) then {
    _actionTargets # _targetId;
} else {
    objNull;
};

private _targetButtonSetupActionClose = _buttonData getOrDefault ["actionClose", false];
private _costCondition = _buttonData getOrDefault ["costCondition", []];
private _actionCondition = _buttonData getOrDefault ["actionCondition", ""];

if (count _costCondition > 0) then {
    private _amount = _costCondition # 0;
    private _name = _costCondition # 1;
    private _category = _costCondition # 2;
    private _checker = [_name, [], "", "", "", [], _amount, _category] call WL2_fnc_purchaseMenuAssetAvailability;
    if !(_checker # 0) then {
        playSoundUI ["AddItemFailed"];
        {
            [_x] call WL2_fnc_smoothText;
        } forEach (_checker # 1);
        call _closeFunction;
        breakOut "buttonClickScope";
    };
};

if (_actionCondition != "") then {
    private _result = [_actionTarget, _actionCondition] call WL2_fnc_mapButtonConditions;
    if (_result != "ok") then {
        playSoundUI ["AddItemFailed"];
        [_result] call WL2_fnc_smoothText;
        call _closeFunction;
        breakOut "buttonClickScope";
    };
};

if !(isNull _actionTarget) then {
    private _targetButtonSetupAction = _buttonData getOrDefault ["action", []];
    if (typeName _targetButtonSetupAction == "ARRAY") then {
        _targetButtonSetupAction = _targetButtonSetupAction # _clickType;
    };
    if (_targetButtonSetupActionClose) then {
        [_actionTarget] spawn _targetButtonSetupAction;
    } else {
        private _actionResult = [_actionTarget] call _targetButtonSetupAction;
        _control ctrlSetStructuredText parseText _actionResult;
    };
    playSoundUI ["\A3\ui_f\data\sound\RscButtonMenu\soundClick.wss", 0.1];
};

if (_targetButtonSetupActionClose) then {
    call _closeFunction;
};