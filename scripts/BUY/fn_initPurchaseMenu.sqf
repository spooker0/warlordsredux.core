#include "includes.inc"
disableSerialization;

if (isDedicated) exitWith {};

waitUntil { !isNull findDisplay 46 };

WL2_tutorialComplete = true;

if (WL_GEAR_BUY_MENU) exitWith {};

if (WL_ISUNCONSCIOUS(player)) exitWith {};

(findDisplay 602) closeDisplay 2;

WL_GEAR_BUY_MENU = true;

hintSilent "";

private _display = (findDisplay 46) createDisplay "BUY_Menu";
if (isNull _display) exitWith {
    WL_GEAR_BUY_MENU = false;
};

ctrlSetFocus (_display displayCtrl BUY_DUMMY_IDC);
private _waitForGearRelease = missionNamespace getVariable ["WL_gearKeyPressed", false];
_display setVariable ["BUY_waitForGearRelease", _waitForGearRelease];
(_display displayCtrl BUY_SEARCH_IDC) ctrlEnable !_waitForGearRelease;

WL_CONTROL_MAP ctrlEnable false;

_display displayAddEventHandler ["Unload", {
    params ["_display"];
    private _transferHandle = _display getVariable ["BUY_transferHandle", scriptNull];
    if (!scriptDone _transferHandle) then {
        terminate _transferHandle;
    };

    uiNamespace setVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
    private _query = _display getVariable ["BUY_query", ""];
    private _selection = if (_query == "") then {
        [lbCurSel (_display displayCtrl BUY_CATEGORY_IDC), lbCurSel (_display displayCtrl BUY_ITEMS_IDC), 0]
    } else { _display getVariable ["BUY_browseSelection", [0, 0, 0]] };

    uiNamespace setVariable ["BIS_WL_purchaseMenuLastSelection", _selection];

    if (ctrlEnabled (_display displayCtrl BUY_TRANSFER_CANCEL_IDC)) then {
        playSound "AddItemFailed";
    };

    WL_TEMP_BUY_MENU = false;
    WL_GEAR_BUY_MENU = false;
    WL_CONTROL_MAP ctrlEnable true;
    hint "";
}];

WL_TEMP_BUY_MENU = false;
uiNamespace setVariable ["WL_BuyMenuCode", ""];
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    private _storedWaitForGearRelease = _display getVariable ["BUY_waitForGearRelease", false];
    if (_storedWaitForGearRelease && _key in actionKeys "Gear") exitWith {
        true
    };

    [_key] call WL2_fnc_handleBuyMenuKeypress;
}];

[_display] spawn {
    params ["_display"];
    disableSerialization;

    waitUntil {
        uiSleep WL_TIMEOUT_SHORT;
        WL_ISUNCONSCIOUS(player) || isNull _display
    };

    if (!isNull _display) then {
        _display closeDisplay 1;
    };
};

_display displayAddEventHandler ["KeyUp", {
    params ["_display", "_key"];

    if (_key == DIK_SPACE) then {
        _display setVariable ["BUY_spaceHeld", false];
    };

    if (_key in actionKeys "Gear") then {
        WL_gearKeyPressed = false;
        private _storedWaitForGearRelease = _display getVariable ["BUY_waitForGearRelease", false];
        if (_storedWaitForGearRelease) then {
            _display setVariable ["BUY_waitForGearRelease", false];
            private _search = _display displayCtrl BUY_SEARCH_IDC;
            private _transferActive = _display getVariable ["BUY_transferActive", false];
            _search ctrlEnable !_transferActive;

        };
    };

}];

_display displayAddEventHandler ["KeyDown", WL2_fnc_timedPromptKeyHandler];

private _categoryControl = _display displayCtrl BUY_CATEGORY_IDC;
private _itemsControl = _display displayCtrl BUY_ITEMS_IDC;
private _requestButton = _display displayCtrl BUY_REQUEST_IDC;
private _transferSlider = _display displayCtrl BUY_TRANSFER_SLIDER_IDC;
private _transferButton = _display displayCtrl BUY_TRANSFER_OK_IDC;
private _cancelButton = _display displayCtrl BUY_TRANSFER_CANCEL_IDC;
uiNamespace setVariable ["BIS_WL_purchaseMenuDisplay", _display];
uiNamespace setVariable ["BIS_WL_purchaseMenuButtonHover", false];
[_requestButton, BIS_WL_colorFriendly] call WL2_fnc_purchaseMenuSetButtonColor;
[_transferButton, BIS_WL_colorFriendly] call WL2_fnc_purchaseMenuSetButtonColor;
[_cancelButton, BIS_WL_colorFriendly] call WL2_fnc_purchaseMenuSetButtonColor;

{
    private _control = _display displayCtrl _x;
    _control ctrlSetFade 1;
    _control ctrlEnable false;
    _control ctrlCommit 0;
} forEach BUY_TRANSFER_IDCS;

call WL2_fnc_purchaseMenuBuildCatalog;
call WL2_fnc_purchaseMenuSetCategories;
private _search = _display displayCtrl BUY_SEARCH_IDC;
_search setVariable ["BUY_searchPlaceholder", true];
_search ctrlAddEventHandler ["SetFocus", {
    params ["_search"];

    private _placeholder = _search getVariable ["BUY_searchPlaceholder", false];
    if (_placeholder) then {
        _search setVariable ["BUY_searchPlaceholder", false];
        _search ctrlSetText "";
    };
}];
_search ctrlAddEventHandler ["KillFocus", {
    params ["_search"];

    private _query = ctrlText _search;
    if (_query == "") then {
        _search setVariable ["BUY_searchPlaceholder", true];
        _search ctrlSetText "Search...";
    };
}];
_search ctrlAddEventHandler ["KeyUp", WL2_fnc_purchaseMenuSearch];
_categoryControl ctrlAddEventHandler ["LBSelChanged", {
    call WL2_fnc_purchaseMenuSetItemsList;
}];

_itemsControl ctrlAddEventHandler ["LBSelChanged", {
    call WL2_fnc_purchaseMenuSetAssetDetails;
}];
_itemsControl ctrlAddEventHandler ["LBDblClick", {
    params ["_control", "_selection"];

    if (_selection < 0) exitWith {};

    _control lbSetCurSel _selection;
    call WL2_fnc_purchaseMenuRequest;
}];

[_requestButton, "BIS_WL_purchaseMenuItemAffordable"] call WL2_fnc_purchaseMenuBindButton;
_requestButton ctrlAddEventHandler ["ButtonClick", { call WL2_fnc_purchaseMenuRequest; }];

_transferSlider ctrlAddEventHandler ["SliderPosChanged", {
    params ["_control", "_storedNew"];
    private _display = ctrlParent _control;
    private _transferAmount = _display displayCtrl BUY_TRANSFER_AMOUNT_IDC;
    _transferAmount ctrlSetText str floor _storedNew;
}];

[_transferButton, "BIS_WL_fundsTransferPossible"] call WL2_fnc_purchaseMenuBindButton;
_transferButton ctrlAddEventHandler ["ButtonClick", { call WL2_fnc_purchaseMenuConfirmTransfer; }];

[_cancelButton] call WL2_fnc_purchaseMenuBindButton;
_cancelButton ctrlAddEventHandler ["ButtonClick", {
    false call WL2_fnc_purchaseMenuSetTransferMode;
    playSound "AddItemFailed";
}];
call WL2_fnc_purchaseMenuSetItemsList;
ctrlSetFocus (_display displayCtrl BUY_DUMMY_IDC);

// Refresh only while this display exists; dynamic eligibility is never cached across purchases.
[_display] spawn {
    params ["_display"];
    disableSerialization;

    while { !isNull _display && !BIS_WL_missionEnd } do {
        uiSleep BUY_REFRESH_INTERVAL;

        if (!isNull _display) then {
            call WL2_fnc_purchaseMenuRefresh;
            call WL2_fnc_purchaseMenuUpdateCategoryTooltips;
        };
    };
};
