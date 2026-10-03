#include "includes.inc"
params ["_searchControl"];
disableSerialization;

private _display = ctrlParent _searchControl;
if (isNull _display) exitWith {};

private _storedTransferActive = _display getVariable ["BUY_transferActive", false];
private _storedWaitForGearRelease = _display getVariable ["BUY_waitForGearRelease", false];
if (_storedTransferActive || _storedWaitForGearRelease) exitWith {};

private _placeholder = _searchControl getVariable ["BUY_searchPlaceholder", false];
private _searchText = ctrlText _searchControl;
if (_placeholder) then {
    _searchText = "";
};

private _query = ((toLower _searchText) splitString " ") joinString " ";
private _previousQuery = _display getVariable ["BUY_query", ""];
if (_query == _previousQuery) exitWith {};

private _categoryControl = _display displayCtrl BUY_CATEGORY_IDC;
private _itemsControl = _display displayCtrl BUY_ITEMS_IDC;
private _wasSearching = _previousQuery != "";
if (!_wasSearching && _query != "") then {
    _display setVariable ["BUY_browseSelection", [lbCurSel _categoryControl, lbCurSel _itemsControl, 0]];
};

_display setVariable ["BUY_query", _query];
_display setVariable ["BUY_filtering", true];

if (_query != "") then {
    if (!_wasSearching) then {
        lbClear _categoryControl;
        _display setVariable ["BUY_searchTooltip", ""];
        private _row = _categoryControl lbAdd localize "STR_WL_buySearchResults";
        _categoryControl lbSetValue [_row, -1];
        _categoryControl lbSetCurSel _row;
    };
} else {
    call WL2_fnc_purchaseMenuSetCategories;
};

_display setVariable ["BUY_filtering", false];
call WL2_fnc_purchaseMenuSetItemsList;
