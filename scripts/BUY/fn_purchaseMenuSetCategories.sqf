#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _categoryControl = _display displayCtrl BUY_CATEGORY_IDC;
_display setVariable ["BUY_filtering", true];
lbClear _categoryControl;

{
    _x params ["_name", "_categoryIndex", "_code", "_tooltip"];
    private _row = _categoryControl lbAdd format ["%1 [%2]", _name, _code];
    _categoryControl lbSetValue [_row, _categoryIndex];
    _categoryControl lbSetTooltip [_row, _tooltip];
} forEach (_display getVariable ["BUY_categories", []]);
private _savedSelection = _display getVariable ["BUY_browseSelection", uiNamespace getVariable ["BIS_WL_purchaseMenuLastSelection", [0, 0, 0]]];
_categoryControl lbSetCurSel ((_savedSelection # 0) max 0 min (lbSize _categoryControl - 1));
_display setVariable ["BUY_filtering", false];
_display setVariable ["BUY_infantryTooltip", ""];
