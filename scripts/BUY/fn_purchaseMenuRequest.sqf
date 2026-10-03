#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

private _storedTransferActive = _display getVariable ["BUY_transferActive", false];
if (_storedTransferActive) exitWith {};

private _selection = lbCurSel (_display displayCtrl BUY_ITEMS_IDC);
private _rows = _display getVariable ["BUY_rows", []];
if (_selection < 0 || _selection >= count _rows) exitWith {};

// The purchase path rechecks eligibility; selecting / filtering never orders an asset.
(_rows # _selection) call WL2_fnc_purchaseFromMenu;
