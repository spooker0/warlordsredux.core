#include "..\..\warlords_constants.inc"

_display = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];

_purchase_category = _display displayCtrl 100;
_purchase_items = _display displayCtrl 101;
_purchase_pic = _display displayCtrl 102;
_purchase_info = _display displayCtrl 103;
_purchase_info_asset = _display displayCtrl 105;
_purchase_info_asset_container = _display displayCtrl 106;
_purchase_request = _display displayCtrl 107;

_curSel = (lbCurSel _purchase_items) max 0;

_assetDetails = (_purchase_items lbData _curSel) splitString "|||";

_assetDetails params [
	"_className",
	"_requirements",
	"_displayName",
	"_picture",
	"_text",
	"_offset"
];

_requirements = call compile _requirements;

_purchase_pic ctrlSetStructuredText parseText format ["<img image='%1' size='%2' align='center' shadow='0'></img>", _picture, (7.693 call WL2_fnc_purchaseMenuGetUIScale)];
_id = _purchase_category lbValue lbCurSel _purchase_category;
_purchase_info_asset ctrlSetStructuredText parseText format ["<t align='left' size='%2'>%1</t>", _text, 0.75 call WL2_fnc_purchaseMenuGetUIScale];
_cost = _purchase_items lbValue lbCurSel _purchase_items;

private _infoAssetHeight = ctrlTextHeight _purchase_info_asset;
_purchase_info_asset ctrlSetPositionH ((_infoAssetHeight + 0.05) max (safezoneH * 0.27));
_purchase_info_asset ctrlCommit 0;

private _side = side player;
private _moneySign = [_side] call WL2_fnc_getMoneySign;
private _scale = 1.5 call WL2_fnc_purchaseMenuGetUIScale;
private _costDisplay = (_cost call BIS_fnc_numberText) regexReplace [" ", ","];

private _spawnClassMap = missionNamespace getVariable ["WL2_spawnClass", createHashMap];
private _spawnClass = _spawnClassMap getOrDefault [_className, _className];
private _dlcInfo = getAssetDLCInfo [_spawnClass];
private _isDLC = _dlcInfo # 0;
private _isAvailable = _dlcInfo # 3;
private _dlcString = if (_isAvailable || !_isDLC) then {
	""
} else {
	format ["<t align='right'>DLC Missing: %1</t>", _dlcInfo # 5];
};

_purchase_request ctrlSetStructuredText parseText format [
	"<t font='PuristaLight' align='center' shadow='2' size='%1'>%2 (%3%4)</t>%5",
	_scale,
	localize "STR_A3_WL_menu_request",
	_moneySign,
	_costDisplay,
	_dlcString
];
call WL2_fnc_purchaseMenuRefresh;
ctrlSetFocus _purchase_request;