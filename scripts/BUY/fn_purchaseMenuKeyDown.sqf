#include "includes.inc"
params ["_menuDisplay", "_key"];

if (isNull _menuDisplay) exitWith {
    false
};

private _storedTransferActive = _menuDisplay getVariable ["BUY_transferActive", false];
if (_storedTransferActive) exitWith {
    false
};

private _search = _menuDisplay displayCtrl BUY_SEARCH_IDC;
if (_key == DIK_SPACE) exitWith {
    private _storedSpaceHeld = _menuDisplay getVariable ["BUY_spaceHeld", false];
    if (!_storedSpaceHeld) then {
        _menuDisplay setVariable ["BUY_spaceHeld", true];
        [_search] call WL2_fnc_purchaseMenuSearch;
        call WL2_fnc_purchaseMenuRequest;
    };

    true
};

if (_key in [DIK_UP, DIK_DOWN] && focusedCtrl _menuDisplay == _search) exitWith {
    private _items = _menuDisplay displayCtrl BUY_ITEMS_IDC;
    private _step = if (_key == DIK_DOWN) then { 1 } else { -1 };

    _items lbSetCurSel ((lbCurSel _items + _step) max 0 min (lbSize _items - 1));
    true
};

if (focusedCtrl _menuDisplay == _search) exitWith {
    false
};

private _waitForGearRelease = _menuDisplay getVariable ["BUY_waitForGearRelease", false];
private _numberKeys = [DIK_0, DIK_1, DIK_2, DIK_3, DIK_4, DIK_5, DIK_6, DIK_7, DIK_8, DIK_9];
private _numpadKeys = [DIK_NUMPAD0, DIK_NUMPAD1, DIK_NUMPAD2, DIK_NUMPAD3, DIK_NUMPAD4, DIK_NUMPAD5, DIK_NUMPAD6, DIK_NUMPAD7, DIK_NUMPAD8, DIK_NUMPAD9];
private _digit = _numberKeys find _key;
if (_digit < 0) then {
    _digit = _numpadKeys find _key;
};

private _focusSearch = _digit >= 0 || _key == DIK_BACKSPACE;
if (_focusSearch && !_waitForGearRelease && ctrlEnabled _search) exitWith {
    private _placeholder = _search getVariable ["BUY_searchPlaceholder", false];
    private _query = ctrlText _search;
    if (_placeholder) then {
        _query = "";
    };

    if (_key == DIK_BACKSPACE) then {
        _query = _query select [0, (count _query - 1) max 0];
    } else {
        _query = _query + str _digit;
    };

    ctrlSetFocus _search;
    _search setVariable ["BUY_searchPlaceholder", false];
    _search ctrlSetText _query;
    _search ctrlSetTextSelection [count _query, 0];
    [_search] call WL2_fnc_purchaseMenuSearch;
    true
};

if (_key in actionKeys "Gear" && !WL_gearKeyPressed) exitWith {
    _menuDisplay closeDisplay 1;
    true
};

false
