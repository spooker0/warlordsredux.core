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

// WL2_fnc_loadoutButtonClicked = {
//     params ["_control"];
//     playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

//     private _display = ctrlParent _control;

//     private _loadoutIndex = _control getVariable ["WL2_loadoutIndex", -1];
//     private _page = uiNamespace getVariable ["WL2_inventoryPage", 0];
//     private _index = _page * 10 + _loadoutIndex;

//     private _loadoutIndexVar = format ["WLC_loadoutIndex_%1", BIS_WL_playerSide];
//     profileNamespace setVariable [_loadoutIndexVar, _index];

//     call WL2_fnc_pageChanged;

//     private _dummyButton = _display displayCtrl 1338;
//     [_dummyButton] spawn {
//         params ["_dummyButton"];
//         uiSleep 0.1;
//         ctrlSetFocus _dummyButton;
//     };
// };

// WL2_fnc_saveButtonClicked = {
//     params ["_control"];
//     playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

//     private _display = ctrlParent _control;

//     private _loadoutIndex = _control getVariable ["WL2_loadoutIndex", -1];
//     private _page = uiNamespace getVariable ["WL2_inventoryPage", 0];
//     private _index = _page * 10 + _loadoutIndex;

//     private _currentLoadout = getUnitLoadout player;
//     profileNamespace setVariable [format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _index], _currentLoadout];

//     call WL2_fnc_pageChanged;

//     private _dummyButton = _display displayCtrl 1338;
//     [_dummyButton] spawn {
//         params ["_dummyButton"];
//         uiSleep 0.1;
//         ctrlSetFocus _dummyButton;
//     };
// };

// WL2_fnc_clearButtonClicked = {
//     params ["_control"];
//     playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

//     private _display = ctrlParent _control;

//     private _loadoutIndex = _control getVariable ["WL2_loadoutIndex", -1];
//     private _page = uiNamespace getVariable ["WL2_inventoryPage", 0];
//     private _index = _page * 10 + _loadoutIndex;

//     private _loadoutVar = format ["WLC_savedLoadout_%1_%2", BIS_WL_playerSide, _index];
//     profileNamespace setVariable [_loadoutVar, []];

//     call WL2_fnc_pageChanged;

//     private _dummyButton = _display displayCtrl 1338;
//     [_dummyButton] spawn {
//         params ["_dummyButton"];
//         uiSleep 0.1;
//         ctrlSetFocus _dummyButton;
//     };
// };

// WL2_fnc_pageChanged = {
//     private _currentPage = uiNamespace getVariable ["WL2_inventoryPage", 0];

//     private _previousButton = uiNamespace getVariable ["WL2_inventoryPreviousButton", objNull];
//     private _nextButton = uiNamespace getVariable ["WL2_inventoryNextButton", objNull];

//     if (!isNull _previousButton) then {
//         _previousButton ctrlEnable (_currentPage > 0);
//     };
//     if (!isNull _nextButton) then {
//         private _loadButtons = uiNamespace getVariable ["WL2_inventoryLoadButtons", []];
//         private _totalButtons = count _loadButtons;
//         private _totalPages = ceil (INV_MAX_SLOTS / _totalButtons) - 1;

//         _nextButton ctrlEnable (_currentPage < _totalPages);
//     };

//     private _loadButtons = uiNamespace getVariable ["WL2_inventoryLoadButtons", []];
//     private _saveButtons = uiNamespace getVariable ["WL2_inventorySaveButtons", []];
//     private _clearButtons = uiNamespace getVariable ["WL2_inventoryClearButtons", []];

//     private _loadoutVar = format ["WLC_loadoutIndex_%1", BIS_WL_playerSide];
//     private _currentLoadoutIndex = profileNamespace getVariable [_loadoutVar, 0];
//     private _totalButtons = count _loadButtons;

//     private _loadouts = call WL2_fnc_getLoadouts;
//     {
//         private _index = _forEachIndex + _currentPage * _totalButtons;

//         if (_index < INV_MAX_SLOTS) then {
//             private _loadout = _loadouts # _index;
//             private _text = [_loadout] call WL2_fnc_trimInventoryText;
//             _x ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _text];
//             _x ctrlShow true;
//         } else {
//             _x ctrlSetStructuredText parseText "";
//             _x ctrlShow false;
//         };

//         if (_index == _currentLoadoutIndex) then {
//             _x ctrlSetBackgroundColor [0.4, 0.6, 0.4, 1];
//         } else {
//             _x ctrlSetBackgroundColor [0, 0, 0, 1];
//         };
//     } forEach _loadButtons;

//     {
//         private _index = _forEachIndex + _currentPage * _totalButtons;
//         if (_index < INV_MAX_SLOTS) then {
//             _x ctrlSetStructuredText parseText format ["<t align='center'>Save Slot %1</t>", _index + 1];
//             _x ctrlShow true;
//         } else {
//             _x ctrlSetStructuredText parseText "";
//             _x ctrlShow false;
//         };
//     } forEach _saveButtons;

//     {
//         private _index = _forEachIndex + _currentPage * _totalButtons;
//         if (_index < INV_MAX_SLOTS) then {
//             _x ctrlSetStructuredText parseText format ["<t align='center'>Clear Slot %1</t>", _index + 1];
//             _x ctrlShow true;
//         } else {
//             _x ctrlSetStructuredText parseText "";
//             _x ctrlShow false;
//         };
//     } forEach _clearButtons;
// };

// WL2_fnc_nextButtonClicked = {
//     params ["_control"];
//     playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

//     private _display = ctrlParent _control;

//     private _loadButtons = uiNamespace getVariable ["WL2_inventoryLoadButtons", []];
//     private _totalButtons = count _loadButtons;
//     private _totalPages = ceil (INV_MAX_SLOTS / _totalButtons) - 1;

//     private _currentPage = uiNamespace getVariable ["WL2_inventoryPage", 0];
//     _currentPage = (_currentPage + 1) min _totalPages;
//     uiNamespace setVariable ["WL2_inventoryPage", _currentPage];

//     call WL2_fnc_pageChanged;

//     private _dummyButton = _display displayCtrl 1338;
//     [_dummyButton] spawn {
//         params ["_dummyButton"];
//         uiSleep 0.1;
//         ctrlSetFocus _dummyButton;
//     };
// };

// WL2_fnc_previousButtonClicked = {
//     params ["_control"];
//     playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

//     private _display = ctrlParent _control;

//     private _currentPage = uiNamespace getVariable ["WL2_inventoryPage", 0];
//     _currentPage = (_currentPage - 1) max 0;
//     uiNamespace setVariable ["WL2_inventoryPage", _currentPage];

//     call WL2_fnc_pageChanged;

//     private _dummyButton = _display displayCtrl 1338;
//     [_dummyButton] spawn {
//         params ["_dummyButton"];
//         uiSleep 0.1;
//         ctrlSetFocus _dummyButton;
//     };
// };

// WL2_fnc_trimInventoryText = {
//     params ["_loadout"];
//     private _text = "";
//     {
//         if (_x == "") then {
//             continue;
//         };
//         private _weapon = _x;
//         private _maxLetters = 0;
//         for "_i" from 0 to count _weapon do {
//             private _fragment = _weapon select [0, _i];
//             _fragment = format ["%1<br/>", _fragment];
//             private _width = _fragment getTextWidth ["PuristaMedium", INV_BUTTON_FONT];
//             _width = _width - 0.016;
//             if (_width > INV_BUTTON_WIDTH) then {
//                 break;
//             };
//             _maxLetters = _i;
//         };
//         private _weaponDisplay = _weapon select [0, _maxLetters];
//         if (_weaponDisplay != "") then {
//             _text = format ["%1%2<br/>", _text, _weaponDisplay];
//         };
//     } forEach _loadout;
//     if (_text == "") then {
//         _text = "(Empty)";
//     };
//     _text
// };

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
    closeDialog 0;
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    "RequestMenu_close" call WL2_fnc_setupUI;
    [player, "orderArsenal"] remoteExec ["WL2_fnc_handleClientRequest", 2];
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