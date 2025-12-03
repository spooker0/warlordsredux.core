#include "includes.inc"
params ["_display", "_clickType", "_buttonId", "_targetId"];

private _closeFunction = {
    _display closeDisplay 0;
};

private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", createHashMap];
private _menuButtons = _allMenuButtons getOrDefault [_targetId, createHashMap];
private _menuButton = _menuButtons getOrDefault [_buttonId, []];

if (count _menuButton == 0) exitWith { false };
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
        private _script = format ["changeButtonText(""%1"", ""%2"", ""%3"");", _targetId, _buttonId, _actionResult];

        private _texture = _display displayCtrl 5501;
        _texture ctrlWebBrowserAction ["ExecJS", _script];
    };
    ctrlSetFocus controlNull;
    playSoundUI ["\A3\ui_f\data\sound\RscButtonMenu\soundClick.wss", 0.1];
};

if (_targetButtonSetupActionClose) then {
    call _closeFunction;
};

true;