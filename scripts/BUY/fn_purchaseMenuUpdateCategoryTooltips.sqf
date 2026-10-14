#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _categories = _display displayCtrl BUY_CATEGORY_IDC;
private _storedQuery = _display getVariable ["BUY_query", ""];
if (_storedQuery != "") exitWith {
    private _tooltip = format ["%1 (%2)", localize "STR_WL_buySearchResults", count (_display getVariable ["BUY_rows", []])];
    private _storedSearchTooltip = _display getVariable ["BUY_searchTooltip", ""];
    if (_tooltip != _storedSearchTooltip) then {
        _categories lbSetTooltip [0, _tooltip];
        _display setVariable ["BUY_searchTooltip", _tooltip];
    };
};

private _infantryRow = -1;
for "_row" from 0 to (lbSize _categories - 1) do {
    if (_categories lbValue _row == 0) exitWith {
        _infantryRow = _row;
    };
};

if (_infantryRow < 0) exitWith {};

private _maxSubordinates = missionNamespace getVariable ["WL2_maxSubordinates", 1];
private _slots = ((units group player) - [player]) apply { name _x };

for "_slot" from 1 to (_maxSubordinates - count _slots) do {
    _slots pushBack "Ready";
};

private _tooltip = format ["Subordinates (Max: %1)\n%2", _maxSubordinates, _slots joinString ", "];
private _storedInfantryTooltip = _display getVariable ["BUY_infantryTooltip", ""];
if (_tooltip != _storedInfantryTooltip) then {
    _categories lbSetTooltip [_infantryRow, _tooltip];
    _display setVariable ["BUY_infantryTooltip", _tooltip];
};
