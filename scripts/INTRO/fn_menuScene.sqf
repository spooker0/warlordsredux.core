#include "includes.inc"
#include "..\BUY\includes.inc"
params ["_display", "_mode"];
disableSerialization;
if (isNull _display) exitWith {};

if (_mode == "update") exitWith {
    if ((_display getVariable ["INTRO_menuMode", ""]) != "travel") exitWith {};
    private _map = _display displayCtrl INTRO_MAP_IDC;
    private _sector = (_display getVariable ["INTRO_sectors", createHashMap]) getOrDefault ["MainPower", createHashMap];
    if (isNull _map || count _sector == 0) exitWith {};

    private _screen = _map ctrlMapWorldToScreen (_sector get "position");
    if (count _screen != 2) exitWith {};
    private _menuSize = _display getVariable ["INTRO_menuSize", [0.5, 0.225]];
    private _anchorX = ((_screen # 0) + safeZoneW * 0.04) max (safeZoneX + safeZoneW * 0.03);
    private _anchorY = ((_screen # 1) - safeZoneH * 0.03) max (safeZoneY + safeZoneH * 0.18);
    _anchorX = _anchorX min (safeZoneX + safeZoneW * 0.97 - (_menuSize # 0));
    _anchorY = _anchorY min (safeZoneY + safeZoneH * 0.85 - (_menuSize # 1));
    private _time = (diag_tickTime - (_display getVariable ["INTRO_sceneStart", diag_tickTime])) * (_display getVariable ["INTRO_animationScale", 1]);

    private _buttonOrder = _display getVariable ["INTRO_menuButtonOrder", []];
    private _highlightId = "";
    if (count _buttonOrder > 0) then {
        private _index = ((count _buttonOrder - 1) - floor (((_time - 0.5) max 0) / 0.2)) max 0;
        _highlightId = _buttonOrder # _index;
    };
    {
        private _position = +(_x getVariable ["INTRO_menuPosition", [0, 0, 0, 0]]);
        _position set [0, (_position # 0) + _anchorX];
        _position set [1, (_position # 1) + _anchorY];
        _x ctrlSetPosition _position;
        if (_x getVariable ["INTRO_menuBackground", false]) then {
            _x ctrlSetBackgroundColor (if ((_x getVariable ["WL2_mapButtonId", ""]) == _highlightId) then {
                [0.55, 0.55, 0.55, 1]
            } else {
                [0, 0, 0, 1]
            });
        };
        _x ctrlSetFade (if (_time < 0.5) then { 1 } else { 0 });
        _x ctrlCommit 0;
    } forEach (_display getVariable ["INTRO_menuControls", []]);
    if (_time >= 0.5 && { _highlightId != "" }) then {
        private _sound = if (_highlightId == (_buttonOrder # 0)) then {
            ["a3\ui_f\data\sound\rscbuttonmenu\soundclick.wss", 1]
        } else {
            ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 1]
        };
        [_display, format ["menu-%1", _highlightId], _sound] call INTRO_fnc_soundCue;
    };
};

{
    if (!isNull _x) then { ctrlDelete _x; };
} forEach (_display getVariable ["INTRO_menuControls", []]);
_display setVariable ["INTRO_menuControls", []];
_display setVariable ["INTRO_menuButtonOrder", []];
_display setVariable ["INTRO_menuMode", _mode];
if (_mode == "hide") exitWith {};

if (_mode == "purchase") exitWith {
    private _menuConfig = missionConfigFile >> "BUY_Menu" >> "controls";
    private _scaleY = 0.55 / (BUY_PANEL_H / 40);
    private _panelWidth = BUY_PANEL_W * BUY_GRID_W;
    private _left = safeZoneX + (safeZoneW - _panelWidth) * 0.5;
    private _top = safeZoneY + safeZoneH * 0.20;
    private _created = [];
    {
        private _prototype = _menuConfig >> _x;
        private _control = _display ctrlCreate [_prototype, getNumber (_prototype >> "idc")];
        _created pushBack _control;
        private _position = ctrlPosition _control;
        _control ctrlSetPosition [
            _left + ((_position # 0) - BUY_X),
            _top + ((_position # 1) - BUY_Y) * _scaleY,
            _position # 2,
            (_position # 3) * _scaleY
        ];
        _control ctrlSetFontHeight (BUY_GRID_H * 0.9);
        _control ctrlEnable false;
        _control ctrlCommit 0;
    } forEach ["Background", "Search", "Categories", "Items", "Picture", "Details", "RequestBackground", "Request"];
    _display setVariable ["INTRO_menuControls", _created];

    (_display displayCtrl BUY_SEARCH_IDC) ctrlSetText localize "STR_WL_introSearch";

    [_display] call WL2_fnc_purchaseMenuBuildCatalog;
    private _categories = _display displayCtrl BUY_CATEGORY_IDC;
    private _categorySelection = -1;
    {
        _x params ["_name", "_categoryIndex", "_code"];
        private _row = _categories lbAdd format ["%1 [%2]", _name, _code];
        _categories lbSetValue [_row, _categoryIndex];
        if (_categoryIndex == 1) then { _categorySelection = _row; };
    } forEach (_display getVariable ["BUY_categories", []]);
    _categories lbSetCurSel _categorySelection;

    private _entries = (_display getVariable ["BUY_catalog", []]) select { (_x # 5) == 1 };
    private _items = _display displayCtrl BUY_ITEMS_IDC;
    {
        _x params ["_details", "_code", "", "_icon"];
        private _row = _items lbAdd format ["%1 [%2]", _details # 2, _code];
        _items lbSetValue [_row, _details # 6];
        if (_icon != "" && "\" in _icon) then { _items lbSetPictureRight [_row, _icon]; };
        _items lbSetTooltip [_row, format ["%1%2", WL_MONEY_SIGN, _details # 6]];
    } forEach _entries;

    private _selection = _entries findIf { "hmg" in toLower ((_x # 0) # 0) };
    _selection = _selection max 0;
    _items lbSetCurSel (if (count _entries > 0) then { _selection } else { -1 });
    if (count _entries > 0) then {
        ((_entries # _selection) # 0) params ["", "", "_name", "_picture", "_text", "", "_cost"];
        (_display displayCtrl BUY_PICTURE_IDC) ctrlSetText _picture;
        private _detailsGroup = _display displayCtrl BUY_DETAILS_GROUP_IDC;
        private _details = _detailsGroup controlsGroupCtrl BUY_DETAILS_IDC;
        if (isNull _details) then {
            _details = _display ctrlCreate [_menuConfig >> "Details" >> "controls" >> "Text", BUY_DETAILS_IDC, _detailsGroup];
        };
        private _groupPosition = ctrlPosition _detailsGroup;
        _details ctrlSetPosition [0, 0, _groupPosition # 2, _groupPosition # 3];
        _details ctrlSetFontHeight (BUY_GRID_H * 0.85);
        _details ctrlSetStructuredText parseText format ["<t align='left' size='0.75'>%1</t>", _text];
        _details ctrlEnable false;
        _details ctrlCommit 0;
        private _costText = (_cost call BIS_fnc_numberText) regexReplace [" ", ","];
        private _requestText = format [
            "<t font='PuristaLight' align='center' shadow='0' size='1.1'>%1 (%2%3)</t>",
            localize "STR_A3_WL_menu_request", WL_MONEY_SIGN, _costText
        ];
        private _request = _display displayCtrl BUY_REQUEST_IDC;
        _request ctrlSetStructuredText parseText _requestText;

        private _requestLabel = _display ctrlCreate ["BUY_Text", -1];
        _requestLabel ctrlSetPosition (ctrlPosition _request);
        _requestLabel ctrlSetStructuredText parseText _requestText;
        _requestLabel ctrlEnable false;
        _requestLabel ctrlCommit 0;
        _created pushBack _requestLabel;
        _display setVariable ["INTRO_menuControls", _created];
        (_display displayCtrl BUY_REQUEST_BACKGROUND_IDC) ctrlSetBackgroundColor (missionNamespace getVariable ["BIS_WL_colorFriendly", [0.1, 0.35, 0.7, 1]]);
    };
};

if (_mode == "travel") exitWith {
    private _sector = (_display getVariable ["INTRO_sectors", createHashMap]) getOrDefault ["MainPower", createHashMap];
    if (count _sector == 0) exitWith {};
    private _iconMap = uiNamespace getVariable ["WL2_mapMenuButtonIcons", createHashMap];

    private _buttons = [
        ["ft-asset", format ["<t color='#00ff00'>%1</t>", localize "STR_WL_fastTravel"], 0, true, true, _iconMap getOrDefault ["ft-asset", ""]],
        ["ft-regular", localize "STR_WL_fastTravelRandom", 0, true, true, _iconMap getOrDefault ["ft-regular", ""]],
        ["ft-parachute", localize "STR_WL_fastTravelAirAssault", WL_COST_AIRASSAULT, true, true, _iconMap getOrDefault ["ft-parachute", ""]],
        ["sector-scan", localize "STR_WL_sectorScan", WL_COST_SCAN, true, true, _iconMap getOrDefault ["sector-scan", ""]]
    ];
    _display setVariable ["INTRO_menuButtonOrder", _buttons apply { _x # 0 }];

    private _settings = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
    private _rowHeight = 0.045 * (_settings getOrDefault ["mapButtonScale", 1.0]);
    private _backplates = [];
    {
        private _backplate = _display ctrlCreate ["RscText", -1];
        _backplate ctrlSetPosition [0, _rowHeight * (_forEachIndex + 1), 0.5, _rowHeight];
        _backplate ctrlSetBackgroundColor [0, 0, 0, 1];
        _backplate ctrlEnable false;
        _backplate ctrlCommit 0;
        _backplate setVariable ["WL2_mapButtonId", _x # 0];
        _backplate setVariable ["INTRO_menuBackground", true];
        _backplates pushBack _backplate;
    } forEach _buttons;
    private _data = [[0, localize "STR_WL_introSector", _buttons]];
    private _menuControls = [_display, [0, 0], _data, true, "INTRO_MenuButton"] call WL2_fnc_addMapButtonsDisplay;
    {
        (_menuControls # (1 + _forEachIndex * 2)) setVariable ["INTRO_menuBackground", true];
    } forEach _buttons;
    private _created = _backplates + _menuControls;
    private _width = 0;
    private _height = 0;
    {
        private _position = ctrlPosition _x;
        _x setVariable ["INTRO_menuPosition", _position];
        _x ctrlEnable false;
        _x ctrlSetFade 1;
        _x ctrlCommit 0;
        _width = _width max ((_position # 0) + (_position # 2));
        _height = _height max ((_position # 1) + (_position # 3));
    } forEach _created;
    _display setVariable ["INTRO_menuControls", _created];
    _display setVariable ["INTRO_menuSize", [_width, _height]];
    [_display, "update"] call INTRO_fnc_menuScene;
};
