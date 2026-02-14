#include "includes.inc"
private _currentPage = uiNamespace getVariable ["WL2_inventoryPage", 0];

private _previousButton = uiNamespace getVariable ["WL2_inventoryPreviousButton", controlNull];
private _nextButton = uiNamespace getVariable ["WL2_inventoryNextButton", controlNull];

if (!isNull _previousButton) then {
    _previousButton ctrlEnable (_currentPage > 0);
};
if (!isNull _nextButton) then {
    private _loadButtons = uiNamespace getVariable ["WL2_inventoryLoadButtons", []];
    private _totalButtons = count _loadButtons;
    private _totalPages = ceil (INV_MAX_SLOTS / _totalButtons) - 1;

    _nextButton ctrlEnable (_currentPage < _totalPages);
};

private _loadButtons = uiNamespace getVariable ["WL2_inventoryLoadButtons", []];
private _saveButtons = uiNamespace getVariable ["WL2_inventorySaveButtons", []];
private _clearButtons = uiNamespace getVariable ["WL2_inventoryClearButtons", []];

private _loadoutVar = format ["WLC_loadoutIndex_%1", BIS_WL_playerSide];
private _currentLoadoutIndex = profileNamespace getVariable [_loadoutVar, 0];
private _totalButtons = count _loadButtons;

private _loadouts = call WL2_fnc_getLoadouts;
{
    private _index = _forEachIndex + _currentPage * _totalButtons;

    if (_index < INV_MAX_SLOTS) then {
        private _loadout = _loadouts # _index;
        private _text = [_loadout] call WL2_fnc_trimInventoryText;
        _x ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _text];
        _x ctrlShow true;
    } else {
        _x ctrlSetStructuredText parseText "";
        _x ctrlShow false;
    };

    if (_index == _currentLoadoutIndex) then {
        _x ctrlSetBackgroundColor [0.4, 0.6, 0.4, 1];
    } else {
        _x ctrlSetBackgroundColor [0, 0, 0, 1];
    };
} forEach _loadButtons;

{
    private _index = _forEachIndex + _currentPage * _totalButtons;
    if (_index < INV_MAX_SLOTS) then {
        _x ctrlSetStructuredText parseText format ["<t align='center'>Save Slot %1</t>", _index + 1];
        _x ctrlShow true;
    } else {
        _x ctrlSetStructuredText parseText "";
        _x ctrlShow false;
    };
} forEach _saveButtons;

{
    private _index = _forEachIndex + _currentPage * _totalButtons;
    if (_index < INV_MAX_SLOTS) then {
        _x ctrlSetStructuredText parseText format ["<t align='center'>Clear Slot %1</t>", _index + 1];
        _x ctrlShow true;
    } else {
        _x ctrlSetStructuredText parseText "";
        _x ctrlShow false;
    };
} forEach _clearButtons;