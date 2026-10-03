#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _storedFiltering = _display getVariable ["BUY_filtering", false];
if (_storedFiltering) exitWith {};

private _category = _display displayCtrl BUY_CATEGORY_IDC;
private _items = _display displayCtrl BUY_ITEMS_IDC;
private _query = _display getVariable ["BUY_query", ""];
private _catalog = _display getVariable ["BUY_catalog", []];
private _entries = [];
if (_query == "") then {
    private _categoryIndex = _category lbValue lbCurSel _category;
    _entries = _catalog select { (_x # 5) == _categoryIndex };
} else {
    private _numeric = count ((toArray _query) select { _x < 48 || _x > 57 }) == 0;
    private _words = _query splitString " ";
    _entries = _catalog select {
        if (_numeric) then { ((_x # 1) find _query) == 0 } else {
            private _name = _x # 2;
            count (_words select { !(_x in _name) }) == 0
        }
    };
};

_display setVariable ["BUY_buildingRows", true];
lbClear _items;
uiNamespace setVariable ["BIS_WL_removeUnitsListID", -1];

{
    _x params ["_details", "_code", "", "_icon"];
    _details params ["_className", "", "_name"];
    private _row = _items lbAdd format ["%1 [%2]", _name, _code];
    _items lbSetValue [_row, _details # 6];

    if (_icon != "" && "\" in _icon) then {
        _items lbSetPictureRight [_row, _icon];
    };

    if (_className == "RemoveUnits") then {
        uiNamespace setVariable ["BIS_WL_removeUnitsListID", _row];
    };

} forEach _entries;
_display setVariable ["BUY_rows", _entries apply { _x # 0 }];
_display setVariable ["BUY_specialRows", _entries apply { _x # 4 }];
_display setVariable ["BUY_rowStates", []];
private _selection = 0;
if (_query == "") then {
    private _saved = _display getVariable ["BUY_browseSelection", uiNamespace getVariable ["BIS_WL_purchaseMenuLastSelection", [0, 0, 0]]];
    _selection = (_saved # 1) max 0 min (count _entries - 1);
};

_items lbSetCurSel (if (count _entries > 0) then { _selection } else { -1 });
_display setVariable ["BUY_buildingRows", false];
call WL2_fnc_purchaseMenuUpdateCategoryTooltips;
call WL2_fnc_purchaseMenuSetAssetDetails;
