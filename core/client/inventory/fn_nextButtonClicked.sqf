#include "includes.inc"
params ["_control"];
playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

private _display = ctrlParent _control;

private _loadButtons = uiNamespace getVariable ["WL2_inventoryLoadButtons", []];
private _totalButtons = count _loadButtons;
private _totalPages = ceil (INV_MAX_SLOTS / _totalButtons) - 1;

private _currentPage = uiNamespace getVariable ["WL2_inventoryPage", 0];
_currentPage = (_currentPage + 1) min _totalPages;
uiNamespace setVariable ["WL2_inventoryPage", _currentPage];

call WL2_fnc_pageChanged;

private _dummyButton = _display displayCtrl 1338;
[_dummyButton] spawn {
    params ["_dummyButton"];
    uiSleep 0.1;
    ctrlSetFocus _dummyButton;
};