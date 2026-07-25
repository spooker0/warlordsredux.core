#include "constants.inc"

private _existingDisplay = findDisplay SPEC_TARGET_MENU_IDD;
if (!isNull _existingDisplay) exitWith {};

private _display = createDialog ["SPEC_TargetMenu", true];
if (isNull _display) exitWith {};

uiNamespace setVariable ["SPEC_TargetMenu", _display];

uiNamespace setVariable ["SPEC_CameraMoveRight", 0];
uiNamespace setVariable ["SPEC_CameraMoveLeft", 0];
uiNamespace setVariable ["SPEC_CameraMoveForward", 0];
uiNamespace setVariable ["SPEC_CameraMoveBackward", 0];
uiNamespace setVariable ["SPEC_CameraMoveUp", 0];
uiNamespace setVariable ["SPEC_CameraMoveDown", 0];

_display setVariable ["SPEC_targetControls", []];
_display setVariable ["SPEC_targetSearchRows", []];
_display setVariable ["SPEC_targetDataSignature", ""];

private _closeControl = _display displayCtrl SPEC_TARGET_CLOSE_ID;

_closeControl ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    private _display = ctrlParent _control;
    _display closeDisplay 2;
}];

private _searchControl = _display displayCtrl SPEC_TARGET_SEARCH_ID;
_searchControl ctrlAddEventHandler ["KeyUp", SPEC_fnc_spectatorTargetMenuSearch];
ctrlSetFocus _searchControl;

[_display] call SPEC_fnc_spectatorTargetMenuRefresh;