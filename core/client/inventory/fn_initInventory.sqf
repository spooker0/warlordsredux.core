#include "includes.inc"

private _display = findDisplay 602;

private _loadoutGroup = _display ctrlCreate ["RscControlsGroup", 6000];
_loadoutGroup ctrlSetPosition [
    safeZoneX / 2,
    safeZoneY / 2,
    1 - safeZoneX,
    0.22
];
_loadoutGroup ctrlCommit 0;

private _loadouts = call WL2_fnc_getLoadouts;

private _xPoint = 0;
private _loadoutNum = 0;

private _loadButtons = [];
private _saveButtons = [];
private _clearButtons = [];
while { _xPoint <= (1 - safeZoneX - INV_BUTTON_WIDTH * 2) } do {
    private _loadButton = _display ctrlCreate ["WLRscInventoryButton", -1, _loadoutGroup];
    _loadButton ctrlSetPosition [_xPoint, 0, INV_BUTTON_WIDTH, 0.12];

    private _loadout = _loadouts # _loadoutNum;

    private _text = [_loadout] call WL2_fnc_trimInventoryText;
    _loadButton ctrlSetFont "PuristaMedium";
    _loadButton ctrlSetFontHeight INV_BUTTON_FONT;
    _loadButton ctrlAddEventHandler ["ButtonClick", WL2_fnc_loadoutButtonClicked];
    _loadButton ctrlCommit 0;

    private _saveButton = _display ctrlCreate ["WLRscInventoryCenterButton", -1, _loadoutGroup];
    _saveButton ctrlSetPosition [_xPoint, 0.13, INV_BUTTON_WIDTH, 0.04];
    _saveButton ctrlSetFont "PuristaMedium";
    _saveButton ctrlSetFontHeight INV_BUTTON_FONT;
    _saveButton ctrlAddEventHandler ["ButtonClick", WL2_fnc_saveButtonClicked];
    _saveButton ctrlCommit 0;

    private _clearButton = _display ctrlCreate ["WLRscInventoryCenterButton", -1, _loadoutGroup];
    _clearButton ctrlSetPosition [_xPoint, 0.18, INV_BUTTON_WIDTH, 0.04];
    _clearButton ctrlSetFont "PuristaMedium";
    _clearButton ctrlSetFontHeight INV_BUTTON_FONT;
    _clearButton ctrlAddEventHandler ["ButtonClick", WL2_fnc_clearButtonClicked];
    _clearButton ctrlCommit 0;

    _loadButton setVariable ["WL2_loadoutIndex", _loadoutNum];
    _saveButton setVariable ["WL2_loadoutIndex", _loadoutNum];
    _clearButton setVariable ["WL2_loadoutIndex", _loadoutNum];

    _loadButtons pushBack _loadButton;
    _saveButtons pushBack _saveButton;
    _clearButtons pushBack _clearButton;

    _xPoint = _xPoint + INV_BUTTON_WIDTH + 0.01;
    _loadoutNum = _loadoutNum + 1;
};

uiNamespace setVariable ["WL2_inventoryLoadButtons", _loadButtons];
uiNamespace setVariable ["WL2_inventorySaveButtons", _saveButtons];
uiNamespace setVariable ["WL2_inventoryClearButtons", _clearButtons];

private _previousButton = _display ctrlCreate ["WLRscInventoryCenterButton", -1, _loadoutGroup];
_previousButton ctrlSetPosition [_xPoint, 0, INV_BUTTON_WIDTH, 0.05];
_previousButton ctrlSetStructuredText parseText "<t align='center'>Previous</t>";
_previousButton ctrlSetFont "PuristaMedium";
_previousButton ctrlSetFontHeight 0.04;
_previousButton ctrlAddEventHandler ["ButtonClick", WL2_fnc_previousButtonClicked];
_previousButton ctrlCommit 0;

private _arsenalButton = _display ctrlCreate ["WLRscInventoryCenterButton", -1, _loadoutGroup];
_arsenalButton ctrlSetPosition [_xPoint, 0.06, INV_BUTTON_WIDTH, 0.1];
_arsenalButton ctrlSetStructuredText parseText format ["<t align='center'>Arsenal</t>"];
_arsenalButton ctrlSetFont "PuristaMedium";
_arsenalButton ctrlSetFontHeight 0.038;
_arsenalButton ctrlAddEventHandler ["ButtonClick", {
    private _arsenalEligibility = ["Arsenal", [], "", "", "", [], 0, "Gear"] call WL2_fnc_purchaseMenuAssetAvailability;
    if (_arsenalEligibility # 0) then {
        playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
        [player, "orderArsenal"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    } else {
        private _errors = _arsenalEligibility # 1;
        {
            [_x] call WL2_fnc_smoothText;
        } forEach _errors;
        playSoundUI ["AddItemFailed"];
    };
}];
_arsenalButton ctrlCommit 0;

private _nextButton = _display ctrlCreate ["WLRscInventoryCenterButton", -1, _loadoutGroup];
_nextButton ctrlSetPosition [_xPoint, 0.17, INV_BUTTON_WIDTH, 0.05];
_nextButton ctrlSetStructuredText parseText "<t align='center'>Next</t>";
_nextButton ctrlSetFont "PuristaMedium";
_nextButton ctrlSetFontHeight 0.04;
_nextButton ctrlAddEventHandler ["ButtonClick", WL2_fnc_nextButtonClicked];
_nextButton ctrlCommit 0;

uiNamespace setVariable ["WL2_inventoryNextButton", _nextButton];
uiNamespace setVariable ["WL2_inventoryPreviousButton", _previousButton];

_previousButton ctrlEnable false;

call WL2_fnc_pageChanged;

private _dummyButton = _display ctrlCreate ["WLDummyButton", 1338];
_dummyButton ctrlCommit 0;