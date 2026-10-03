#include "includes.inc"

disableSerialization;

private _display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];

if (isNull _display) exitWith {};

private _storedBuildingRows = _display getVariable ["BUY_buildingRows", false];
if (_storedBuildingRows) exitWith {};

private _itemsControl = _display displayCtrl BUY_ITEMS_IDC;
private _pictureControl = _display displayCtrl BUY_PICTURE_IDC;
private _detailsControl = _display displayCtrl BUY_DETAILS_IDC;
private _detailsGroup = _display displayCtrl BUY_DETAILS_GROUP_IDC;
private _requestButton = _display displayCtrl BUY_REQUEST_IDC;

private _selection = lbCurSel _itemsControl;
private _rows = _display getVariable ["BUY_rows", []];
if (_selection < 0 || _selection >= count _rows) exitWith {
    _pictureControl ctrlSetText "";
    _detailsControl ctrlSetStructuredText parseText "";
    _requestButton ctrlSetStructuredText parseText "";
    _requestButton ctrlEnable false;
    [_requestButton, [0.06, 0.06, 0.065, 1]] call WL2_fnc_purchaseMenuSetButtonColor;
    uiNamespace setVariable ["BIS_WL_purchaseMenuItemAffordable", false];
};

_requestButton ctrlEnable !(_display getVariable ["BUY_transferActive", false]);
(_rows # _selection) params ["_className", "_requirements", "_displayName", "_picture", "_text", "_offset", "_cost"];
_pictureControl ctrlSetText _picture;
_detailsControl ctrlSetStructuredText parseText format ["<t align='left' size='%2'>%1</t>", _text, 0.75];

private _detailsHeight = ctrlTextHeight _detailsControl;
_detailsControl ctrlSetPositionH ((_detailsHeight + BUY_GRID_H) max ((ctrlPosition _detailsGroup) # 3));
_detailsControl ctrlCommit 0;

private _moneySign = WL_MONEY_SIGN;
private _scale = 1.1;
private _costDisplay = (_cost call BIS_fnc_numberText) regexReplace [" ", ","];

private _spawnClass = WL_ASSET(_className, "spawn", _className);
private _dlcInfo = getAssetDLCInfo [_spawnClass];
private _isDLC = _dlcInfo # 0;
private _isAvailable = _dlcInfo # 3;
private _dlcString = if (_isAvailable || !_isDLC) then {
    ""
} else {
    format ["<t align='right'>DLC Missing: %1</t>", _dlcInfo # 5];
};

_requestButton ctrlSetStructuredText parseText format [
    "<t font='PuristaLight' align='center' shadow='0' size='%1'>%2 (%3%4)</t>%5",
    _scale,
    localize "STR_A3_WL_menu_request",
    _moneySign,
    _costDisplay,
    _dlcString
];
_display setVariable ["BUY_nextRefresh", 0];
call WL2_fnc_purchaseMenuRefresh;
