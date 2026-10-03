#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];

if (isNull _display) exitWith {};

private _now = diag_tickTime;
private _storedNextRefresh = _display getVariable ["BUY_nextRefresh", 0];
if (_now < _storedNextRefresh) exitWith {};

_display setVariable ["BUY_nextRefresh", _now + 0.1];
private _itemsControl = _display displayCtrl BUY_ITEMS_IDC;
private _requestButton = _display displayCtrl BUY_REQUEST_IDC;
private _rows = _display getVariable ["BUY_rows", []];
private _specialRows = _display getVariable ["BUY_specialRows", []];
private _states = _display getVariable ["BUY_rowStates", []];
private _selected = lbCurSel _itemsControl;
private _selectedAvailability = [];
{
    private _details = _x;
    private _availability = _details call WL2_fnc_purchaseMenuAssetAvailability;
    if (_forEachIndex == _selected) then {
        _selectedAvailability = _availability;
    };

    private _special = _specialRows param [_forEachIndex, false];
    private _color = if (_availability # 0) then {
        if (_special) then { [1, 0.85, 0.5, 1] } else { [1, 1, 1, 1] }
    } else {
        if (_special) then { [0.5, 0.42, 0.25, 1] } else { [0.5, 0.5, 0.5, 1] }
    };

    private _tooltip = if (_availability # 0) then { "" } else { (_availability # 1) joinString "\n" };

    private _state = [_color, _tooltip];
    if (_state isNotEqualTo (_states param [_forEachIndex, []])) then {
        _itemsControl lbSetColor [_forEachIndex, _color];
        _itemsControl lbSetTooltip [_forEachIndex, _tooltip];
        _states set [_forEachIndex, _state];
    };

} forEach _rows;
_display setVariable ["BUY_rowStates", _states];

if (count _selectedAvailability == 0) exitWith {
    uiNamespace setVariable ["BIS_WL_purchaseMenuItemAffordable", false];
};

private _availability = _selectedAvailability;
private _color = BIS_WL_colorFriendly;
_requestButton ctrlSetTooltipColorBox [1, 1, 1, 1];
_requestButton ctrlSetTooltipColorText [1, 1, 1, 1];

if (_availability # 0 && ctrlEnabled _requestButton) then {
    uiNamespace setVariable ["BIS_WL_purchaseMenuItemAffordable", true];
    private _storedPurchaseMenuButtonHover = uiNamespace getVariable ["BIS_WL_purchaseMenuButtonHover", false];
    if (_storedPurchaseMenuButtonHover) then {
        _color = BIS_WL_colorFriendly;
        [_requestButton, [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3]] call WL2_fnc_purchaseMenuSetButtonColor;
    } else {
        [_requestButton, _color] call WL2_fnc_purchaseMenuSetButtonColor;
    };

    _requestButton ctrlSetTextColor [1, 1, 1, 1];
    _requestButton ctrlSetTooltip "";
    private _dlcOwned = _availability # 2;
    private _dlcTooltip = _availability # 3;
    if (!_dlcOwned) then {
        _requestButton ctrlSetTooltip _dlcTooltip;
        _requestButton ctrlSetTooltipColorText [1, 0, 0, 1];
        _requestButton ctrlSetTooltipColorBox [1, 0, 0, 1];
    };
} else {
    uiNamespace setVariable ["BIS_WL_purchaseMenuItemAffordable", false];
    [_requestButton, [(_color # 0) * 0.5, (_color # 1) * 0.5, (_color # 2) * 0.5, _color # 3]] call WL2_fnc_purchaseMenuSetButtonColor;
    _requestButton ctrlSetTextColor [0.5, 0.5, 0.5, 1];
    _requestButton ctrlSetTooltip ((_availability # 1) joinString "\n");
};
