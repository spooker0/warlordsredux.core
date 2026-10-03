#include "includes.inc"

disableSerialization;

private _active = _this;
private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
if (isNull _display) exitWith {};

if (_active) then {
    _display setVariable ["BUY_transferPreviousFocus", focusedCtrl _display];
};

_display setVariable ["BUY_transferActive", _active];

{
    (_display displayCtrl _x) ctrlEnable !_active;
} forEach [BUY_CATEGORY_IDC, BUY_ITEMS_IDC, BUY_REQUEST_IDC, BUY_SEARCH_IDC];
(_display displayCtrl BUY_SEARCH_IDC) ctrlEnable (!_active && !(_display getVariable ["BUY_waitForGearRelease", false]));
private _storedRows = _display getVariable ["BUY_rows", []];
if (!_active && count _storedRows == 0) then {
    (_display displayCtrl BUY_REQUEST_IDC) ctrlEnable false;
};

{
    private _control = _display displayCtrl _x;
    _control ctrlEnable (_active && !(_x in [BUY_TRANSFER_BACKGROUND_IDC, BUY_TRANSFER_OK_BACKGROUND_IDC, BUY_TRANSFER_CANCEL_BACKGROUND_IDC]));
    _control ctrlSetFade ([1, 0] select _active);
    _control ctrlCommit 0;
} forEach BUY_TRANSFER_IDCS;
uiNamespace setVariable ["BIS_WL_fundsTransferPossible", false];
_display setVariable ["BUY_nextRefresh", 0];
call WL2_fnc_purchaseMenuRefresh;

if (!_active) then {
    private _previousFocus = _display getVariable ["BUY_transferPreviousFocus", controlNull];
    if (!isNull _previousFocus && ctrlEnabled _previousFocus) then {
        ctrlSetFocus _previousFocus;
    };
};
