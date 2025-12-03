#include "includes.inc"
params ["_offsetX", "_offsetY"];
private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
    // _display = (findDisplay 12) createDisplay "RscWLBrowserMenu";
};
uiNamespace setVariable ["WL2_mapButtonDisplay", _display];

private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\buttons.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];
_texture setVariable ["WL2_buttonsMenuOffsetX", _offsetX];
_texture setVariable ["WL2_buttonsMenuOffsetY", _offsetY];

systemChat format ["Buttons loaded: %1", diag_frameNo toFixed 0];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    systemChat format ["Menu texture loaded: %1", diag_frameNo toFixed 0];

    private _menuButtonIconMap = createHashMapFromArray [
        ["access-control", "a3\modules_f\data\iconunlock_ca.paa"],
        ["add-waypoint", "A3\ui_f\data\map\markers\military\box_CA.paa"],
        ["control-driver", "a3\ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa"],
        ["control-gunner", "a3\ui_f\data\IGUI\Cfg\CommandBar\imageGunner_ca.paa"],
        ["ew", "a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"],
        ["fortify-stronghold", "A3\ui_f\data\map\mapcontrol\Ruin_CA.paa"],
        ["ft", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-ai", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-asset", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-conflict", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-conflict-air", "a3\ui_f\data\map\vehicleicons\iconparachute_ca.paa"],
        ["ft-fob", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-fob-test", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-home", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-squad", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-squad-leader", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-stronghold", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-stronghold-near", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-stronghold-test", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["ft-tent", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
        ["lock-fob", "a3\modules_f\data\iconunlock_ca.paa"],
        ["loiter", "A3\ui_f\data\map\markers\military\box_CA.paa"],
        ["kick", "a3\modules_f\data\iconunlock_ca.paa"],
        ["mark-sector", "A3\ui_f\data\map\markers\handdrawn\flag_CA.paa"],
        ["move", "A3\ui_f\data\map\markers\military\box_CA.paa"],
        ["radar-operate", "a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"],
        ["radar-rotate", "a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"],
        ["remove", "a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa"],
        ["remove-fob", "a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa"],
        ["remove-stronghold", "a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa"],
        ["repair-fob", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["repair-stronghold", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["sector-scan", "a3\drones_f\air_f_gamma\uav_02\data\ui\map_uav_02_ca.paa"],
        ["smart-mine-adjust", "a3\ui_f\data\map\vehicleicons\iconexplosiveuw_ca.paa"],
        ["smart-mine-type", "a3\ui_f\data\map\vehicleicons\iconexplosiveuw_ca.paa"],
        ["target-altitude", "a3\ui_f\data\igui\cfg\simpletasks\types\Heli_ca.paa"],
        ["target-loiter-radius", "A3\ui_f\data\map\markers\military\circle_CA.paa"],
        ["vehicle-paradrop", "a3\ui_f\data\map\vehicleicons\iconparachute_ca.paa"]
    ];

    private _allMenuButtons = uiNamespace getVariable ["WL2_mapButtons", createHashMap];
    private _allButtonsData = [];
    {
        private _targetId = _x;
        private _menuButtons = _y;

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

    private _offsetX = _texture getVariable ["WL2_buttonsMenuOffsetX", 0];
    private _offsetY = _texture getVariable ["WL2_buttonsMenuOffsetY", 0];

    private _buttonsDataJSON = toJSON _allButtonsData;
    private _script = format ["setButtons(%1, %2, %3);", _buttonsDataJSON, _offsetX, _offsetY];
    _texture ctrlWebBrowserAction ["ExecJS", _script];

    systemChat format ["Buttons loaded: %1", diag_frameNo toFixed 0];
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    private _display = ctrlParent _texture;

    private _closeFunction = {
        _display closeDisplay 0;
    };

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        call _closeFunction;
    };

    private _params = fromJSON _message;
    _params params ["_clickType", "_buttonId", "_targetId"];

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
            _texture ctrlWebBrowserAction ["ExecJS", _script];
        };
        ctrlSetFocus controlNull;
        playSoundUI ["\A3\ui_f\data\sound\RscButtonMenu\soundClick.wss", 0.1];
    };

    if (_targetButtonSetupActionClose) then {
        call _closeFunction;
    };

    true;
}];

while { !isNull _texture } do {
    uiSleep 0.001;
    private _insertMarkerDisplay = uiNamespace getVariable ["RscDisplayInsertMarker", displayNull];
    if (!isNull _insertMarkerDisplay) then {
        _insertMarkerDisplay closeDisplay 0;
    };
};