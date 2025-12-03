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

    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    [_display, 0, _entry # 1, _entry # 0] call WL2_fnc_mapButtonClick;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _allButtonsData = _texture getVariable ["WL2_allButtonsData", []];

    private _offsetX = _texture getVariable ["WL2_buttonsMenuOffsetX", 0];
    private _offsetY = _texture getVariable ["WL2_buttonsMenuOffsetY", 0];

    private _buttonsDataJSON = toJSON _allButtonsData;
    private _script = format ["setButtons(%1, %2, %3);", _buttonsDataJSON, _offsetX, _offsetY];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
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

    [_display, _clickType, _buttonId, _targetId] call WL2_fnc_mapButtonClick;
}];

while { !isNull _texture } do {
    uiSleep 0.001;
    private _insertMarkerDisplay = uiNamespace getVariable ["RscDisplayInsertMarker", displayNull];
    if (!isNull _insertMarkerDisplay) then {
        _insertMarkerDisplay closeDisplay 0;
    };
};