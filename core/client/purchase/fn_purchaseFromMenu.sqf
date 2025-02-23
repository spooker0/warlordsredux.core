#include "..\..\warlords_constants.inc"

params [
    "_className",
    "_requirements",
    "_displayName",
    "_picture",
    "_text",
    "_offset",
    "_cost",
    "_category"
];

_requirements = call compile _requirements;

private _purchaseDetails = [_className, _requirements, _displayName, _picture, _text, _offset, _cost, _category];
private _availability = _purchaseDetails call WL2_fnc_purchaseMenuAssetAvailability;
if (_availability # 0) then {
    _purchaseDetails call WL2_fnc_triggerPurchase;
    playSound "AddItemOK";

    private _tasksRequireUIList = ["FundsTransfer"];
    if !(_className in _tasksRequireUIList) then {
        "RequestMenu_close" call WL2_fnc_setupUI;
    };
} else {
    systemChat format ["Invalid buy action: %1", (_availability # 1) joinString ", "];
    playSound "AddItemFailed";
};