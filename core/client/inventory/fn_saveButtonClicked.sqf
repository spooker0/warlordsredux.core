#include "includes.inc"
params ["_control"];
playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

private _display = ctrlParent _control;

private _loadoutIndex = _control getVariable ["WL2_loadoutIndex", -1];
private _page = uiNamespace getVariable ["WL2_inventoryPage", 0];
private _index = _page * 10 + _loadoutIndex;

private _currentLoadout = getUnitLoadout player;
profileNamespace setVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _index], _currentLoadout];

call WL2_fnc_pageChanged;

private _dummyButton = _display displayCtrl 1338;
[_dummyButton] spawn {
    params ["_dummyButton"];
    uiSleep 0.1;
    ctrlSetFocus _dummyButton;
};